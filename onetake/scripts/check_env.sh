#!/usr/bin/env bash
# check_env.sh — what can this machine run of the onetake pipeline?
#
#   bash scripts/check_env.sh            # check, and pip-install missing Python packages
#   bash scripts/check_env.sh --no-install
#
# Prints one line per capability (ok / missing) and a summary of which protocol steps
# will work here. Never loops on a failed install: one attempt, then it reports.

INSTALL=1
[ "${1:-}" = "--no-install" ] && INSTALL=0

ok()   { printf '  \033[32mok\033[0m       %s\n' "$1"; }
miss() { printf '  \033[33mmissing\033[0m  %s\n' "$1"; }

PY=python3
PIP_FLAGS="--quiet --disable-pip-version-check"
$PY -m pip install --help 2>/dev/null | grep -q -- --break-system-packages && PIP_FLAGS="$PIP_FLAGS --break-system-packages"

echo "tools"
HAVE_FFMPEG=0; HAVE_NODE=0; HAVE_CHROMIUM=0
command -v ffmpeg  >/dev/null && command -v ffprobe >/dev/null && { ok "ffmpeg / ffprobe"; HAVE_FFMPEG=1; } || miss "ffmpeg / ffprobe  (render.py, analyze_ref.py, verify_promo.py)"
command -v node    >/dev/null && { ok "node $(node --version)"; HAVE_NODE=1; } || miss "node  (scripts/test_motion.js)"

echo "python packages"
# import name : pip name
PKGS="numpy:numpy scipy:scipy PIL:Pillow matplotlib:matplotlib fontTools:fonttools brotli:brotli cv2:opencv-python-headless playwright:playwright"
MISSING=""
for pair in $PKGS; do
  mod=${pair%%:*}; pkg=${pair##*:}
  if $PY -c "import $mod" 2>/dev/null; then ok "$pkg"; else MISSING="$MISSING $pkg"; fi
done
if [ -n "$MISSING" ] && [ $INSTALL = 1 ]; then
  echo "  installing:$MISSING"
  $PY -m pip install $PIP_FLAGS $MISSING >/dev/null 2>&1 || true
  for pkg in $MISSING; do
    mod=$pkg; case $pkg in Pillow) mod=PIL;; fonttools) mod=fontTools;; opencv-python-headless) mod=cv2;; esac
    $PY -c "import $mod" 2>/dev/null && ok "$pkg (installed)" || miss "$pkg"
  done
else
  for pkg in $MISSING; do miss "$pkg"; done
fi

echo "headless chromium"
if $PY -c "import playwright" 2>/dev/null; then
  probe() { $PY - <<'EOF' 2>/dev/null
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page(); pg.set_content("<p>ok</p>"); assert pg.inner_text("p") == "ok"; b.close()
print("launched")
EOF
  }
  if [ "$(probe)" = "launched" ]; then ok "chromium via playwright"; HAVE_CHROMIUM=1
  elif [ $INSTALL = 1 ]; then
    echo "  trying: playwright install chromium (one attempt; often blocked by sandbox network rules)"
    timeout 240 $PY -m playwright install chromium >/dev/null 2>&1 || true
    if [ "$(probe)" = "launched" ]; then ok "chromium via playwright (installed)"; HAVE_CHROMIUM=1
    else miss "chromium — playwright cannot launch a browser here"; fi
  else miss "chromium — playwright cannot launch a browser here"; fi
else
  miss "chromium — playwright not installed"
fi

echo
echo "what runs here"
echo "  concept, beat sheet, comp.html on lib/motion.js, look.py apply     yes"
[ $HAVE_NODE = 1 ]     && echo "  library tests (node scripts/test_motion.js)                        yes" \
                       || echo "  library tests (node scripts/test_motion.js)                        no  — needs node"
[ $HAVE_FFMPEG = 1 ]   && echo "  analyze_ref.py on an attached reference clip                       yes" \
                       || echo "  analyze_ref.py on an attached reference clip                       no  — needs ffmpeg"
if [ $HAVE_CHROMIUM = 1 ] && [ $HAVE_FFMPEG = 1 ]; then
  echo "  stills / probe / render (1080p30 drafts) / verify --comp           yes"
else
  echo "  stills / probe / render / verify --comp                            no  — deliver comp.html + local render commands"
fi
echo "  record_footage.py on live sites, --gpu, Kokoro/whisper narration   run these on your own machine"

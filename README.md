# onetake — Claude skill for product motion films

An installable **Claude skill** packaging of [onetake](https://github.com/feitangyuan/onetake) by Patrick
([@feitangyuan](https://github.com/feitangyuan)): short product / app / skill motion videos (10–30 s launch clips,
narrated feature demos up to ~60 s) built as one HTML composition where every value is a function of time, rendered
frame by frame with shutter motion blur, scored with synthesised sound, and checked by an oracle that fails a
slideshow before a human has to watch it.

This repo adds what the upstream repo doesn't have for Claude chat: a SKILL.md that passes the skill upload
validator (description cut from 1,440 to under 1,024 characters), a section on what the chat sandbox can and
can't run, an environment check script, a lean package (≈4 MB, without the 89 MB of case videos), and a
ready-to-upload zip.

## Install

### Claude (claude.ai / desktop / mobile)

1. Download **[`dist/onetake.zip`](dist/onetake.zip)** (or the zip on the latest release).
2. In Claude, open **Settings → Capabilities** and make sure code execution is on.
3. Under **Skills**, choose **Upload skill** and pick `onetake.zip`.
4. Ask for a film: *"Make a 15-second launch video for my app"*, *"做个产品宣传片"*, or attach a reference clip
   and say *"I want this feel."*

Menu names in Claude's settings can change; if these don't match, look for Skills in Settings.

### Claude Code

```bash
git clone https://github.com/alisaleem252/onetake-animations-skills
mkdir -p ~/.claude/skills && cp -r onetake-animations-skills/onetake ~/.claude/skills/onetake
```

Local machines get the whole pipeline, including 4K60 finals, `--gpu` renders, live-site footage capture and narration.

## What works where

| step | Claude chat sandbox | your machine (Claude Code) |
|---|---|---|
| concept round, beat sheet, `comp.html` on `lib/motion.js`, looks | yes | yes |
| `analyze_ref.py` on an attached reference clip | yes (ffmpeg) | yes |
| stills, probe, 1080p30 draft render, verify | if headless Chromium launches (`scripts/check_env.sh` tells you) | yes |
| `record_footage.py` on live sites | no (sandbox network allowlist) | yes |
| 4K60 final, `--gpu` WebGL, Kokoro / faster-whisper narration | no | yes |

When Chromium isn't available in chat, the skill tells Claude to hand you `comp.html` (preview with `?play` in any
browser) plus the exact render commands to run locally.

Local requirements: python3 with `playwright` (chromium), `numpy`, `scipy`, `Pillow`, `matplotlib`, `fonttools`,
`brotli`, `opencv-python`; `ffmpeg`/`ffprobe`; `node`. Run `bash onetake/scripts/check_env.sh` to see what's missing.

## Layout

```
onetake/                 the skill folder — this is what gets zipped and installed
  SKILL.md               protocol: reference → 3 concepts → beat sheet → footage → compose → render → sound → verify
  lib/                   motion.js (the move library, window.OM), ui_kit.js (rebuilt-UI helpers, window.UIK)
  scripts/               analyze_ref, record_footage, probe, render, stills, look, sfx_palette, verify_promo, vo_tools, check_env …
  references/            rhythm, composition, motion library, sound, product demos, 3D, reference deconstruction
  templates/             comp.html skeleton, footage and sound-score examples
  looks/                 six measured looks + OFL fonts
  gallery/               one live demo per move + contact sheets
  cases/*/README.md      beat sheets and lessons from 13 accepted films (videos: see upstream)
build.sh                 → dist/onetake.zip
.upstream-sha            the upstream commit this package was built from
```

## Updating from upstream

```bash
git clone --depth 1 https://github.com/feitangyuan/onetake /tmp/onetake-upstream
# copy lib/ scripts/ references/ templates/ looks/ gallery/ and cases/*/README.md into onetake/,
# keep this repo's SKILL.md edits (description, "Running inside Claude chat", scripts/check_env.sh row),
# record the new commit in .upstream-sha, then:
./build.sh
```

## License — read before using it for client work

onetake is © 2026 Patrick and licensed under the **PolyForm Noncommercial License 1.0.0** ([LICENSE](LICENSE)).
That license is kept unchanged here, as it requires.

> Required Notice: Copyright (c) 2026 Patrick. onetake is free for noncommercial use only.

Free for personal projects, study and other noncommercial use. **Commercial use, including videos made for paying
clients or to promote a commercial product, needs a commercial license from the author.** See the
[upstream README](https://github.com/feitangyuan/onetake) for how to get one. The packaging changes in this repo
are offered under the same terms.

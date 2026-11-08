# onetake — Claude plugin marketplace for product motion films

![onetake — motion films that never cut to the next slide](https://raw.githubusercontent.com/feitangyuan/onetake/main/assets/hero.gif)

> **Credit:** onetake is created by **Patrick ([@feitangyuan](https://github.com/feitangyuan))**.
> Original project: **[github.com/feitangyuan/onetake](https://github.com/feitangyuan/onetake)**. This repo only
> packages it as a Claude plugin marketplace and an uploadable Claude skill. The move library, scripts, references,
> looks, gallery and case studies are all his work. Star and follow the original.

Short product / app / skill motion videos (10–30 s launch clips, narrated feature demos up to ~60 s) built as one
HTML composition where every value is a function of time, rendered frame by frame with shutter motion blur, scored
with synthesised sound, and checked by an oracle that fails a slideshow before a human has to watch it.

## Install

### As a marketplace (Claude desktop app and Claude Code)

Add this repo as a marketplace, then install the `onetake` plugin from it.

**Claude desktop app:** open the plugins settings, choose to add a marketplace, and enter
`alisaleem252/onetake-animations-skills` (or the full GitHub URL). Then install **onetake** from the
**onetake-animations** marketplace. Menu names in the app can change; look for Plugins or Marketplaces in Settings.

**Claude Code**, inside a session:

```
/plugin marketplace add alisaleem252/onetake-animations-skills
/plugin install onetake@onetake-animations
```

or in one step (Claude Code 2.1.275 or later):

```
/plugin install onetake --marketplace alisaleem252/onetake-animations-skills
```

or from your shell:

```bash
claude plugin marketplace add alisaleem252/onetake-animations-skills
claude plugin install onetake@onetake-animations
```

Updates: `/plugin marketplace update onetake-animations`.

### As a single skill upload (claude.ai / desktop / mobile)

1. Download **[`dist/onetake.zip`](dist/onetake.zip)** (or the zip on the latest release).
2. Make sure code execution is on in Claude's settings.
3. Under **Skills**, choose **Upload skill** and pick `onetake.zip`.

### Then ask for a film

*"Make a 15-second launch video for my app"*, *"做个产品宣传片"*, or attach a reference clip and say *"I want
this feel."* The skill walks through reference → three concepts → beat sheet → compose → render → sound → verify.

## What works where

| step | Claude chat sandbox | your machine (Claude Code / desktop) |
|---|---|---|
| concept round, beat sheet, `comp.html` on `lib/motion.js`, looks | yes | yes |
| `analyze_ref.py` on an attached reference clip | yes (ffmpeg) | yes |
| stills, probe, 1080p30 draft render, verify | if headless Chromium launches (`scripts/check_env.sh` tells you) | yes |
| `record_footage.py` on live sites | no (sandbox network allowlist) | yes |
| 4K60 final, `--gpu` WebGL, Kokoro / faster-whisper narration | no | yes |

When Chromium isn't available in chat, the skill tells Claude to hand you `comp.html` (preview with `?play` in any
browser) plus the exact render commands to run locally.

Local requirements: python3 with `playwright` (chromium), `numpy`, `scipy`, `Pillow`, `matplotlib`, `fonttools`,
`brotli`, `opencv-python`; `ffmpeg`/`ffprobe`; `node`. Run `bash scripts/check_env.sh` from the skill folder to see
what's missing.

## Layout

```
.claude-plugin/marketplace.json      the marketplace: "onetake-animations", one plugin
plugins/onetake/
  .claude-plugin/plugin.json         the plugin manifest
  skills/onetake/                    the skill (also what dist/onetake.zip contains)
    SKILL.md                         reference → 3 concepts → beat sheet → footage → compose → render → sound → verify
    lib/                             motion.js (move library, window.OM), ui_kit.js (rebuilt-UI helpers, window.UIK)
    scripts/                         analyze_ref, record_footage, probe, render, stills, look, sfx_palette, verify_promo, vo_tools, check_env …
    references/                      rhythm, composition, motion library, sound, product demos, 3D, reference deconstruction
    templates/                       comp.html skeleton, footage and sound-score examples
    looks/                           six measured looks + OFL fonts
    gallery/                         one live demo per move + contact sheets
    cases/*/README.md                beat sheets and lessons from 13 accepted films (videos: see upstream)
build.sh                             → dist/onetake.zip
.upstream-sha                        the upstream commit this package was built from
```

Check the marketplace after edits with `claude plugin validate .`.

## Updating from upstream

```bash
git clone --depth 1 https://github.com/feitangyuan/onetake /tmp/onetake-upstream
# copy lib/ scripts/ references/ templates/ looks/ gallery/ and cases/*/README.md into plugins/onetake/skills/onetake/,
# keep this repo's SKILL.md edits (description, "Running inside Claude chat", scripts/check_env.sh row),
# record the new commit in .upstream-sha, bump "version" in plugins/onetake/.claude-plugin/plugin.json, then:
./build.sh && claude plugin validate .
```

## Credits

- **onetake** — Patrick ([@feitangyuan](https://github.com/feitangyuan)), [github.com/feitangyuan/onetake](https://github.com/feitangyuan/onetake).
  Concept, protocol, motion library, scripts, looks, gallery, case studies and the hero animation above.
- **Fonts** in `looks/fonts/` — their authors, under the SIL Open Font License (see `looks/fonts/LICENSES.txt`).
- **Claude packaging** (marketplace, plugin manifest, chat-sandbox notes, `check_env.sh`, `build.sh`) —
  [Ali Saleem (@alisaleem252)](https://github.com/alisaleem252).

## License — read before using it for client work

onetake is © 2026 Patrick and licensed under the **PolyForm Noncommercial License 1.0.0** ([LICENSE](LICENSE)).
That license is kept unchanged here, as it requires.

> Required Notice: Copyright (c) 2026 Patrick. onetake is free for noncommercial use only.

Free for personal projects, study and other noncommercial use. **Commercial use, including videos made for paying
clients or to promote a commercial product, needs a commercial license from the author.** See the
[upstream README](https://github.com/feitangyuan/onetake) for how to get one. The packaging changes in this repo
are offered under the same terms.

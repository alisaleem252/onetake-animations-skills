#!/usr/bin/env bash
# build.sh — package onetake/ as an uploadable Claude skill: dist/onetake.zip
set -euo pipefail
cd "$(dirname "$0")"

# The skill upload validator rejects descriptions over 1024 characters.
desc_len=$(python3 -I -c '
import re, json, sys
t = open("onetake/SKILL.md", encoding="utf-8").read()
fm = t.split("---", 2)[1]
m = re.search(r"^description: (.*)$", fm, re.M)
d = m.group(1).strip()
print(len(json.loads(d) if d.startswith("\"") else d))')
if [ "$desc_len" -gt 1024 ]; then
  echo "SKILL.md description is $desc_len characters; the limit is 1024" >&2
  exit 1
fi

mkdir -p dist
rm -f dist/onetake.zip
zip -rqX dist/onetake.zip onetake \
  -x '*/__pycache__/*' '*.pyc' '*/.DS_Store' 'onetake/cases/*/*.mp4'
echo "dist/onetake.zip  $(du -h dist/onetake.zip | cut -f1)  (description: $desc_len chars)"

#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_MD="$SKILL_DIR/SKILL.md"

log() {
  printf '[verify-skill] %s\n' "$*"
}

die() {
  printf '[verify-skill] ERROR: %s\n' "$*" >&2
  exit 1
}

[ -f "$SKILL_MD" ] || die "SKILL.md not found"

python3 - "$SKILL_MD" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding='utf-8')
m = re.match(r'^---\n(.*?)\n---\n', text, re.S)
if not m:
    raise SystemExit('frontmatter block not found')
frontmatter = m.group(1)
keys = []
for line in frontmatter.splitlines():
    line = line.strip()
    if not line or line.startswith('#'):
        continue
    if ':' not in line:
        raise SystemExit(f'invalid frontmatter line: {line}')
    keys.append(line.split(':', 1)[0].strip())
allowed = {'name', 'description'}
extra = [k for k in keys if k not in allowed]
missing = [k for k in ('name', 'description') if k not in keys]
if extra:
    raise SystemExit(f'unexpected frontmatter keys: {extra}')
if missing:
    raise SystemExit(f'missing frontmatter keys: {missing}')
print('frontmatter ok')
PY

for script in \
  "$SKILL_DIR/scripts/fetch-upstream.sh" \
  "$SKILL_DIR/scripts/bootstrap.sh" \
  "$SKILL_DIR/scripts/run-douyin.sh" \
  "$SKILL_DIR/scripts/verify-skill.sh"
  do
  [ -f "$script" ] || die "missing script: $script"
  bash -n "$script"
  log "bash syntax ok: $(basename "$script")"
done

for forbidden in .env cookies.json download_history.json douyin_scraper.log; do
  if find "$SKILL_DIR" -name "$forbidden" -print -quit | grep -q .; then
    die "forbidden runtime file present in skill: $forbidden"
  fi
done

if find "$SKILL_DIR" -type d \( -name downloads -o -name .venv -o -name __pycache__ \) -print -quit | grep -q .; then
  die "forbidden runtime/build directory present in skill"
fi

log "skill structure looks clean"
log "verification passed"

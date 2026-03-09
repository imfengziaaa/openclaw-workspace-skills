#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-$(pwd)}"
cd "$REPO_DIR"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found" >&2
  exit 1
fi

python3 -m pip install -r requirements.txt

# Upstream llm_extractor.py imports these but requirements.txt does not pin them.
python3 -m pip install openai pydantic

python3 -m playwright install chromium

echo "Bootstrap complete for $REPO_DIR"

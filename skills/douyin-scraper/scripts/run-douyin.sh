#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 /path/to/douyin_scapy [main.py args...]" >&2
  echo "Example: $0 /path/to/douyin_scapy --scrape" >&2
  exit 1
fi

REPO_DIR="$1"
shift || true

cd "$REPO_DIR"
exec python3 main.py "$@"

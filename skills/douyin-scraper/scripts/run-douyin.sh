#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run-douyin.sh REPO_DIR [main.py args...]

Examples:
  run-douyin.sh /path/to/douyin_scapy --help
  run-douyin.sh /path/to/douyin_scapy --login
  run-douyin.sh /path/to/douyin_scapy --scrape
  run-douyin.sh /path/to/douyin_scapy --monitor --interval 300
EOF
}

log() {
  printf '[run-douyin] %s\n' "$*"
}

die() {
  printf '[run-douyin] ERROR: %s\n' "$*" >&2
  exit 1
}

contains_arg() {
  local needle="$1"
  shift || true
  local arg
  for arg in "$@"; do
    [ "$arg" = "$needle" ] && return 0
  done
  return 1
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit 0
fi

REPO_DIR="$1"
shift || true
REPO_DIR="$(cd "$REPO_DIR" 2>/dev/null && pwd)" || die "repository directory does not exist: ${REPO_DIR}"

[ -f "$REPO_DIR/main.py" ] || die "main.py not found under $REPO_DIR"
[ -f "$REPO_DIR/config.py" ] || die "config.py not found under $REPO_DIR"
[ -f "$REPO_DIR/requirements.txt" ] || die "requirements.txt not found under $REPO_DIR"

if [ -x "$REPO_DIR/.venv/bin/python" ]; then
  PYTHON_BIN="$REPO_DIR/.venv/bin/python"
  USING_VENV=1
else
  command -v python3 >/dev/null 2>&1 || die "python3 not found and no repo-local virtualenv present"
  PYTHON_BIN="$(command -v python3)"
  USING_VENV=0
  log "warning: using system python because $REPO_DIR/.venv/bin/python does not exist"
  log "recommended: run scripts/bootstrap.sh '$REPO_DIR' first"
fi

if grep -q 'MS4wLjABAAAA_THuZH1zflJo7x28u8AsqWN6OEkmOzYEbl-fhPkslzxpX9vuauJ_YTE74ogOBxHr' "$REPO_DIR/config.py"; then
  log "warning: config.py still contains the upstream sample TARGET_USERS entry"
  log "warning: replace it with the operator's own authorized target before real scraping"
fi

if contains_arg "--login" "$@"; then
  log "manual step required: the operator must complete Douyin QR-code login in the opened browser"
fi

if ! contains_arg "--login" "$@" && [ ! -f "$REPO_DIR/cookies.json" ]; then
  log "warning: cookies.json not found; non-login scraping may fail until login is completed"
fi

if contains_arg "--help" "$@" || contains_arg "-h" "$@"; then
  if [ "$USING_VENV" -eq 0 ]; then
    log "wrapper preflight complete"
    log "upstream help requires Python dependencies; run scripts/bootstrap.sh '$REPO_DIR' first"
    usage
    exit 0
  fi
fi

cd "$REPO_DIR"
exec "$PYTHON_BIN" main.py "$@"

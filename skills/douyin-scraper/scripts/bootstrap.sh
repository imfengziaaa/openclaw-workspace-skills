#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-$(pwd)}"
DRY_RUN=0
SKIP_PLAYWRIGHT=0
WITH_LLM=1

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [REPO_DIR] [--dry-run] [--skip-playwright] [--without-llm]

Prepare the upstream douyin_scapy repository for use.

Default behavior:
  - validate repo layout
  - create/reuse .venv under the repo
  - install requirements.txt
  - install openai + pydantic (used by upstream but not pinned there)
  - install Playwright Chromium
EOF
}

log() {
  printf '[bootstrap] %s\n' "$*"
}

die() {
  printf '[bootstrap] ERROR: %s\n' "$*" >&2
  exit 1
}

require_bin() {
  command -v "$1" >/dev/null 2>&1 || die "required binary not found: $1"
}

check_file() {
  [ -e "$1" ] || die "required file not found: $1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --skip-playwright)
      SKIP_PLAYWRIGHT=1
      shift
      ;;
    --without-llm)
      WITH_LLM=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      die "unknown argument: $1"
      ;;
    *)
      REPO_DIR="$1"
      shift
      ;;
  esac
done

REPO_DIR="$(cd "$REPO_DIR" 2>/dev/null && pwd)" || die "repository directory does not exist: ${REPO_DIR}"

require_bin python3
require_bin git
check_file "$REPO_DIR/main.py"
check_file "$REPO_DIR/requirements.txt"
check_file "$REPO_DIR/config.py"

if ! command -v ffmpeg >/dev/null 2>&1; then
  log "warning: ffmpeg not found; video first-frame extraction may fail"
fi

VENV_DIR="$REPO_DIR/.venv"
PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

log "repository: $REPO_DIR"
log "virtualenv: $VENV_DIR"

if [ "$DRY_RUN" -eq 1 ]; then
  log "dry-run passed"
  log "would create/reuse .venv, install requirements, optional llm deps, and Playwright Chromium"
  exit 0
fi

if [ ! -x "$PYTHON_BIN" ]; then
  log "creating virtual environment"
  python3 -m venv "$VENV_DIR"
else
  log "reusing existing virtual environment"
fi

log "upgrading pip"
"$PYTHON_BIN" -m pip install --upgrade pip

log "installing upstream requirements"
"$PIP_BIN" install -r "$REPO_DIR/requirements.txt"

if [ "$WITH_LLM" -eq 1 ]; then
  log "installing llm extras required by upstream imports: openai pydantic"
  "$PIP_BIN" install openai pydantic
else
  log "skipping optional llm extras"
fi

if [ "$SKIP_PLAYWRIGHT" -eq 0 ]; then
  log "installing Playwright Chromium"
  "$PYTHON_BIN" -m playwright install chromium
else
  log "skipping Playwright Chromium install"
fi

log "bootstrap complete"
log "python: $PYTHON_BIN"
log "next: run '$PYTHON_BIN $REPO_DIR/main.py --help' or use the skill wrapper run-douyin.sh"

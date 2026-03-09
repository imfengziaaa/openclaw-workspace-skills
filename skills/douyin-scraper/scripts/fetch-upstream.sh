#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="${DOUYIN_UPSTREAM_URL:-https://github.com/afengzi/douyin_scapy.git}"
DEFAULT_DEST="/home/node/.openclaw/workspace/repos/douyin_scapy"
DEST_DIR="$DEFAULT_DEST"
REF=""

usage() {
  cat <<'EOF'
Usage: fetch-upstream.sh [--dest PATH] [--ref BRANCH_OR_TAG]

Clone or update the upstream douyin_scapy repository.

Options:
  --dest PATH         Destination directory (default: /home/node/.openclaw/workspace/repos/douyin_scapy)
  --ref NAME          Optional branch or tag to checkout after fetch/clone
  -h, --help          Show this help

Environment:
  DOUYIN_UPSTREAM_URL Override the upstream repository URL
EOF
}

log() {
  printf '[fetch-upstream] %s\n' "$*"
}

die() {
  printf '[fetch-upstream] ERROR: %s\n' "$*" >&2
  exit 1
}

require_bin() {
  command -v "$1" >/dev/null 2>&1 || die "required binary not found: $1"
}

check_repo_shape() {
  local repo_dir="$1"
  local required=(main.py requirements.txt config.py .env.example)
  local missing=()
  local item
  for item in "${required[@]}"; do
    if [ ! -e "$repo_dir/$item" ]; then
      missing+=("$item")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    die "repository looks incomplete: missing ${missing[*]} in $repo_dir"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dest)
      [ "$#" -ge 2 ] || die "--dest requires a value"
      DEST_DIR="$2"
      shift 2
      ;;
    --ref)
      [ "$#" -ge 2 ] || die "--ref requires a value"
      REF="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

require_bin git
mkdir -p "$(dirname "$DEST_DIR")"

if [ -d "$DEST_DIR/.git" ]; then
  log "updating existing repository: $DEST_DIR"
  git -C "$DEST_DIR" remote get-url origin >/dev/null 2>&1 || die "$DEST_DIR exists but is not a usable git repository"
  git -C "$DEST_DIR" fetch --tags origin
  if [ -n "$REF" ]; then
    git -C "$DEST_DIR" checkout "$REF"
    git -C "$DEST_DIR" pull --ff-only origin "$REF"
  else
    current_branch="$(git -C "$DEST_DIR" branch --show-current || true)"
    if [ -n "$current_branch" ]; then
      git -C "$DEST_DIR" pull --ff-only origin "$current_branch"
    else
      log "repository is in detached HEAD state; leaving current checkout unchanged"
    fi
  fi
elif [ -e "$DEST_DIR" ]; then
  die "destination exists and is not a git repository: $DEST_DIR"
else
  log "cloning upstream repository into: $DEST_DIR"
  if [ -n "$REF" ]; then
    git clone --depth 1 --branch "$REF" "$UPSTREAM_URL" "$DEST_DIR"
  else
    git clone --depth 1 "$UPSTREAM_URL" "$DEST_DIR"
  fi
fi

check_repo_shape "$DEST_DIR"

log "repository ready: $DEST_DIR"
log "next steps:"
log "  1) cp '$DEST_DIR/.env.example' '$DEST_DIR/.env'"
log "  2) edit '$DEST_DIR/config.py' and replace the default TARGET_USERS example"
log "  3) run bootstrap.sh '$DEST_DIR'"

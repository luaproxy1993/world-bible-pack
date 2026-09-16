#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE=0
ALL=0
DEST=""

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]
  --dir PATH      Install destination
  --all-agents    Also copy to Claude / Cursor / Codex / .agents
  --force         Overwrite
Default: ~/.grok/skills/world-bible-pack

  npx skills add luaproxy1993/world-bible-pack -y
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DEST="${2:?}"; shift 2 ;;
    --all-agents) ALL=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

install_one() {
  local target="$1"
  case "$target" in
    "~/"*) target="$HOME/${target#~/}" ;;
  esac
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ "$FORCE" -ne 1 ]; then
    echo "skip existing $target  use --force to overwrite"
    return 0
  fi
  rm -rf "$target"
  mkdir -p "$target"
  rsync -a --exclude dist --exclude .git --exclude .DS_Store --exclude __pycache__ "$SCRIPT_DIR/" "$target/"
  chmod +x "$target/install.sh" 2>/dev/null || true
  echo "installed -> $target"
}

if [ -n "$DEST" ]; then
  install_one "$DEST"
else
  install_one "$HOME/.grok/skills/world-bible-pack"
fi

if [ "$ALL" -eq 1 ]; then
  install_one "$HOME/.claude/skills/world-bible-pack"
  install_one "$HOME/.cursor/skills/world-bible-pack"
  install_one "$HOME/.codex/skills/world-bible-pack"
  install_one "$HOME/.agents/skills/world-bible-pack"
fi

echo "world-bible-pack v$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo unknown)"
echo "In the agent: /world-bible-pack"

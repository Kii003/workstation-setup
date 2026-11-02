#!/usr/bin/env bash
# Claude Code on macOS: install the CLI, link shared config + your own skills, install plugins.
# Called by setup.sh (DRY_RUN, SHARED_DIR, BACKUP_DIR come from there) — or run it alone.
set -uo pipefail

SHARED_DIR="${SHARED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../shared" && pwd)}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.workstation-setup-backup/$(date +%Y%m%d-%H%M%S)}"
DRY_RUN="${DRY_RUN:-0}"
SRC="$SHARED_DIR/claude"
DEST="$HOME/.claude"
export PATH="$HOME/.local/bin:$PATH"

run() { if [ "$DRY_RUN" = 1 ]; then printf "  [dry-run] %s\n" "$*"; else "$@"; fi; }
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "  ✓ $dst (already linked)"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then run mkdir -p "$BACKUP_DIR"; run mv "$dst" "$BACKUP_DIR/"; echo "  ! backed up $dst"; fi
  run mkdir -p "$(dirname "$dst")"; run ln -s "$src" "$dst"; echo "  ✓ $dst"
}

# 1) CLI via the official native installer (npm install is deprecated and needs Node)
if command -v claude >/dev/null 2>&1; then
  echo "  ✓ $(claude --version 2>/dev/null | head -1)"
elif [ "$DRY_RUN" = 1 ]; then
  echo "  [dry-run] curl -fsSL https://claude.ai/install.sh | bash"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

# 2) Global config
link "$SRC/CLAUDE.md"     "$DEST/CLAUDE.md"
link "$SRC/settings.json" "$DEST/settings.json"

# 3) Your own skills / agents / commands — linked one by one so other content in ~/.claude stays untouched
for kind in skills agents commands hooks; do
  [ -d "$SRC/$kind" ] || continue
  for item in "$SRC/$kind"/*; do
    [ -e "$item" ] || continue
    case "$(basename "$item")" in README.md|.gitkeep) continue ;; esac
    link "$item" "$DEST/$kind/$(basename "$item")"
  done
done

# 4) Plugins from plugins.txt
grep -Ev '^[[:space:]]*(#|$)' "$SRC/plugins.txt" | while read -r line; do
  case "$line" in
    marketplace:*)
      repo="${line#marketplace:}"
      if [ "$DRY_RUN" = 1 ]; then echo "  [dry-run] claude plugin marketplace add $repo"
      elif claude plugin marketplace add "$repo" >/dev/null 2>&1; then echo "  ✓ marketplace $repo"
      else echo "  ! marketplace $repo — inside Claude Code run: /plugin marketplace add $repo"; fi ;;
    *)
      if [ "$DRY_RUN" = 1 ]; then echo "  [dry-run] claude plugin install $line"
      elif claude plugin install "$line" >/dev/null 2>&1; then echo "  ✓ plugin $line"
      else echo "  ! $line not installed automatically — inside Claude Code run: /plugin install $line"; fi ;;
  esac
done

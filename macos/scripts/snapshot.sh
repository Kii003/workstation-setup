#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════
# Run on a machine that's already set up, to keep the repo current.
# Only changes files inside the repo. Never deletes anything.
#   1. lists Homebrew packages / VS Code extensions not yet in any Brewfile
#   2. copies your own (non-linked) Claude skills/agents/commands into shared/claude/
#   3. copies your Hammerspoon config
# Then review, commit and push.
# ═════════════════════════════════════════════════════════════
set -uo pipefail
MACOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "$MACOS_DIR/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
lower() { tr '[:upper:]' '[:lower:]'; }

echo "==> Homebrew packages installed but not in any Brewfile"
brew bundle dump --file="$TMP/now" --force >/dev/null 2>&1
grep -hEo '^(brew|cask) "[^"]+"' "$MACOS_DIR"/brew/*.Brewfile | sort -u > "$TMP/known"
grep -hEo '^(brew|cask) "[^"]+"' "$TMP/now" | sort -u | comm -13 "$TMP/known" - > "$TMP/new"
if [ -s "$TMP/new" ]; then sed 's/^/   /' "$TMP/new"; echo "   → copy the ones you want into a module in macos/brew/"
else echo "   ✓ nothing new"; fi

echo "==> VS Code extensions not in vscode.Brewfile"
if command -v code >/dev/null 2>&1; then
  grep -hEo '^vscode "[^"]+"' "$MACOS_DIR"/brew/*.Brewfile | sed 's/^vscode "\(.*\)"$/\1/' | lower | sort -u > "$TMP/ext_known"
  code --list-extensions | lower | sort -u | comm -13 "$TMP/ext_known" - > "$TMP/ext_new"
  if [ -s "$TMP/ext_new" ]; then sed 's/^/   vscode "/; s/$/"/' "$TMP/ext_new"; else echo "   ✓ nothing new"; fi
else
  echo "   (VS Code CLI not found)"
fi

echo "==> Your own Claude skills / agents / commands"
for kind in skills agents commands; do
  [ -d "$HOME/.claude/$kind" ] || continue
  for item in "$HOME/.claude/$kind"/*; do
    [ -e "$item" ] || continue
    [ -L "$item" ] && continue                         # already linked from the repo
    name="$(basename "$item")"
    target="$REPO_DIR/shared/claude/$kind/$name"
    if [ -e "$target" ]; then echo "   ! $kind/$name already in repo — not overwritten"
    else mkdir -p "$(dirname "$target")"; cp -R "$item" "$target"; echo "   + $kind/$name"; fi
  done
done

echo "==> Hammerspoon"
if [ -f "$HOME/.hammerspoon/init.lua" ] && [ ! -L "$HOME/.hammerspoon/init.lua" ]; then
  cp "$HOME/.hammerspoon/init.lua" "$MACOS_DIR/hammerspoon/init.lua"; echo "   + hammerspoon/init.lua"
else echo "   ✓ already linked or not present"; fi

echo
echo "==> Manual: Raycast → Settings → Advanced → Export → save into macos/raycast/"
echo
git -C "$REPO_DIR" status --short

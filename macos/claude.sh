#!/usr/bin/env bash
# Claude Code on macOS: install the CLI, link shared config + your own skills, install plugins.
# Called by setup.sh (DRY_RUN, SHARED_DIR, BACKUP_DIR come from there) — or run it alone.
set -uo pipefail

SHARED_DIR="${SHARED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../shared" && pwd)}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.workstation-setup-backup/$(date +%Y%m%d-%H%M%S)}"
DRY_RUN="${DRY_RUN:-0}"
LINK_SKILLS_FOR_OTHER_AGENTS="${LINK_SKILLS_FOR_OTHER_AGENTS:-true}"
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

# 3b) Skills are an open standard (SKILL.md) - also link them where other agents look
#     (~/.agents/skills: Codex CLI and the `npx skills` installer), so one copy serves every tool
if [ "$LINK_SKILLS_FOR_OTHER_AGENTS" = true ] && [ -d "$SRC/skills" ]; then
  for item in "$SRC/skills"/*; do
    [ -d "$item" ] || continue
    link "$item" "$HOME/.agents/skills/$(basename "$item")"
  done
fi

# 4) Plugins from plugins.txt
{ grep -Ev '^[[:space:]]*(#|$)' "$SRC/plugins.txt" || true; } | while read -r line; do
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

# 5) MCP servers from mcp-servers.txt (user scope; existing names are left alone)
if [ -f "$SRC/mcp-servers.txt" ]; then
  { grep -Ev '^[[:space:]]*(#|$)' "$SRC/mcp-servers.txt" || true; } | while read -r name transport rest; do
    [ -n "$rest" ] || { echo "  ! mcp-servers.txt: incomplete line for '$name'"; continue; }
    rest="${rest//\~\//$HOME/}"    # expand ~/ in paths
    if [ "$DRY_RUN" = 1 ]; then echo "  [dry-run] claude mcp add $name ($transport)"; continue; fi
    if claude mcp get "$name" >/dev/null 2>&1; then echo "  ✓ mcp $name (exists)"; continue; fi
    case "$transport" in
      http|sse) claude mcp add --scope user --transport "$transport" "$name" "$rest" >/dev/null 2>&1 ;;
      stdio)    # shellcheck disable=SC2086
                claude mcp add --scope user "$name" -- $rest >/dev/null 2>&1 ;;
      *) echo "  ! mcp $name: unknown transport '$transport'"; continue ;;
    esac && echo "  ✓ mcp $name" || echo "  ! mcp $name not added - try: claude mcp add --scope user ..."
  done
fi
true

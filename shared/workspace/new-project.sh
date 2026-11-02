#!/usr/bin/env bash
# Create a project from _templates/project/ and register it in the router.
#
#   ./new-project.sh <container> <name> ["one-line description"]
#   ./new-project.sh 20_Private/80_Labs weather-bot "Telegram bot for rain alerts"
#
# Never overwrites: refuses if the project folder already exists.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ $# -ge 2 ] || { sed -n '4,6p' "$0" | sed 's/^# \{0,1\}//'; echo; echo "Containers:"; (cd "$ROOT" && find . -mindepth 2 -maxdepth 2 -type d -name '[0-9]*' ! -path './00_*' ! -path '*/00_Shared' | sed 's#^\./#  #' | sort); exit 1; }
container="${1%/}"; name="$2"; desc="${3:-<what it is>}"

case "$name" in *[!a-z0-9-]*|-*|"") echo "Name must be lowercase-with-dashes (like the GitHub repo): $name"; exit 1 ;; esac
[ -d "$ROOT/$container" ] || { echo "Container not found: $ROOT/$container"; exit 1; }
dest="$ROOT/$container/$name"
[ -e "$dest" ] && { echo "Already exists, not touching it: $dest"; exit 1; }

cp -R "$ROOT/_templates/project" "$dest"
today="$(date +%Y-%m-%d)"
find "$dest" -type f \( -name '*.md' \) -print0 | while IFS= read -r -d '' f; do
  sed -i.bak -e "s/{{PROJECT}}/$name/g" -e "s/{{DATE}}/$today/g" "$f" && rm -f "$f.bak"
done
git -C "$dest" init -q
git -C "$dest" add -A
git -C "$dest" -c commit.gpgsign=false commit -q -m "Initial project scaffold"

# Register in the router, just above "## Conventions"
router="$ROOT/CLAUDE.md"
line="- \`$container/$name\` - $desc (local git only)"
if [ -f "$router" ] && grep -q '^## Conventions' "$router"; then
  n="$(grep -n '^## Conventions' "$router" | head -1 | cut -d: -f1)"
  # insert before the blank line that precedes the heading, so entries stay one block
  [ "$n" -gt 1 ] && [ -z "$(sed -n "$((n-1))p" "$router")" ] && n=$((n-1))
  awk -v l="$line" -v t="$n" 'NR==t { print l } { print }' "$router" > "$router.tmp" && mv "$router.tmp" "$router"
fi

echo "✓ $dest"
echo "  registered in CLAUDE.md (router) - edit the description there if needed"
echo "  next: cd \"$dest\" && claude"
echo "        then fill in CLAUDE.md; with Matt Pocock's skills run /setup-matt-pocock-skills once"

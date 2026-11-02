#!/usr/bin/env bash
# Run one digest track headlessly and file the result in the knowledge-base inbox.
#   ./run.sh mechanics      (track B)
#   ./run.sh news           (track A)
#   ./run.sh all
# Needs: Claude Code signed in (`claude` once interactively). Read-only web tools only.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"   # launchd has a minimal PATH

INBOX="$(cd ../../../00_Knowledge-Base/01-inbox 2>/dev/null && pwd)" || { echo "knowledge-base inbox not found"; exit 1; }
TODAY="$(date +%Y-%m-%d)"
mkdir -p state

run_track() {
  local track="$1" out prev prompt tmp
  out="$INBOX/$TODAY-digest-$track.md"
  [ -e "$out" ] && { echo "exists, skipping: $out"; return 0; }
  prev="$(ls -1 "$INBOX"/*-digest-"$track".md 2>/dev/null | sort | tail -1 || true)"
  prompt="$(sed "s/{{DATE}}/$TODAY/g" "prompts/$track.md")"
  prompt="$prompt

Today is $TODAY. Previous digest: ${prev:-none}."
  tmp="$(mktemp)"
  if claude -p "$prompt" --allowedTools "WebSearch,WebFetch,Read" --output-format text > "$tmp" 2> "state/last-error-$track.log"; then
    # keep only the file content: drop anything the model wrote before the frontmatter
    awk 'f || /^---[[:space:]]*$/ { f=1; print }' "$tmp" > "$tmp.clean"
    if grep -q '^# ' "$tmp.clean"; then
      mv "$tmp.clean" "$out"; rm -f "$tmp"; echo "✓ $out"
      printf '## [%s] digest | %s track\nFiled %s\n\n' "$TODAY" "$track" "$(basename "$out")" >> docs/log.md
    else
      mv "$tmp" "state/last-bad-output-$track.md"; rm -f "$tmp.clean"; echo "✗ $track: output had no digest heading - see state/"; return 1
    fi
  else
    rm -f "$tmp"; echo "✗ $track: claude failed - see state/last-error-$track.log"; return 1
  fi
}

case "${1:-all}" in
  mechanics|news) run_track "$1" ;;
  all) run_track mechanics; run_track news ;;
  *) echo "usage: $0 [mechanics|news|all]"; exit 1 ;;
esac

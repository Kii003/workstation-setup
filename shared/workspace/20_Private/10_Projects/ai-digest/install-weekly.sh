#!/usr/bin/env bash
# macOS: run the digest every Monday 08:00 via launchd (runs at next wake if the Mac was asleep).
#   ./install-weekly.sh            install / update
#   ./install-weekly.sh remove     uninstall
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="com.workstation-setup.ai-digest"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if [ "${1:-}" = remove ]; then
  launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
  [ -f "$PLIST" ] && mv "$PLIST" "$DIR/state/$LABEL.plist.removed"
  echo "✓ removed (plist moved to state/)"; exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents" "$DIR/state"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$DIR/run.sh</string><string>all</string></array>
  <key>StartCalendarInterval</key><dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>0</integer></dict>
  <key>StandardOutPath</key><string>$DIR/state/launchd.log</string>
  <key>StandardErrorPath</key><string>$DIR/state/launchd.log</string>
</dict></plist>
PL
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "✓ weekly digest scheduled (Mondays 08:00). Check: launchctl list | grep ai-digest"
echo "  run now once: launchctl kickstart gui/$(id -u)/$LABEL"

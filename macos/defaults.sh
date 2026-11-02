#!/usr/bin/env bash
# Opinionated macOS settings. Every line is commented — delete what you don't want.
# All of these can be changed back in System Settings.
set -uo pipefail
PROJECTS_ROOT="${PROJECTS_ROOT:-$HOME/code}"
SCREENSHOTS_DIR="${SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"

# ─── Keyboard ────────────────────────────────────────────────
defaults write NSGlobalDomain KeyRepeat -int 2                     # fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15             # short delay before repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false # hold key = repeat, not accent popup
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false   # no smart quotes in code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2           # Tab moves through all dialog controls

# ─── Trackpad ────────────────────────────────────────────────
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true            # tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ─── Finder ──────────────────────────────────────────────────
defaults write NSGlobalDomain AppleShowAllExtensions -bool true    # show file extensions
defaults write com.apple.finder AppleShowAllFiles -bool true       # show hidden files (Cmd+Shift+. toggles)
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$PROJECTS_ROOT/"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true    # no .DS_Store on network drives
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ─── Save dialogs ────────────────────────────────────────────
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false     # save locally, not iCloud

# ─── Dock ────────────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock tilesize -int 44
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false               # don't reorder Spaces
defaults write com.apple.dock wvous-br-corner -int 4               # hot corner bottom-right: Desktop
defaults write com.apple.dock wvous-br-modifier -int 0

# ─── Screenshots ─────────────────────────────────────────────
mkdir -p "$SCREENSHOTS_DIR"
defaults write com.apple.screencapture location -string "$SCREENSHOTS_DIR"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ─── Misc ────────────────────────────────────────────────────
defaults write com.apple.TextEdit RichText -int 0                  # TextEdit opens plain text
defaults write com.apple.ActivityMonitor ShowCategory -int 0       # show all processes

for app in Finder Dock SystemUIServer; do killall "$app" >/dev/null 2>&1 || true; done
echo "  ✓ macOS settings applied (some need a logout to take effect)"

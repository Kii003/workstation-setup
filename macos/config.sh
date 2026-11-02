# ═════════════════════════════════════════════════════════════
# config.sh — the only file you need to edit
#
# Tip: keep personal values in config.local.sh (same variables,
# loaded after this file). It is gitignored, so you can pull
# template updates without merge conflicts.
# ═════════════════════════════════════════════════════════════

# ─── Git identity ────────────────────────────────────────────
GIT_NAME="Your Name"
GIT_EMAIL="you@example.com"            # default identity for all repos

# Optional second identity, used automatically for repos inside GIT_ALT_DIR
# (e.g. work vs. personal). Leave GIT_ALT_EMAIL empty to disable.
GIT_ALT_EMAIL=""
GIT_ALT_DIR="$HOME/code/personal"

# ─── Modules ─────────────────────────────────────────────────
# Each module is a file in macos/brew/<name>.Brewfile.
# Edit those files to add/remove apps. Remove a name here to skip a module.
BREW_MODULES="core browsers communication ai dev terminal productivity media vscode"
# Available but off by default:  office  containers

# ─── Runtimes (managed by mise, not Homebrew) ────────────────
# Format: tool@version, space separated. Leave empty to skip.
MISE_GLOBALS="node@lts python@3.12 pnpm@latest"

# ─── Folders ─────────────────────────────────────────────────
PROJECTS_ROOT="$HOME/code"                       # where git repos live
PROJECT_DIRS="work personal"                     # subfolders of PROJECTS_ROOT
EXTRA_DIRS=""                                    # any other folders, e.g. "$HOME/Work/Docs $HOME/Work/Misc"
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"     # instead of cluttering the Desktop

# ─── Steps ───────────────────────────────────────────────────
INSTALL_CLAUDE_CODE=true      # CLI + shared/claude config + plugins
APPLY_MACOS_DEFAULTS=true     # Finder, Dock, keyboard, trackpad (macos/defaults.sh)
LINK_DOTFILES=true            # zshrc, gitconfig, starship, ghostty

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
GIT_ALT_DIR="$HOME/Claude/20_Private"     # matches the workspace's private world

# ─── Modules ─────────────────────────────────────────────────
# Each module is a file in macos/brew/<name>.Brewfile.
# Edit those files to add/remove apps. Remove a name here to skip a module.
BREW_MODULES="core browsers communication ai dev terminal productivity media vscode"
# Available but off by default:  office  containers  local-ai

# ─── Runtimes (managed by mise, not Homebrew) ────────────────
# Format: tool@version, space separated. Leave empty to skip.
MISE_GLOBALS="node@lts python@3.12 pnpm@latest"

# ─── Workspace & folders ─────────────────────────────────────
# The Claude workspace: router, knowledge base, work/private worlds, project template
# (shared/workspace/ → copied here once, never overwritten). All your projects live inside it.
WORKSPACE_ROOT="$HOME/Claude"
# Which top-level workspace folders this machine gets. Empty = all.
# Example for a private-only machine: "00_Knowledge-Base 20_Private 30_Skills"
WORKSPACE_PARTS=""
EXTRA_DIRS=""                                    # any other folders, e.g. "$HOME/Work/Docs"
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"     # instead of cluttering the Desktop

# ─── Steps ───────────────────────────────────────────────────
INSTALL_CLAUDE_CODE=true      # CLI + shared/claude config, hooks, agents, plugins
INSTALL_WORKSPACE=true        # copy the workspace scaffold to WORKSPACE_ROOT (never overwrites)
LINK_SKILLS_FOR_OTHER_AGENTS=true   # also link your skills into ~/.agents/skills (Codex & other SKILL.md tools)
APPLY_MACOS_DEFAULTS=true     # Finder, Dock, keyboard, trackpad (macos/defaults.sh)
LINK_DOTFILES=true            # zshrc, gitconfig, starship, ghostty

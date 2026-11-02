#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════
# macOS workstation setup
#
#   ./setup.sh                  run everything
#   ./setup.sh brew claude      run only these steps
#   ./setup.sh --dry-run        show what would happen, change nothing
#   ./setup.sh --help
#
# Idempotent: safe to run as often as you like.
# Never deletes anything: files replaced by symlinks are moved to
# ~/.workstation-setup-backup/<timestamp>/
# ═════════════════════════════════════════════════════════════
set -uo pipefail

MACOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$MACOS_DIR/.." && pwd)"
SHARED_DIR="$REPO_DIR/shared"

source "$MACOS_DIR/config.sh"
[ -f "$MACOS_DIR/config.local.sh" ] && source "$MACOS_DIR/config.local.sh"

BACKUP_DIR="$HOME/.workstation-setup-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
FAILED=""
STEPS="preflight xcode homebrew brew runtimes folders workspace dotfiles claude macos summary"

# ─── Helpers ─────────────────────────────────────────────────
c_b=$'\033[1;34m'; c_g=$'\033[1;32m'; c_y=$'\033[1;33m'; c_r=$'\033[1;31m'; c_0=$'\033[0m'
step() { printf "\n%s==> %s%s\n" "$c_b" "$1" "$c_0"; }
ok()   { printf "%s  ✓ %s%s\n" "$c_g" "$1" "$c_0"; }
warn() { printf "%s  ! %s%s\n" "$c_y" "$1" "$c_0"; }
fail() { printf "%s  ✗ %s%s\n" "$c_r" "$1" "$c_0"; FAILED="$FAILED\n  - $1"; }
has()  { command -v "$1" >/dev/null 2>&1; }
run()  { if [ "$DRY_RUN" = 1 ]; then printf "  [dry-run] %s\n" "$*"; else "$@"; fi; }

# write_file <path>  (content from stdin)
write_file() {
  if [ "$DRY_RUN" = 1 ]; then printf "  [dry-run] write %s\n" "$1"; cat >/dev/null; return; fi
  mkdir -p "$(dirname "$1")"; cat > "$1"
}

# link <source> <target> — backs up an existing target instead of deleting it
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then ok "$dst (already linked)"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    run mkdir -p "$BACKUP_DIR"; run mv "$dst" "$BACKUP_DIR/"; warn "backed up $dst → $BACKUP_DIR"
  fi
  run mkdir -p "$(dirname "$dst")"; run ln -s "$src" "$dst"; ok "$dst → $src"
}

brew_env() { [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"; [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"; true; }

# ─── Steps ───────────────────────────────────────────────────
do_preflight() {
  step "Preflight"
  [ "$(uname)" = "Darwin" ] || { echo "This script is for macOS."; exit 1; }
  ok "macOS $(sw_vers -productVersion) on $(uname -m)"
  [ "$GIT_EMAIL" = "you@example.com" ] && warn "config.sh still has the example Git identity — edit it (or config.local.sh) first"
  [ "$DRY_RUN" = 1 ] && warn "DRY RUN — nothing will be changed"
  true
}

do_xcode() {
  step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then ok "installed"; return; fi
  run xcode-select --install
  [ "$DRY_RUN" = 1 ] || { echo "  Confirm the installer window, wait until it finishes, then press Enter."; read -r _; }
}

do_homebrew() {
  step "Homebrew"
  brew_env
  if ! has brew; then
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_env
  fi
  has brew && ok "$(brew --version | head -1)"
  has brew && run brew analytics off >/dev/null 2>&1
  true
}

do_brew() {
  step "Apps & CLI tools ($BREW_MODULES)"
  brew_env
  has brew || { fail "Homebrew missing — run ./setup.sh homebrew"; return; }
  run brew update >/dev/null
  for m in $BREW_MODULES; do
    local f="$MACOS_DIR/brew/$m.Brewfile"
    [ -f "$f" ] || { fail "module '$m' not found ($f)"; continue; }
    printf "\n  %s── %s ──%s\n" "$c_b" "$m" "$c_0"
    run brew bundle --file="$f" || fail "module '$m': some packages failed (scroll up)"
  done
}

do_runtimes() {
  step "Runtimes via mise"
  [ -n "$MISE_GLOBALS" ] || { ok "skipped (MISE_GLOBALS empty)"; return; }
  brew_env
  has mise || { fail "mise missing — it's in the core module"; return; }
  # shellcheck disable=SC2086
  run mise use -g $MISE_GLOBALS || fail "mise: $MISE_GLOBALS"
  ok "$MISE_GLOBALS"
}

do_folders() {
  step "Folders"
  for d in $EXTRA_DIRS; do run mkdir -p "$d"; ok "$d"; done
  run mkdir -p "$SCREENSHOTS_DIR"; ok "$SCREENSHOTS_DIR"
}

do_workspace() {
  [ "$INSTALL_WORKSPACE" = true ] || return 0
  step "Claude workspace → $WORKSPACE_ROOT"
  local src="$SHARED_DIR/workspace" added=0 kept=0 rel
  while IFS= read -r -d '' f; do
    rel="${f#$src/}"
    if [ -e "$WORKSPACE_ROOT/$rel" ]; then kept=$((kept+1)); continue; fi
    run mkdir -p "$(dirname "$WORKSPACE_ROOT/$rel")"
    run cp -p "$f" "$WORKSPACE_ROOT/$rel"
    added=$((added+1))
  done < <(find "$src" -type f -print0)
  for s in "$WORKSPACE_ROOT"/*/00_Shared/_secrets; do [ -d "$s" ] && run chmod 700 "$s"; done
  ok "$added files added, $kept already there (kept as they are)"
}

do_dotfiles() {
  [ "$LINK_DOTFILES" = true ] || return 0
  step "Dotfiles"
  local D="$MACOS_DIR/dotfiles"
  link "$D/zshrc"             "$HOME/.zshrc"
  link "$D/gitconfig"         "$HOME/.gitconfig"
  link "$SHARED_DIR/dotfiles/gitignore_global" "$HOME/.gitignore_global"
  link "$SHARED_DIR/dotfiles/starship.toml"    "$HOME/.config/starship.toml"
  link "$D/ghostty"           "$HOME/.config/ghostty/config"
  [ -f "$MACOS_DIR/hammerspoon/init.lua" ] && link "$MACOS_DIR/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"

  # Machine-specific values are generated, never committed
  local alt_block=""
  [ -n "$GIT_ALT_EMAIL" ] && alt_block="[includeIf \"gitdir:${GIT_ALT_DIR%/}/\"]
	path = ~/.gitconfig-alt"
  write_file "$HOME/.gitconfig.local" <<EOF
# generated by workstation-setup — edit config.sh and re-run ./setup.sh dotfiles
[user]
	name = $GIT_NAME
	email = $GIT_EMAIL
$alt_block
EOF
  if [ -n "$GIT_ALT_EMAIL" ]; then
    write_file "$HOME/.gitconfig-alt" <<EOF
[user]
	email = $GIT_ALT_EMAIL
EOF
    ok "Git: $GIT_EMAIL (default), $GIT_ALT_EMAIL inside $GIT_ALT_DIR"
  else
    ok "Git: $GIT_EMAIL"
  fi

  write_file "$HOME/.config/workstation-setup/env.zsh" <<EOF
# generated by workstation-setup
export WORKSTATION_SETUP_DIR="$REPO_DIR"
export WORKSPACE_ROOT="$WORKSPACE_ROOT"
EOF
  [ -f "$HOME/.zshrc.local" ] || echo "# machine-specific shell config, not in the repo" | write_file "$HOME/.zshrc.local"
}

do_claude() {
  [ "$INSTALL_CLAUDE_CODE" = true ] || return 0
  step "Claude Code"
  DRY_RUN="$DRY_RUN" SHARED_DIR="$SHARED_DIR" BACKUP_DIR="$BACKUP_DIR" LINK_SKILLS_FOR_OTHER_AGENTS="$LINK_SKILLS_FOR_OTHER_AGENTS" \
    bash "$MACOS_DIR/claude.sh" || fail "Claude Code setup"
}

do_macos() {
  [ "$APPLY_MACOS_DEFAULTS" = true ] || return 0
  step "macOS settings"
  if [ "$DRY_RUN" = 1 ]; then printf "  [dry-run] bash macos/defaults.sh\n"; return; fi
  WORKSPACE_ROOT="$WORKSPACE_ROOT" SCREENSHOTS_DIR="$SCREENSHOTS_DIR" bash "$MACOS_DIR/defaults.sh" || fail "macOS defaults"
}

do_summary() {
  step "Done"
  if [ -n "$FAILED" ]; then printf "%sFailed:%b%s\n" "$c_r" "$FAILED" "$c_0"; else ok "all automated steps finished"; fi
  cat <<EOF

${c_y}Next (manual, see README → "After the script"):${c_0}
  1. Open a new terminal so the new shell config loads
  2. Sign in to your password manager; for 1Password CLI: op signin
  3. gh auth login
  4. claude   → sign in, then /plugin to check installed plugins
  5. bash ~/.claude/hooks/test-protect-files.sh   → secret protection works?
     then in Claude Code: /doctor                   → full setup checkup
  6. cd $WORKSPACE_ROOT → fill in CLAUDE.md (router) and the two world files
  7. Sign in to your apps and grant permissions when macOS asks
EOF
}

usage() { sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'; echo; echo "Steps: $STEPS"; }

# ─── Main ────────────────────────────────────────────────────
ARGS=""
for a in "$@"; do
  case "$a" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) ARGS="$ARGS $a" ;;
  esac
done
for s in ${ARGS:-$STEPS}; do
  case " $STEPS " in *" $s "*) "do_$s" ;; *) fail "unknown step '$s'"; usage; exit 1 ;; esac
done

# =============================================================
# config.ps1 - the only file you need to edit
#
# Tip: keep personal values in config.local.ps1 (same variables,
# loaded after this file). It is gitignored, so you can pull
# template updates without merge conflicts.
# =============================================================

# --- Git identity --------------------------------------------
$GitName  = "Your Name"
$GitEmail = "you@example.com"              # default identity for all repos

# Optional second identity, used automatically for repos inside $GitAltDir
# (e.g. work vs. personal). Leave $GitAltEmail empty to disable.
$GitAltEmail = ""
$GitAltDir   = "$HOME\code\personal"

# --- Modules -------------------------------------------------
# Each module is a file in windows\apps\<name>.txt (winget IDs).
# Edit those files to add/remove apps. Remove a name here to skip a module.
$AppModules = @("core", "browsers", "communication", "ai", "dev", "terminal", "productivity", "media", "vscode")
# Available but off by default:  "office"  "containers"

# --- Runtimes (managed by mise) ------------------------------
# Format: tool@version. Empty array = skip.
$MiseGlobals = @("node@lts", "python@3.12", "pnpm@latest")

# --- Folders -------------------------------------------------
$ProjectsRoot = "$HOME\code"               # where git repos live
$ProjectDirs  = @("work", "personal")      # subfolders of ProjectsRoot
$ExtraDirs    = @()                        # any other folders, e.g. @("$HOME\Work\Docs")

# --- Steps ---------------------------------------------------
$InstallClaudeCode   = $true    # CLI + shared\claude config + plugins
$ApplyWindowsTweaks  = $true    # Explorer, taskbar, search (windows\tweaks.ps1)
$LinkDotfiles        = $true    # PowerShell profile, gitconfig, starship
$ConfigureTerminal   = $true    # Windows Terminal: PowerShell 7 as default, Nerd Font

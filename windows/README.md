# Windows setup — planned

Goal: the same experience as [`macos/`](../macos/) — one config file, one script, modular app lists, never deletes anything.

Planned mapping:

| macOS | Windows |
|---|---|
| `setup.sh` | `setup.ps1` (PowerShell 7) |
| `config.sh` | `config.ps1` |
| Homebrew `brew/*.Brewfile` | `winget/*.json` (winget import/export), optional Scoop for CLI tools |
| zsh + Starship | PowerShell profile + Starship (same `starship.toml`) |
| `defaults.sh` | registry tweaks for Explorer, taskbar, keyboard |
| `claude.sh` | `claude.ps1` — official `install.ps1`, links `shared/claude/` into `%USERPROFILE%\.claude` |
| Raycast | PowerToys (Run, FancyZones, Keyboard Manager) |
| Hammerspoon | AutoHotkey |

`shared/` (Claude Code config, skills, plugins, env templates) is reused as-is.

Contributions welcome.

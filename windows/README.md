# Windows setup — full walkthrough

Sit down at a fresh PC, paste one command, and come back to your setup.

## 1 · Before you start (once, on any machine)

- [ ] Your copy of this template exists (private repo, see the main README)
- [ ] `windows/config.ps1` has your Git identity — or put it in `config.local.ps1`
- [ ] Modules in `config.ps1` and app lists in `apps/*.txt` match what you use
- [ ] Optional: `.\setup.ps1 -Steps check` on any Windows PC verifies every winget ID in your modules exists

## 2 · Windows first-run (≈15 min, manual)

- Sign in, connect Wi-Fi, run **Windows Update** until nothing is left (winget comes with "App Installer", which updates through the Store)
- **Work PC?** Consider keeping OneDrive backup of Desktop/Documents **off** so work files don't sync to a personal account

## 3 · One command (≈30–60 min, mostly unattended)

Open **PowerShell** (normal, *not* as administrator) and paste — replace the repo URL with yours:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Kii003/workstation-setup/main/windows/bootstrap.ps1))) -Repo https://github.com/<you>/<your-repo>
```

What happens:

1. Installs Git if it's missing, clones your repo to `~\code\workstation-setup` (private repo → a GitHub sign-in window opens)
2. Asks if you want to edit `config.ps1` first — press Enter to go
3. Runs `setup.ps1`:

| Step | What it does |
|---|---|
| `preflight` | checks Windows/winget, warns if config still has example values |
| `admin` | **one UAC prompt**: Developer Mode (for symlinks), long paths, all apps machine-wide, WSL2 if containers |
| `apps` | apps marked `user:` (e.g. Spotify refuses admin installs) |
| `vscode` | VS Code extensions |
| `runtimes` | global Node/Python/pnpm via mise |
| `folders` | projects root + subfolders |
| `dotfiles` | links PowerShell profile (PS 7 and 5.1), gitconfig, starship; writes `~\.gitconfig.local`; installs PSFzf |
| `terminal` | Windows Terminal: PowerShell 7 as default, Nerd Font |
| `claude` | Claude Code CLI, global CLAUDE.md + settings, your skills, plugins |
| `tweaks` | Explorer, taskbar, search, dark mode, keyboard, clipboard history |
| `summary` | lists failures and next steps |

Accept the UAC prompt when it appears (a few seconds in), then you can walk away.

Already cloned? Run it directly:

```powershell
cd ~\code\workstation-setup\windows
.\setup.ps1 -DryRun                 # preview
.\setup.ps1                         # everything
.\setup.ps1 -Steps apps,claude      # selected steps
```

## 4 · After the script (≈20 min, manual)

1. **Close the window, open Windows Terminal** — PowerShell 7 with your profile loads.
2. **Password manager.** For 1Password: sign in → Settings → Developer → *Integrate with 1Password CLI* → `op signin`. Install the browser extension.
3. **GitHub:** `gh auth login` → GitHub.com → HTTPS → browser.
4. **Claude Code:** `claude` → sign in → `/plugin` to confirm your plugins.
5. **Sign in to your apps.**
6. Using containers? **Reboot once** so WSL2 and Docker work.

## 5 · Polish (≈10 min)

- **PowerToys:** restore your backup ([`powertoys/README.md`](powertoys/README.md))
- **AutoHotkey:** your `main.ahk` is already in Startup if it's in [`autohotkey/`](autohotkey/)
- **Taskbar:** unpin what you don't click daily — `Alt+Space` (PowerToys Run) or `Win` + typing handles the rest

---

## Shell cheat sheet (PowerShell profile)

| Command | Does |
|---|---|
| `p` | cd to your projects root |
| `z <part of name>` | jump to a recently used folder |
| `Ctrl+R` | fuzzy-search history (PSFzf) · `↑` searches history by prefix |
| `ll` / `lt` | detailed list / tree |
| `c` · `cc` · `cr` | Claude Code: new · continue last · pick session |
| `gs` `gl` `gp` `gpl` | git status · log · push · pull --rebase |
| `ports` | what's listening on which port |
| `envgen` | generate `.env` from `.env.tpl` via 1Password |
| `setup-snapshot` | sync this PC's new apps/skills back into the repo |

## Module file format (`apps/*.txt`)

```
Git.Git                     # winget ID, comment optional
user:Spotify.Spotify        # install as your user instead of admin
```

Find IDs with `winget search <name>`. After editing, check with `.\setup.ps1 -Steps check`.

## Troubleshooting

| Problem | Fix |
|---|---|
| "running scripts is disabled" | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| winget missing | Microsoft Store → "App Installer" → Update |
| a package failed | `.\setup.ps1 -Steps check` — wrong ID? Fix the module, re-run `-Steps admin` |
| files were *copied* instead of linked | Developer Mode wasn't on yet — re-run `.\setup.ps1 -Steps dotfiles,claude` |
| profile errors in Windows PowerShell 5.1 | use PowerShell 7 (`pwsh`), it's the Terminal default after setup |
| icons look broken in the prompt | Terminal font must be "JetBrainsMono Nerd Font" (`-Steps terminal`) |

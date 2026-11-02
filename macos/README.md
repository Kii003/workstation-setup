# macOS setup — full walkthrough

Chronological, from an unboxed Mac to a working setup.

## 1 · Before you start (on your current machine)

- [ ] Your copy of this template exists (private repo) and `config.sh` has your Git identity
- [ ] Modules in `config.sh` and app lists in `brew/` match what you actually use
- [ ] Your own Claude skills are in `../shared/claude/skills/` — or run `scripts/snapshot.sh` on your current machine
- [ ] Optional: adapt `../shared/workspace/` (world names, router, knowledge-base language)
- [ ] Optional: Raycast export in `raycast/`, Hammerspoon `init.lua` in `hammerspoon/`
- [ ] You know your password manager login (for 1Password: email, password, **Secret Key** from the Emergency Kit)

## 2 · macOS first-run (≈15 min, manual)

- Language, Wi-Fi, user account
- **Work machine?** Consider a separate Apple ID, and keep iCloud Drive / Desktop & Documents sync **off** so work files don't end up in a personal cloud
- FileVault on, Touch ID
- System Settings → General → Software Update

## 3 · Get the repo (≈5 min)

```bash
xcode-select --install          # git comes with the Command Line Tools — confirm the dialog, wait
git clone https://github.com/<you>/<your-repo>.git ~/code/workstation-setup
```

Private repo: GitHub asks for your username and a **personal access token** as password (github.com → Settings → Developer settings → Personal access tokens). Or download the repo as ZIP from the browser.

## 4 · Run the script (≈20–60 min, unattended)

```bash
cd ~/code/workstation-setup/macos
./setup.sh --dry-run            # optional preview
./setup.sh
```

| Step | What it does |
|---|---|
| `preflight` | checks macOS, warns if config still has example values |
| `xcode` | Command Line Tools (skipped if present) |
| `homebrew` | installs Homebrew — asks for your Mac password once |
| `brew` | installs every module listed in `BREW_MODULES` |
| `runtimes` | global Node/Python/pnpm via mise (`MISE_GLOBALS`) |
| `folders` | extra folders, screenshots folder |
| `workspace` | copies the Claude workspace to `~/Claude` (only missing files) |
| `dotfiles` | links zshrc, gitconfig, starship, ghostty; writes `~/.gitconfig.local` |
| `claude` | Claude Code CLI, global CLAUDE.md + settings, hook, agents, your skills, plugins |
| `macos` | Finder, Dock, keyboard, trackpad, screenshot settings |
| `summary` | lists failures and next steps |

Run single steps: `./setup.sh brew` · `./setup.sh dotfiles claude`

## 5 · After the script (≈30 min, manual)

Order matters — password manager first makes everything else fast.

1. **Open a new terminal** (Ghostty, if you kept the terminal module) so the new shell config loads.
2. **Password manager.** For 1Password: sign in → Settings → Developer → *Integrate with 1Password CLI* → in the terminal: `op signin`. Install the browser extension.
3. **GitHub:** `gh auth login` → GitHub.com → HTTPS → browser.
4. **Claude Code:** `claude` → sign in → `/plugin` to confirm your plugins are active. Then `bash ~/.claude/hooks/test-protect-files.sh` (all cases must pass) and `/doctor` inside Claude Code for a full setup checkup.
5. **Workspace:** fill in `~/Claude/CLAUDE.md` (router) and the two world files — see [`../shared/workspace/README.md`](../shared/workspace/README.md).
6. **Sign in to your apps** (browser, chat, notes, editor settings sync …).
7. **Apps not in Homebrew:** install manually and consider opening an issue/PR if a cask exists.

## 6 · Permissions (≈5 min)

macOS asks on first launch; otherwise System Settings → Privacy & Security:

| Typical apps | Permission |
|---|---|
| Raycast, AltTab, Hammerspoon, dictation tools | Accessibility |
| Dictation, meeting notes, video calls | Microphone |
| Meeting notes, screen sharing tools | Screen & System Audio Recording |
| Terminal (optional) | Full Disk Access |

## 7 · Polish (≈10 min)

- **Raycast:** import your export, or follow [`raycast/README.md`](raycast/README.md)
- **Browser:** separate profiles for work and personal
- **Dock:** remove everything you don't click daily — the launcher handles the rest

## 8 · Per project

New project from the template (scaffold, git init, router entry):
```bash
new-project 20_Private/80_Labs my-idea "what it is"
```
Existing repo — clone it into the right world:
```bash
cd ~/Claude/10_Work/10_Projects
gh repo clone <org>/<repo> && cd <repo>
mise install          # project's Node/Python versions from .tool-versions / mise.toml
pnpm install          # or npm / bun
envgen                # .env from .env.tpl via 1Password (see below)
claude                # with Matt Pocock's skills: run /setup-matt-pocock-skills once per repo
```
- **Knowledge base:** open `~/Claude/00_Knowledge-Base` as a vault in Obsidian.
- **AI digest:** `cd ~/Claude/20_Private/10_Projects/ai-digest && ./run.sh mechanics`, check the result in the inbox, then `./install-weekly.sh`.

---

## Secrets without plain-text .env files

1. Store the secret in your password manager (e.g. vault "Dev", item "My API").
2. Copy [`../shared/templates/env.tpl`](../shared/templates/env.tpl) into the project as `.env.tpl` and point each variable at its secret reference.
3. `envgen` writes `.env` from it. `.env.tpl` can be committed; `.env` is ignored globally.

On a new machine there's nothing to copy — sign in and run `envgen`.

---

## Shell cheat sheet

| Command | Does |
|---|---|
| `p` / `kb` | cd to the workspace / knowledge base |
| `new-project <container> <name> "desc"` | project from the template + router entry |
| `z <part of name>` | jump to a recently used folder |
| `Ctrl+R` | fuzzy-search shell history |
| `ll` / `lt` | detailed list / tree |
| `c` · `cc` · `cr` | Claude Code: new · continue last · pick session |
| `gs` `gl` `gp` `gpl` | git status · log · push · pull --rebase |
| `ports` | what's listening on which port |
| `envgen` | generate `.env` from `.env.tpl` |
| `setup-snapshot` | sync this machine back into the repo |

## Maintenance

```bash
brew update && brew upgrade
brew bundle check --file=brew/dev.Brewfile    # anything missing from a module?
setup-snapshot
```

## Handing back / wiping a machine

Run `setup-snapshot` one last time and push. Sign out of your accounts, then System Settings → General → Transfer or Reset → **Erase All Content and Settings**.

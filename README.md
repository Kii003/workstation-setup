# workstation-setup

A template for turning a fresh computer into your complete work and coding setup — apps, CLI tools, shell, Git, editor, and **Claude Code with your skills and plugins** — with one script.

Fork it, edit one config file, keep it in sync as your setup evolves. Next machine: clone, run, sign in, done.

| Platform | Status |
|---|---|
| macOS | ✅ ready — [`macos/`](macos/) |
| Windows | 🚧 planned — [`windows/`](windows/) |

---

## What you get

- **Apps & tools in modules** — browsers, communication, AI, dev, terminal, productivity, media, office, containers. Turn modules on/off in one line, edit each module's list freely.
- **Runtimes per project** via [mise](https://mise.jdx.dev) (Node, Python, pnpm …) instead of global installs.
- **Shell** — zsh with Starship prompt, autosuggestions, fuzzy history (`Ctrl+R`), `z` folder jumping, sensible aliases.
- **Git** — good defaults, GitHub CLI auth, optional automatic second identity (e.g. work vs. personal) by folder.
- **Claude Code** — official native installer, a global `CLAUDE.md` template, safe permission defaults, your own skills linked from the repo, plugins (e.g. [Matt Pocock's skills](https://github.com/mattpocock/skills)) installed from a list.
- **Secrets out of plain-text `.env`** — templates that reference your password manager, generated on demand.
- **OS settings** — Finder/Explorer, Dock/Taskbar, keyboard, trackpad, screenshots.
- **Snapshot script** — pulls new apps, extensions and skills from a running machine back into the repo, so the next setup is always current.

Safe by design: idempotent (run it as often as you want), `--dry-run` mode, and it **never deletes** anything — files it replaces are moved to a backup folder.

---

## Quick start (macOS)

**1. Make your own copy.** Click **Use this template** on GitHub → create a **private** repo (it will contain your config, skills and preferences).

**2. Customize** — on any machine, or directly on GitHub:

| File | What to change |
|---|---|
| [`macos/config.sh`](macos/config.sh) | Git name/email, modules, runtimes, folders |
| [`macos/brew/*.Brewfile`](macos/brew/) | add/remove apps in each module |
| [`shared/claude/CLAUDE.md`](shared/claude/CLAUDE.md) | your global instructions for Claude Code |
| [`shared/claude/plugins.txt`](shared/claude/plugins.txt) | Claude Code plugins to install |
| [`shared/claude/skills/`](shared/claude/skills/) | your own skills |

**3. On the new Mac:**

```bash
xcode-select --install                 # installs git; confirm the dialog and wait
git clone https://github.com/<you>/<your-repo>.git ~/code/workstation-setup
cd ~/code/workstation-setup/macos
./setup.sh --dry-run                   # optional: see what will happen
./setup.sh
```

Takes 20–60 minutes depending on modules and bandwidth. Full walkthrough — including what to do after the script — in [`macos/README.md`](macos/README.md).

---

## Repository layout

```
workstation-setup/
├── shared/                    # platform-independent
│   ├── claude/
│   │   ├── CLAUDE.md          # global Claude Code instructions (template)
│   │   ├── settings.json      # global permissions
│   │   ├── plugins.txt        # plugins to install
│   │   └── skills/            # your own skills
│   └── templates/env.tpl      # .env template referencing 1Password
├── macos/
│   ├── setup.sh               # entry point
│   ├── config.sh              # ← your settings
│   ├── brew/*.Brewfile        # app/tool modules
│   ├── dotfiles/              # zshrc, gitconfig, starship, ghostty
│   ├── defaults.sh            # macOS settings
│   ├── claude.sh              # Claude Code install + config linking
│   ├── raycast/ hammerspoon/  # app configs that can't be scripted fully
│   └── scripts/snapshot.sh    # sync a running machine back into the repo
└── windows/                   # coming next
```

`shared/` is used by both platforms, so your Claude Code setup is identical everywhere.

---

## Keeping it up to date

On a machine that's already set up:

```bash
setup-snapshot      # shell function from the zshrc
```

It lists apps and VS Code extensions you installed that aren't in any Brewfile yet, and copies new Claude skills and your Hammerspoon config into the repo. Review, commit, push.

To pull improvements from the original template into your copy, add it as a remote once and merge occasionally:

```bash
git remote add template https://github.com/<template-owner>/workstation-setup.git
git fetch template && git merge template/main
```

Keep personal values in `macos/config.local.sh` (gitignored, same variables as `config.sh`) to avoid merge conflicts.

---

## FAQ

**Do I need 1Password?** No. It's in the `core` module because the secrets workflow uses its CLI. Swap it for Bitwarden or anything else and adjust `envgen` in the zshrc.

**Do I need Claude Code?** No. Set `INSTALL_CLAUDE_CODE=false` and remove the `ai` module.

**Something failed halfway.** Fix the cause and re-run — completed steps are skipped. Run one step with `./setup.sh <step>`, e.g. `./setup.sh brew`. The summary at the end lists what failed.

**Will it overwrite my existing dotfiles?** It moves them to `~/.workstation-setup-backup/<timestamp>/` first. Nothing is deleted.

**Intel Mac?** Works — the scripts detect `/usr/local` vs. `/opt/homebrew`.

---

## Contributing

Issues and PRs welcome — especially new module suggestions, fixes for newer macOS versions, and the Windows port. Keep defaults generic and opinions commented, so forks can delete what they don't need.

## License

[MIT](LICENSE)

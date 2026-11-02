# workstation-setup

A template for turning a fresh computer into your complete work and coding setup — apps, CLI tools, shell, Git, editor, and **Claude Code with your skills and plugins** — with one script.

Fork it, edit one config file, keep it in sync as your setup evolves. Next machine: clone, run, sign in, done.

| Platform | Status |
|---|---|
| macOS | ✅ ready — [`macos/`](macos/) |
| Windows | ✅ ready — [`windows/`](windows/) |

---

## What you get

- **Apps & tools in modules** — browsers, communication, AI, dev, terminal, productivity (incl. Obsidian for the knowledge base), media, plus optional office, containers and local-ai (Ollama, LM Studio). Turn modules on/off in one line, edit each module's list freely.
- **Runtimes per project** via [mise](https://mise.jdx.dev) (Node, Python, pnpm …) instead of global installs.
- **Shell** — zsh with Starship prompt, autosuggestions, fuzzy history (`Ctrl+R`), `z` folder jumping, sensible aliases.
- **Git** — good defaults, GitHub CLI auth, optional automatic second identity (e.g. work vs. personal) by folder.
- **Claude Code** — official native installer, a global `CLAUDE.md`, secret protection (deny rules + a tested `protect-files` hook that fails closed), writes outside the project blocked, a critic subagent, plugins (e.g. [Matt Pocock's skills](https://github.com/mattpocock/skills)) and vetted MCP servers installed from lists.
- **Skills for every agent** — your `SKILL.md` skills are linked for Claude Code *and* `~/.agents/skills` (Codex and other tools that follow the open skills standard). One copy, every tool.
- **Claude workspace** — `~/Claude` with a router, separate work/private "worlds", a knowledge base following [Karpathy's LLM Wiki](shared/workspace/00_Knowledge-Base/05-practices/llm-wiki-pattern.md) pattern, and a project template where every project is a small compiled wiki around its code. `new-project` scaffolds one in a second. Includes **ai-digest**: a weekly headless Claude run that files AI changes into the knowledge-base inbox, so your rules don't go stale. → [`shared/workspace/README.md`](shared/workspace/README.md)
- **Secrets out of plain-text `.env`** — templates that reference your password manager, generated on demand.
- **OS settings** — Finder/Explorer, Dock/Taskbar, keyboard, trackpad, screenshots, dark mode.
- **Snapshot script** — pulls new apps, extensions and skills from a running machine back into the repo, so the next setup is always current.

Safe by design: idempotent (run it as often as you want), `--dry-run` mode, and it **never deletes** anything — files it replaces are moved to a backup folder.

---

> **New here?** Follow **[INSTALL.md](INSTALL.md)** — a step-by-step guide for beginners, including a version where Claude Code does the installation for you.

## Quick start (macOS)

**1. Make your own copy.** Click **Use this template** on GitHub → create a **private** repo (it will contain your config, skills and preferences).

**2. Customize** — on any machine, or directly on GitHub:

| File | What to change |
|---|---|
| [`macos/config.sh`](macos/config.sh) | Git name/email, modules, runtimes, folders |
| [`macos/brew/*.Brewfile`](macos/brew/) | add/remove apps in each module |
| [`shared/claude/CLAUDE.md`](shared/claude/CLAUDE.md) | your global instructions for Claude Code |
| [`shared/claude/plugins.txt`](shared/claude/plugins.txt) | Claude Code plugins to install |
| [`shared/claude/mcp-servers.txt`](shared/claude/mcp-servers.txt) | MCP servers to add — vet them first ([checklist](shared/workspace/00_Knowledge-Base/05-practices/mcp-vetting.md)) |
| [`shared/claude/skills/`](shared/claude/skills/) | your own skills |
| [`shared/workspace/`](shared/workspace/) | router, world rules, knowledge base, project template |

**3. On the new Mac:**

```bash
xcode-select --install                 # installs git; confirm the dialog and wait
git clone https://github.com/<you>/<your-repo>.git ~/code/workstation-setup
cd ~/code/workstation-setup/macos
./setup.sh --dry-run                   # optional: see what will happen
./setup.sh
```

Takes 20–60 minutes depending on modules and bandwidth. Full walkthrough — including what to do after the script — in [`macos/README.md`](macos/README.md).

## Quick start (Windows)

Steps 1–2 as above (Windows settings live in [`windows/config.ps1`](windows/config.ps1) and [`windows/apps/*.txt`](windows/apps/)). Then on the new PC, in a normal PowerShell window:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Kii003/workstation-setup/main/windows/bootstrap.ps1))) -Repo https://github.com/<you>/<your-repo>
```

It installs Git, clones your repo, and runs the setup with a single UAC prompt. Full walkthrough in [`windows/README.md`](windows/README.md).

---

## Repository layout

```
workstation-setup/
├── shared/                    # platform-independent
│   ├── dotfiles/              # starship.toml, gitignore_global (both platforms)
│   ├── claude/                → ~/.claude
│   │   ├── CLAUDE.md          # global instructions (template)
│   │   ├── settings.json      # deny rules, hook, plugins
│   │   ├── hooks/             # protect-files.sh + its test
│   │   ├── agents/            # adversarial-critic
│   │   ├── plugins.txt        # plugins to install
│   │   ├── mcp-servers.txt    # MCP servers to add (vetted, commented by default)
│   │   └── skills/            # your own skills
│   ├── workspace/             → ~/Claude (copied once, never overwritten)
│   │   ├── CLAUDE.md          # router
│   │   ├── 00_Knowledge-Base/ # Karpathy LLM wiki
│   │   ├── 10_Work/ 20_Private/   # worlds with their own rules + secrets
│   │   ├── 20_Private/10_Projects/ai-digest/   # weekly AI digest → knowledge-base inbox
│   │   ├── _templates/        # project / skill / agent
│   │   └── new-project.sh/.ps1
│   └── templates/env.tpl      # .env template referencing 1Password
├── macos/
│   ├── setup.sh               # entry point
│   ├── config.sh              # ← your settings
│   ├── brew/*.Brewfile        # app/tool modules
│   ├── dotfiles/              # zshrc, gitconfig, ghostty
│   ├── defaults.sh            # macOS settings
│   ├── claude.sh              # Claude Code install + config linking
│   ├── raycast/ hammerspoon/  # app configs that can't be scripted fully
│   └── scripts/snapshot.sh    # sync a running machine back into the repo
└── windows/
    ├── bootstrap.ps1          # one-command start on a fresh PC
    ├── setup.ps1              # entry point
    ├── config.ps1             # ← your settings
    ├── apps/*.txt             # winget modules (same categories as macOS)
    ├── dotfiles/              # PowerShell profile, gitconfig
    ├── tweaks.ps1             # Windows settings
    ├── claude.ps1             # Claude Code install + config linking
    ├── powertoys/ autohotkey/ # Raycast/Hammerspoon counterparts
    └── scripts/snapshot.ps1   # sync a running PC back into the repo
```

`shared/` is used by both platforms, so your Claude Code setup, workspace, prompt and global gitignore are identical everywhere.

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

Keep personal values in `macos/config.local.sh` / `windows/config.local.ps1` (gitignored, same variables as `config.sh`) to avoid merge conflicts.

---

## FAQ

**Do I need 1Password?** No. It's in the `core` module because the secrets workflow uses its CLI. Swap it for Bitwarden or anything else and adjust `envgen` in the zshrc.

**Do I need Claude Code?** No. Set `INSTALL_CLAUDE_CODE=false` and `INSTALL_WORKSPACE=false` and remove the `ai` module.

**I already have a `~/Claude` folder.** The workspace step only adds files that don't exist yet — your router, world files and projects are left alone. Point `WORKSPACE_ROOT` elsewhere to keep them fully separate.

**Is the secret protection real?** Two layers: deny rules in `settings.json` and the `protect-files.sh` hook (for what rules can't express: shell redirection, `.env.example`/`.env.tpl` exceptions, `.git/`). Run `bash ~/.claude/hooks/test-protect-files.sh` — 22 cases. It's a guard rail against mistakes, not a sandbox: the hook's header lists what it deliberately can't catch. The hook is registered with `onFailure: "block"`, so if it can't run at all, Claude Code blocks instead of silently continuing unprotected.

**Something failed halfway.** Fix the cause and re-run — completed steps are skipped. Run one step with `./setup.sh <step>`, e.g. `./setup.sh brew`. The summary at the end lists what failed.

**Will it overwrite my existing dotfiles?** It moves them to `~/.workstation-setup-backup/<timestamp>/` first. Nothing is deleted.

**Intel Mac?** Works — the scripts detect `/usr/local` vs. `/opt/homebrew`.

**Windows: is every app ID correct?** Run `.\setup.ps1 -Steps check` on any Windows PC — it verifies each winget ID in your modules.

---

## Contributing

Issues and PRs welcome — especially new module suggestions, fixes for newer macOS/Windows versions, and verified winget IDs for apps that are still commented out. Keep defaults generic and opinions commented, so forks can delete what they don't need.

## License

[MIT](LICENSE)

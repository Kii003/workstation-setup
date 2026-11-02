# Claude workspace

One folder for everything you do with Claude Code — copied to `~/Claude` by the setup (never overwrites what's there). It combines two ideas:

- **Andrej Karpathy's LLM Wiki:** knowledge is *compiled* into a small set of markdown pages that Claude maintains, instead of re-discovered every session. Used at three scales: a knowledge base, every project, and the workspace itself.
- **Matt Pocock's skills:** engineering workflows (`/tdd`, `/diagnose`, `/teach`, `/handoff`, `/wait-what` …) installed globally as a plugin, available in every folder.

```
~/Claude/
├── CLAUDE.md                 ROUTER - auto-loads in every session below ~/Claude: worlds, projects, conventions
├── 00_Knowledge-Base/        AI wiki (Karpathy): inbox → compiled pages → dashboard + log
├── 10_Work/                  WORK world - own accounts, secrets, rules (CLAUDE.md)
│   ├── 00_Shared/_secrets/   the only secret store for work
│   ├── 10_Projects/          real projects (or one numbered folder per area)
│   ├── 80_Labs/              experiments
│   └── 90_Archive/
├── 20_Private/               PRIVATE world
│   ├── 00_Shared/_secrets/
│   ├── 10_Projects/          serious private projects
│   ├── 70_Learning/          /teach workspaces, one per topic
│   ├── 80_Labs/              playground
│   └── 90_Archive/
├── 30_Skills/                skill sources you're building
├── _templates/               project, skill and agent templates
└── new-project.sh / .ps1     create a project from the template + register it in the router
```

## The one rule
**The folder decides account, secrets and rulebook.** Work code never touches private accounts and vice versa. Claude Code loads every `CLAUDE.md` from the current folder up to `~/Claude`, so a session in `20_Private/80_Labs/x` automatically gets the router + the private world rules + the project rules.

## Context layers (what Claude reads, from general to specific)
| Layer | File | Holds |
|---|---|---|
| Global | `~/.claude/CLAUDE.md` + `settings.json` + hooks | how Claude works with you; hard limits (secrets, destructive commands) |
| Workspace | `~/Claude/CLAUDE.md` | router: worlds, project list, conventions |
| World | `10_Work/CLAUDE.md`, `20_Private/CLAUDE.md` | accounts, secrets location, data rules |
| Project | `<project>/CLAUDE.md` + `docs/where-we-are.md` | stack, commands, pitfalls, current state |

Each layer stays short; details live in files that are read on demand.

## Daily use
```bash
new-project 20_Private/80_Labs weather-bot "Telegram bot for rain alerts"   # scaffold + git init + router line
cd ~/Claude/20_Private/80_Labs/weather-bot && claude
# ... work ...
"wrap up"        # Claude compiles docs/where-we-are.md, appends docs/log.md
```
Knowledge base: `kb`, then `claude` → "ingest" / "query …" / "lint".

## First steps after setup
1. Fill in the router (`CLAUDE.md`): your GitHub/hosting per world.
2. Fill in the world files (`10_Work/CLAUDE.md`, `20_Private/CLAUDE.md`): accounts, company rules, record limits.
3. Language and goals in `00_Knowledge-Base/CLAUDE.md` and `00-goals.md`.
4. Move existing projects into the right world, add a router line for each.

Background: `00_Knowledge-Base/05-practices/llm-wiki-pattern.md` and `project-standard.md`.

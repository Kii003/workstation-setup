# Workspace router

Loads automatically in every Claude Code session started anywhere below this folder.
Keep it short (~30 lines): it costs context in every session.

Two worlds plus a knowledge base. **The folder decides account, secrets and rulebook - never mix them.**

| Folder | What | GitHub / hosting | Rules |
|---|---|---|---|
| `00_Knowledge-Base/` | AI wiki: tools, models, practices, my setup (Karpathy LLM Wiki) | - | its own `CLAUDE.md` |
| `10_Work/` | work | <!-- e.g. org `acme` on GitHub, company Vercel --> | `10_Work/CLAUDE.md` |
| `20_Private/` | private | <!-- e.g. personal GitHub --> | `20_Private/CLAUDE.md` |
| `30_Skills/` | skill sources | uploaded to the Claude account or linked into `~/.claude/skills` | - |

## Projects
<!-- One line per project, added when it's created (new-project does this for you):
- `20_Private/10_Projects/my-app` - what it is (where it's hosted)
-->
- `20_Private/10_Projects/ai-digest` - weekly AI digest into the knowledge-base inbox (local git only)

## Conventions
- Container folders numbered in steps of 10 (`00_` shared/meta, `80_` labs, `90_` archive); project repos unnumbered, lowercase-with-dashes, named like on GitHub; no spaces.
- Every project follows `00_Knowledge-Base/05-practices/project-standard.md` (template: `_templates/project/`).
- Hard boundaries (secrets, destructive commands) are global in `~/.claude/settings.json` + hooks.
- New project: `./new-project.sh <world/area> <name>` (Windows: `.\new-project.ps1`) → follow that world's `CLAUDE.md`.

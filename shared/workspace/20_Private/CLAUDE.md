# 20_Private - private world

- **Accounts:** private GitHub and hosting. No company data, no company secrets, no company connectors for writing.
- **Secrets:** only in `00_Shared/_secrets/<service>.env` (gitignored, `chmod 600`). Never print a value.
- **Three kinds of projects:**
  - `10_Projects/` - **serious**: things I rely on.
  - `70_Learning/` - **teach workspaces**: one folder per subject, created with `./new-topic.sh <topic>`. Workflow in its `README.md`.
  - `80_Labs/` - **playground**: experiments for fun and learning, no pressure.
- **New project:** shape per `../00_Knowledge-Base/05-practices/project-standard.md` (template `../_templates/project/`). Local git only until it proves itself; then its own private GitHub repo. Add a line to `../CLAUDE.md` (router).
- **Build nothing on spec:** a skill only after a procedure repeated ~3x, an agent only on real need. Monthly: archive dead labs, delete unused skills/agents.
- Done or dead → `90_Archive/`.

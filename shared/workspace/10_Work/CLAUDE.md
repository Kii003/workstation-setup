# 10_Work - work world

- **Rulebook:** if your company ships its own standards (a plugin, a `standards.md`, a template repo), those win over anything here. Don't edit company-managed files; local adjustments go into the project repo, `.claude/settings.local.json` or `CLAUDE.local.md`.
- **Accounts:** <!-- company GitHub org, hosting, cloud accounts -->. Never push work code to private accounts.
- **Secrets:** only in `00_Shared/_secrets/<service>.env` (or the company secret manager). Never copy a value into a project, never print one. Projects reach them through a symlink or an `.env.tpl` that references the password manager.
- **Company systems (CRM, automation, databases):** read-only from Claude sessions unless a task explicitly says otherwise. Warn before any task that reads or writes more than <!-- N --> records (API quotas) and wait for confirmation.
- **Areas:** `10_Projects/` (or one numbered folder per department, e.g. `10_Sales/`, `20_Growth/`). Experiments → `80_Labs/<name>/` (local git only). Done or dead → `90_Archive/`.
- **New project:** create it in the right area, apply `../00_Knowledge-Base/05-practices/project-standard.md`, add a line to `../CLAUDE.md` (router).

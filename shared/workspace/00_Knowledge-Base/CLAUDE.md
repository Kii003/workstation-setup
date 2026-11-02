# Rules for this wiki

Personal AI wiki following Karpathy's LLM Wiki pattern (`05-practices/llm-wiki-pattern.md`). Topic: working better with AI - Claude, Claude Code, tools, models and workflows.

- Always read `00-dashboard.md` first, then only the relevant folder.
- `01-inbox/`: raw sources - never edit, read only.
- `02-roadmap/` to `06-setup/`: wiki pages maintained by Claude.
- Log every change with a date in `log.md`.
- **"ingest"**: work inbox items into the matching pages, update the dashboard. One source at a time; verify every claim against the primary source before it becomes a page or a task.
- **"query"**: dashboard → relevant pages → answer with page references; propose filing valuable answers as a page.
- **"lint"**: contradictions, stale claims (check frontmatter `updated`), orphan pages, missing pages/links, gaps → report + proposals.
- Mark contradictions/stale info (especially about models) with `⚠️ stale?` + date + source instead of silently overwriting.
- No customer data or internal company data - meta knowledge about workflows only.
- Language: <!-- your language -->, concise, practical.

## Conventions
- Wiki pages have YAML frontmatter: `updated`, `sources`, `tags`. Links as `[[folder/page]]` (Obsidian-compatible).
- Log entries: `## [YYYY-MM-DD] <ingest|query|lint|setup> | Title` → latest: `grep "^## \[" log.md | tail -5`.
- Inbox files: `YYYY-MM-DD-shortname.md` with frontmatter `source`, `retrieved`.

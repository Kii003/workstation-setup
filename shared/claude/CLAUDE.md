# Global instructions for Claude Code

<!--
  This file is linked to ~/.claude/CLAUDE.md and applies to every project.
  Keep it short: everything here costs context in every session.
  Project-specific rules belong in each repo's own CLAUDE.md.
  Replace the examples below with your own.
-->

## About me
- <!-- Your role and what you mostly build, e.g. "Full-stack dev, mostly Next.js + Postgres" -->
- <!-- Your experience level, so explanations are pitched right -->

## Communication
- Reply in <!-- your language -->. Code, comments and commit messages in English.
- Be concise: result first, explanation only if needed.
- When there are several options, recommend one instead of listing many.

## Way of working
- Start with the smallest working solution; add configuration only when it's actually needed.
- For larger changes (several files, schema, new dependencies): show a short plan first.
- Don't delete files without asking — rename or move instead.
- Follow the patterns already in the repo instead of introducing new ones.

## Secrets
- Never put keys or tokens in code or commits. Secrets come from the password manager (e.g. `op read`, `op inject` with a `.env.tpl`).
- Don't read or print `.env` files.

## Git
- Small, descriptive commits. Never force-push to main.

<!--
## Team / company rules
Add guardrails that matter for your org, e.g.:
- "Our CRM API has a daily quota: warn before any task that reads or writes more than 500 records."
-->

# {{PROJECT}}

<!-- Schema + index of this project's mini wiki. Keep < 200 lines. Standard: 00_Knowledge-Base/05-practices/project-standard.md -->

## What this is
<2 sentences: purpose, who uses it.>

## Stack
<language, framework, database, deploy target>

## Commands
- Setup: `<...>`
- Dev:   `<...>`
- Test:  `<...>`   # run after every change
- Lint:  `<...>`
- Build: `<...>`

## Hard limits
- `inputs/` is read-only. Results go into new files.
- Secrets come from <!-- 00_Shared/_secrets/<service>.env via .env.tpl / password manager -->. Never print them.

## Pitfalls
<What already went wrong here. The most valuable section - add to it the moment something breaks.>

## Docs (read on demand)
- `docs/decisions.md` - decisions that apply now
- `docs/context.md` - verified facts, don't re-derive
- `docs/architecture.md` - components and data flow
- `docs/roadmap.md` - phases / checklist
- `docs/log.md` - history

## Current state
@docs/where-we-are.md

## Session end ("wrap up")
Overwrite `docs/where-we-are.md` (one page, compiled - don't append) · 2-3 lines to `docs/log.md` · new decision → `docs/decisions.md` · new pitfall → above.

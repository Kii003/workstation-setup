---
updated: 2026-11-02
sources: [[05-practices/llm-wiki-pattern]], Claude Code docs (memory, CLAUDE.md imports)
tags: [project-structure, template, llm-wiki]
---

# Project standard: a mini wiki around the code

Every project is a **small Karpathy wiki around the code**. The code is the source of truth and is not wiki-fied; the knowledge around it is. Template: `_templates/project/` (created by `new-project`).

## Shape
```
<project>/
├── CLAUDE.md          SCHEMA + INDEX - < 200 lines: what, stack, commands, hard limits, pitfalls,
│                      doc list as `backticked paths` (read on demand); @-import only where-we-are
├── README.md          what / status / how to start / where secrets come from
├── inputs/            RAW - read-only (mails, specs, exports handed over)
├── docs/
│   ├── where-we-are.md   COMPILED current state - ONE page, overwritten at every session end
│   ├── decisions.md      COMPILED decisions that apply now; superseded ones → decisions-archive.md
│   ├── context.md        verified facts (don't re-derive)
│   ├── architecture.md   boxes + diagram
│   ├── roadmap.md        phases / checklist
│   └── log.md            LOG - `## [YYYY-MM-DD] <type> | title`, the history where-we-are drops
└── src/ …             the code
```
Karpathy mapping: `inputs/` = raw · `docs/*` = wiki pages · `CLAUDE.md` = schema + index · `docs/log.md` + git log = log · session end = small ingest · monthly = lint.

## The two rules that make it a wiki
1. **Compile, don't append.** `where-we-are.md` is replaced, not extended. The previous state goes into `docs/log.md` as 2-3 lines. Otherwise it grows to tens of KB and costs context every session.
2. **Current vs. history.** `decisions.md` holds what applies now; replaced decisions move to `decisions-archive.md` with a pointer.

## Session end (say "wrap up")
1. Overwrite `docs/where-we-are.md` with the current state (one page).
2. Append 2-3 lines to `docs/log.md`.
3. New/changed decision → `docs/decisions.md` (move the old one to the archive).
4. New pitfall → `CLAUDE.md` → Pitfalls.

## Context budget
- Root `CLAUDE.md` < 200 lines. Only `@docs/where-we-are.md` is imported; everything else is listed as a path and read on demand.
- Deterministic checks (lint, typecheck, secret scan, tests) belong in hooks/CI, not in prose rules.
- With Matt Pocock's skills: run `/setup-matt-pocock-skills` once per project.

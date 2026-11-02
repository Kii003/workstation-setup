---
updated: 2026-11-02
sources: [Andrej Karpathy, "LLM Wiki" gist (2026)]
tags: [knowledge-management, workflow, claude-code]
---

# LLM Wiki pattern (Karpathy)

**Core:** instead of re-searching raw documents on every question (RAG), the LLM builds and maintains a **persistent, interlinked markdown wiki**. Knowledge is compiled once and grows with every source and every question.

**Roles:** you curate sources, ask questions, think. The LLM does the bookkeeping: summarising, linking, filing, flagging contradictions.

## Layers
| Layer | Karpathy | In this workspace |
|---|---|---|
| Raw sources (immutable) | `raw/` | `01-inbox/` |
| Wiki (LLM writes) | markdown pages | `02-roadmap/` … `06-setup/` |
| Schema (rules) | `CLAUDE.md` / `AGENTS.md` | `CLAUDE.md` |
| Index | `index.md` | `00-dashboard.md` |
| Log | `log.md` | `log.md` |

## Operations
- **Ingest:** read source → discuss takeaways → create/extend pages → dashboard + log. One source can touch many pages; one at a time, supervised, beats batches.
- **Query:** dashboard → relevant pages → answer with references. **File good answers back** so they don't vanish into chat history.
- **Lint:** contradictions, stale claims, orphan pages, missing pages for often-mentioned concepts, missing links.

## Tips
- Consistent log prefix `## [YYYY-MM-DD] type | Title` → `grep "^## \[" log.md | tail -5`.
- An index is enough up to ~100 sources; beyond that add local search.
- YAML frontmatter (`updated`, `sources`, `tags`) makes pages queryable (Obsidian Dataview) and staleness easy to lint.
- Put it in git: version history for free.

## Why it works
Wikis die because maintenance grows faster than value. LLMs don't get bored or forget a cross-reference, so maintenance costs almost nothing.

## Three scales in this workspace
| Karpathy | Knowledge base | Each project (mini wiki) | Whole workspace |
|---|---|---|---|
| Raw sources | `01-inbox/` | `inputs/` | - |
| Wiki pages | `02`-`06` | `docs/*` | world `CLAUDE.md` files |
| Schema | `CLAUDE.md` | project `CLAUDE.md` | `~/.claude/CLAUDE.md` + router |
| Index | `00-dashboard.md` | doc list in project `CLAUDE.md` | router `CLAUDE.md` |
| Log | `log.md` | `docs/log.md` + git log | - |
| Lint | on request | at session end | monthly |

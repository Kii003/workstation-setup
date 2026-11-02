# ai-digest

## What this is
Weekly digest of AI changes, filed into the knowledge-base inbox (`../../../00_Knowledge-Base/01-inbox/`). Part of the freshness loop (`00_Knowledge-Base/06-setup/freshness-loop.md`): sources → digest → "ingest" → wiki → templates/rules.
Two tracks: **mechanics** (B: should I work differently?) and **news** (A: what happened?).

## Stack
Headless Claude Code (`claude -p`) with read-only tools (WebSearch, WebFetch, Read). Shell runner + OS scheduler. No dependencies.

## Commands
- Run now: `./run.sh [mechanics|news|all]` (Windows: `.\run.ps1`)
- Schedule weekly: `./install-weekly.sh` (Windows: `.\install-weekly.ps1`); remove with `remove` / `-Remove`
- Sources: edit `sources.yaml` · output format: `prompts/*.md`

## Hard limits
- The digest only proposes. Nothing is applied automatically; proposals become tasks after "ingest" verified them.
- Read-only tools in headless mode - never add Write/Edit/Bash to the runner.
- One file per track per day; an existing file is never overwritten.

## Pitfalls
- A first run is not trustworthy by default: verify each claim against its primary source during "ingest" (the prompt demands it, but check).
- The scheduler only runs when the machine is on; it catches up at next wake/boot.
- Headless runs need a signed-in Claude Code; if runs fail, see `state/last-error-*.log`.

## Docs (read on demand)
- `docs/decisions.md` · `docs/log.md`

## Current state
@docs/where-we-are.md

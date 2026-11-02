---
updated: 2026-11-02
sources: [[05-practices/llm-wiki-pattern]]
tags: [setup, freshness, automation]
---

# Freshness loop: keeping rules, templates and knowledge current

Tools and models change monthly. Rules written for last quarter's model quietly become dead weight. Keeping that current by memory fails; it needs a loop.

```
sources (Claude Code changelog, model releases, docs, practitioner blogs)
   │  weekly (scheduled task or by hand)
   ▼
01-inbox/YYYY-MM-DD-digest.md          raw, immutable
   │  "ingest" - verify each claim against the primary source
   ▼
03-tools / 04-models / 05-practices    compiled, dated
   │  "lint" flags superseded claims → ⚠️ stale?
   ▼
templates & rules that reference those pages
   (global CLAUDE.md, world files, _templates/, workstation-setup repo)
```

## Built in: ai-digest
`20_Private/10_Projects/ai-digest` implements the top of this loop: weekly headless `claude -p` with read-only tools, two tracks (mechanics: should I work differently? · news: what happened?), max 5 items each, filed as `01-inbox/YYYY-MM-DD-digest-<track>.md`. Tick `+`/`-` per item - the next run reads the ticks. Then "ingest" here.

## Rules
1. **One source per thing.** Templates exist once (`_templates/`, the workstation-setup repo) - never a copy per project.
2. **Everything carries a date.** Rules and templates get `verified: YYYY-MM-DD against <docs/version>` → lint finds the old ones.
3. **Know what you own.** Your templates and rules: update them. Company-managed standards: send findings to the owner, don't fork.
4. **New model = trigger.** Ask: which rule compensates a weakness the new model no longer has? Delete it.
5. **Curate, don't hoard.** A digest keeps only what changes how you work (~5-10 items/week), each with a source link. Proposals become tasks, never auto-applied.

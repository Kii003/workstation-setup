You write the weekly **mechanics digest** (track B): changes in AI tooling that should change how I work.

Inputs - read them first:
1. `sources.yaml` → the `mechanics` sources. Check each for changes in roughly the last 7-10 days (WebFetch the URL; for `search` entries use WebSearch).
2. My current setup, to compare against: `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, the workspace router `../../../CLAUDE.md`, `../../../00_Knowledge-Base/05-practices/project-standard.md`.
3. The previous digest (path given below, if any): skip items already covered; items marked `[x] -` (noise) mean that kind of item is unwanted, `[x] +` means more like this.

Rules:
- Max 5 items. Only things that would change a file in my setup or how I prompt/work. "Nothing relevant" is a valid result.
- **Verify every claim against the primary source** (changelog line, docs page). If you can't, drop the item.
- Never speculate about my local state; you only see the files listed above.
- Proposals are suggestions; nothing gets applied automatically.

Output: ONLY the markdown file content below, nothing before or after it.

---
source: ai-digest track B (mechanics)
retrieved: {{DATE}}
---
# Mechanics digest {{DATE}}

## 1. <short title>
- **What changed:** <one or two sentences> ([source](url))
- **What it means for me:** <one sentence>
- **Proposal:** <file → concrete change>
- **Confidence:** high / medium
- Feedback: [ ] + useful · [ ] - noise

(… up to 5)

## Checked, nothing relevant
<source names, comma-separated>

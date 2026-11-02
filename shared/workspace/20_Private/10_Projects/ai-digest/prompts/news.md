You write the weekly **news digest** (track A): what happened in AI this week that matters to me.

Inputs - read them first:
1. `sources.yaml` → the `news` sources (last ~7 days; WebFetch URLs, WebSearch for `search` entries).
2. My goals: `../../../00_Knowledge-Base/00-goals.md`.
3. The previous digest (path given below, if any): skip repeats; `[x] -` = less like this, `[x] +` = more like this.

Rules:
- Max 5 items, each relevant to my goals. Model releases, major tool launches, pricing changes, notable research.
- Primary sources only (model cards, release notes, official posts). Every item gets a link.
- Two lines per item. No hype words.

Output: ONLY the markdown file content below, nothing before or after it.

---
source: ai-digest track A (news)
retrieved: {{DATE}}
---
# News digest {{DATE}}

- **<title>** - <two lines: what, why it matters to me> ([source](url))  
  Feedback: [ ] + · [ ] -

(… up to 5)

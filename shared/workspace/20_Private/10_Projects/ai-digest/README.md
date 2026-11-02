# ai-digest

Weekly AI digest → `00_Knowledge-Base/01-inbox/`. Two tracks:

| | Mechanics (B) | News (A) |
|---|---|---|
| Question | should I work differently? | what happened? |
| Sources | changelogs, docs, engineering blogs, skill/plugin repos | model releases, official announcements |
| Output per item | what changed · what it means for me · concrete proposal · confidence · link | two lines + link |
| Max | 5 items | 5 items |

```bash
./run.sh                 # both tracks now (Windows: .\run.ps1)
./install-weekly.sh      # every Monday 08:00 (Windows: .\install-weekly.ps1)
```
Then in the knowledge base: `kb` → `claude` → **"ingest"**. Tick `+`/`-` on items; the next run reads your ticks and tunes itself.

Requirements: Claude Code signed in. Customize `sources.yaml` and `prompts/`.

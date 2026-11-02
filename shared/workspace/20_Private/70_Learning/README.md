# 70_Learning - teach workspaces

One folder per topic. Each topic folder is its own `/teach` workspace (Matt Pocock's skills plugin).

## Workflow
1. Main session, when something doesn't land: `/handoff learn <topic>` - writes a handoff file and prints its path.
2. `./new-topic.sh <topic>` (once per topic) → `cd <topic> && claude`.
3. `/teach <topic> - context in <handoff path>`. Use `/wait-what` here freely; the main session stays clean.
4. Back in the main session: just continue. Only hand back if the learning changed a decision (then record it in that project's `docs/decisions.md`).

Skills come from the `mattpocock-skills` plugin (user scope, auto-updates) - available in every folder.

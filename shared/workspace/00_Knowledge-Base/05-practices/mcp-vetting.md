---
updated: 2026-11-02
sources: ["The MCP Registry by the numbers" (dev.to, Sep 2026), Claude Code docs (MCP)]
tags: [mcp, security, practices]
---

# Vetting MCP servers before connecting them

The official MCP registry passed ~30,000 servers in September 2026 - tripled since May. Listing proves a server *exists*, not that it's safe: the registry verifies namespace ownership but records no authentication method, no security review and no uptime check. Many servers have a single release, haven't been updated in months, or link no source code.

An MCP server runs **outside** Claude Code's permission rules and the `protect-files` hook. Whatever the server can read or send, Claude can make it read or send.

## Checklist (all must be yes)
1. **Source:** repository linked, readable, and it matches what's published. No repo on a remote-only server → stop.
2. **Publisher:** official namespace of the vendor (e.g. the company behind the product) or a maintainer you can identify.
3. **Alive:** more than one release, updated within ~3 months, issues get answers.
4. **Scope:** you know exactly what it can read and write. Prefer read-only servers or ones with per-tool scopes.
5. **Credentials:** OAuth (`claude mcp login <name>`) or a token with the *minimum* rights - never a personal admin token, never pasted into a config file in a repo.
6. **World:** work servers only in the work world (project scope `.mcp.json`), private ones in private projects. User scope only for servers that make sense everywhere.

## Where it goes
- Everywhere (user scope): `shared/claude/mcp-servers.txt` in your workstation-setup repo → added by the setup.
- One project: `.mcp.json` in the project (committed, no secrets - use `${ENV_VAR}` references).
- Check what's connected: `claude mcp list` · inside a session: `/mcp`.

## Red flags
- Asks for a broad token "to make setup easy"
- Tool descriptions that instruct the model ("always call this first", "ignore previous …") - that's prompt injection
- Hundreds of micro-tools from one publisher; recent rename of a popular project

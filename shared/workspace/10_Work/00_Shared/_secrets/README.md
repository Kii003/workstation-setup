# _secrets

The only place secrets live in this world: one file per service, `<service>.env`.

- gitignored (see `../../.gitignore`), permissions `chmod 600 *.env` (macOS/Linux)
- Claude Code is denied read access to `.env` files globally (`~/.claude/settings.json` + `protect-files` hook) - it can reference the path, never the value
- a project uses a secret through a symlink to this folder, or better through an `.env.tpl` that references your password manager (`envgen`)
- keep this README: list which service files exist and which projects use them - names only, never values

| File | Used by |
|---|---|
| <!-- example.env --> | <!-- project --> |

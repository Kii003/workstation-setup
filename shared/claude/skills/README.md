# Your own Claude Code skills

Each subfolder is one skill and contains a `SKILL.md`. The setup script links each one into `~/.claude/skills/`.

```
skills/
├── my-skill/
│   └── SKILL.md
└── another-skill/
    ├── SKILL.md
    └── reference.md
```

- **Add a skill:** create the folder here, commit, re-run the Claude step (`./setup.sh claude`).
- **Already have skills on a machine?** `macos/scripts/snapshot.sh` copies any non-linked skills from `~/.claude/skills/` into this folder.
- **Third-party skill packs** (e.g. Matt Pocock's) go in `../plugins.txt`, not here — plugins update themselves.
- **Skills in the Claude desktop/web app** belong to your Anthropic account and appear after sign-in; no need to copy them.

Skill format: see the Claude Code docs on skills (`SKILL.md` with `name` and `description` frontmatter).

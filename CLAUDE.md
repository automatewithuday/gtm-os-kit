@AGENTS.md

## Claude Code Only

<!-- Everything agents share lives in AGENTS.md, imported by the line at the
     top. Codex and other agents read AGENTS.md directly. This file is for
     the few things only Claude Code understands. Keep "@AGENTS.md" on its
     own line, with no backticks around it. -->

- A safety hook (`.claude/hooks/safety-guard.sh`) pauses risky tool calls and shows a permission prompt. Never work around it, for example by calling an API from the shell instead of the guarded tool.
- Skills in `gtm-skills/` are linked into `.claude/skills/`. Run one with `/skill-name`.

### Importing Other Files

Pull a file into context at load time with `@path/to/file` on its own line:

```
@company/overview.md
@company/rules.md
```

Imported files load with every session, so import only what every task needs.

### Path-Specific Rules

Use `.claude/rules/` for rules that only apply to certain files or folders. Each rule file scopes itself with a `paths` field in its frontmatter:

```
.claude/rules/
├── outbound-copy.md      # paths: "past-campaigns/**" -- how campaign files are written
└── python-style.md       # paths: "**/*.py" -- coding standards for scripts
```

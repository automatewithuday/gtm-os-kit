# Claude Code Hooks System

Hooks let you run custom scripts at every stage of a Claude Code session. They act as guardrails, loggers, and notifications -- giving you control over what Claude can do and visibility into what it did.

This directory contains three hooks, a self-check for the safety guard, and the `settings.json` that wires them up.

## What's Included

| File | Purpose | Wired To |
|------|---------|----------|
| `safety-guard.sh` | Pauses risky operations until you approve them | PreToolUse |
| `test-safety-guard.sh` | Self-check for the guard. Run after every edit. | (run by hand) |
| `session-logger.sh` | Logs every event to per-session JSONL files | PreToolUse, PostToolUse, PostToolUseFailure, UserPromptSubmit, Stop, PreCompact, SessionEnd |
| `notify.sh` | Sends native OS notifications when Claude needs attention | Stop, PermissionRequest, Notification, SessionStart, SessionEnd, SubagentStop |
| `settings.json` | Wires all hooks to the correct lifecycle events | (config file) |

## Installation

Run these commands from your project's root directory (the folder where `.claude/` lives or will live).

**1. Create directories and copy hooks:**

```bash
mkdir -p .claude/hooks .claude/sessions
cp path/to/gtm-os-kit/blueprint/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

Replace `path/to/gtm-os-kit` with wherever you cloned the kit.

**2. Add the settings file:**

```bash
# If you do not have a .claude/settings.json yet, copy it directly.
# -n refuses to overwrite an existing file.
cp -n path/to/gtm-os-kit/blueprint/hooks/settings.json .claude/settings.json

# If you already have one, manually merge the "hooks" key from
# the kit's settings.json into your existing file.
```

**3. Install jq (required dependency):**

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Verify it's installed
jq --version
```

**4. Exclude session logs from git, and commit the rest:**

```bash
echo ".claude/sessions/" >> .gitignore
```

Session logs can contain anything typed into a tool, so they stay local. Commit `.claude/settings.json` and `.claude/hooks/` so your whole team runs the same guard. If your `.gitignore` ignores all of `.claude/`, narrow it.

**5. Check the guard works:**

```bash
bash .claude/hooks/test-safety-guard.sh
```

It should end with `All checks passed.` Run it again every time you edit the guard.

## How Hooks Work

Claude Code emits lifecycle events as it runs. You attach shell scripts to these events via `settings.json`. The scripts receive a JSON payload on stdin with details about the event.

**Execution flow:**

```
User types prompt
  -> SessionStart (once, at session beginning)
  -> UserPromptSubmit (each prompt)
  -> PreToolUse (before each tool call)
     [your safety-guard.sh runs here]
     allow | ask you to approve | block
  -> Tool executes
  -> PostToolUse (on success) / PostToolUseFailure (on failure)
  -> Stop (Claude finishes responding)
  -> ... (repeat for next prompt)
  -> SessionEnd (when session closes)
```

## Lifecycle Events Reference

| Event | When It Fires | Typical Use |
|-------|---------------|-------------|
| `SessionStart` | Session begins or resumes | Welcome message, load context |
| `UserPromptSubmit` | User sends a prompt | Log prompts, inject context |
| `PreToolUse` | Before every tool call | **Safety guards**, logging |
| `PostToolUse` | After a successful tool call | Logging, metrics |
| `PostToolUseFailure` | After a failed tool call | Error tracking, alerts |
| `Stop` | Claude finishes a response | Notifications, logging |
| `PermissionRequest` | Claude needs user approval | Notifications (urgent) |
| `Notification` | Claude sends a notification | Notifications |
| `SubagentStop` | A sub-agent finishes | Notifications |
| `PreCompact` | Before context compaction | Snapshot session state |
| `SessionEnd` | Session closes | Summary stats, cleanup |

## Hook Input Format

Every hook receives JSON on stdin. The shape varies by event, but always includes:

```json
{
  "hook_event_name": "PreToolUse",
  "session_id": "abc-123-def",
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push --force"
  }
}
```

Common fields:
- `hook_event_name` -- which lifecycle event triggered this hook
- `session_id` -- unique ID for the current session
- `tool_name` -- the tool being called (PreToolUse, PostToolUse, PostToolUseFailure only)
- `tool_input` -- the arguments passed to the tool (PreToolUse only)
- `error` -- error message (PostToolUseFailure only)
- `cwd` -- the directory the session is working in
- `prompt` -- the user's prompt text (UserPromptSubmit only)

## settings.json Structure

The hooks configuration lives under the `"hooks"` key in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PROJECT_DIR}\"/.claude/hooks/safety-guard.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

Key options:
- `matcher` -- which tools this hook applies to. Use `"*"` for all tools, or a pipe-separated list like `"Bash|Write|Edit"` for specific tools.
- `type` -- always `"command"` (runs a shell script).
- `command` -- path to your script. Start it with `"${CLAUDE_PROJECT_DIR}"` so it still resolves after Claude changes directory. A bare relative path stops working the moment Claude runs `cd`, and a guard that cannot be found does not guard anything.
- `timeout` -- max seconds before the hook is killed (optional, prevents hangs).

## Customizing the Safety Guard

The safety guard is the most important hook to customize.

**What it does on a match:** it does not silently refuse. Claude Code shows you a permission prompt with the reason, and the call runs only if you approve. In a headless run (`claude -p`) nobody can answer, so the call is denied. If the guard itself cannot run (no `jq`, unreadable input) it blocks the call outright.

**How it matches MCP tools:** tool names look like `mcp__<server>__<action>`, and the server part differs between setups. So the guard checks the action against `BLOCKED_PATTERNS` (send, reply, delete, activate a campaign, create an invoice, and so on) whatever the server is called. Open `safety-guard.sh` and:

- Add a tool the patterns miss to `BLOCKED_TOOLS`:

```bash
BLOCKED_TOOLS=(
  "mcp__your_server__dangerous_tool"
)
```

- Let a tool through that a pattern catches by adding it to `ALLOWED_TOOLS`.
- Add a whole class of actions to `BLOCKED_PATTERNS` as `"Category::regex"`.

**Add bash patterns:**
Find the "DANGEROUS BASH PATTERNS" section and add `grep` checks:

```bash
# Ask before deploying to production
if echo "$CMD" | grep -qE '\bnpm\s+run\s+deploy:prod\b'; then
  ask "Production deployment. Command: $CMD"
fi
```

**Guard direct API calls:** add the API hosts of your sequencer, CRM and chat tools to `GUARDED_API_HOSTS`, so a write sent with `curl` gets the same prompt as the MCP tool would.

**Then add a case to `test-safety-guard.sh` and run it.** The bash checks are pattern matches, not a shell parser. They catch the common forms, not every possible spelling, so also keep the credentials your agent holds scoped to what it should be able to do.

**Find your tool names:**
Ask Claude Code: "List all available MCP tools" or check your MCP server documentation.

## Adding Your Own Hooks

Create a new script, make it executable, and wire it in `settings.json`.

**Example: Log all file writes to a separate audit file**

```bash
#!/bin/bash
# .claude/hooks/audit-writes.sh
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)

if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // ""' 2>/dev/null)
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $TOOL $FILE" >> .claude/audit.log
fi
exit 0
```

Wire it:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/audit-writes.sh"
        }
      ]
    }
  ]
}
```

## Session Logs

The session logger writes JSONL files to `.claude/sessions/`. Each session gets its own file.

**View a session's activity:**

```bash
# List recent sessions
ls -lt .claude/sessions/ | head

# Pretty-print a session transcript
cat .claude/sessions/<session_id>.jsonl | jq .

# See all tools used in a session
grep '"tool_start"' .claude/sessions/<session_id>.jsonl | jq -r '.tool'

# Count tool usage across sessions
cat .claude/sessions/*.jsonl | grep '"tool_start"' | jq -r '.tool' | sort | uniq -c | sort -rn

# Find all failed tool calls
grep '"tool_fail"' .claude/sessions/*.jsonl | jq '{tool: .tool, error: .error}'
```

## Troubleshooting

**Hook isn't running:**
- Check that the script is executable: `chmod +x .claude/hooks/your-hook.sh`
- Verify the path in `settings.json` starts with `"${CLAUDE_PROJECT_DIR}"/.claude/hooks/`
- Make sure `jq` is installed: `which jq`

**Every tool call is blocked:**
- The guard fails closed. If `jq` is missing it blocks everything and says so. Install `jq`.

**The guard prompts for something harmless:**
- A pattern in `BLOCKED_PATTERNS` matched the tool's action name. Add the exact tool name to `ALLOWED_TOOLS`.

**The guard does not prompt for something risky:**
- Add the tool to `BLOCKED_TOOLS` or its API host to `GUARDED_API_HOSTS`, add a test case, and run `test-safety-guard.sh`.

**Notifications not showing:**
- macOS: Check System Preferences > Notifications > Script Editor
- Linux: Make sure `notify-send` is installed
- Check that `osascript` or `notify-send` is available: `which osascript`

**Session logs are too large:**
- Add `.claude/sessions/` to `.gitignore`
- Periodically clean old sessions: `find .claude/sessions -mtime +30 -delete`

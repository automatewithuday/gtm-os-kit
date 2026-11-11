#!/bin/bash

# =============================================================================
# Safety Guard - PreToolUse Hook for Claude Code
# =============================================================================
#
# Stops risky operations until a human approves them. Claude Code calls this
# hook before every tool use. The script reads the tool call from stdin (JSON)
# and checks it against the lists below.
#
# What happens on a match:
#   Claude Code shows YOU a permission prompt with the reason. Approve it and
#   the call runs; decline and it does not. Claude cannot approve it for you.
#   In headless runs (claude -p) nobody can answer, so the call is denied.
#
# What happens if the guard itself cannot run (jq missing, unreadable input):
#   The tool call is blocked. A guard that cannot inspect a call never waves
#   it through.
#
# Install: wire this script to PreToolUse in .claude/settings.json
# Customize: edit ALLOWED_TOOLS, BLOCKED_TOOLS, BLOCKED_PATTERNS and
#            GUARDED_API_HOSTS to match your stack
# Test:      bash test-safety-guard.sh
# =============================================================================

# Block outright. Used only when the guard cannot do its job.
fail_closed() {
  echo "SAFETY GUARD: $1" >&2
  exit 2
}

command -v jq >/dev/null 2>&1 || fail_closed "jq is not installed, so tool calls cannot be inspected. Install it (brew install jq / apt install jq), then retry."

INPUT=$(cat)
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null) || fail_closed "could not parse the hook input."
[ -n "$TOOL_NAME" ] || fail_closed "the hook input has no tool_name."
TOOL_INPUT=$(printf '%s' "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null)

# Hand the decision to the human: Claude Code shows a permission prompt.
ask() {
  jq -n --arg reason "SAFETY GUARD - $1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
  exit 0
}

# =============================================================================
# ALLOWED MCP TOOLS
# =============================================================================
# Exact tool names that skip the checks below. Use this when a pattern catches
# a tool you are happy to let run without a prompt.
# =============================================================================

ALLOWED_TOOLS=(
  # "mcp__your_server__send_internal_test"
)

# =============================================================================
# BLOCKED MCP TOOLS (exact names)
# =============================================================================
# Tool names that always need approval. Format: "mcp__<server>__<tool_name>"
#
# Server names differ between setups (a Gmail connector added through
# claude.ai is not called "gmail"), so the patterns in the next section catch
# the common cases whatever the server is called. Use this list for tools the
# patterns miss. Ask Claude "list all available MCP tools" to see your names.
# =============================================================================

BLOCKED_TOOLS=(

  # ---------------------------------------------------------------------------
  # 1. EMAIL & MESSAGING
  # ---------------------------------------------------------------------------
  "mcp__gmail__create_draft"            # drafts can auto-send via rules
  # "mcp__teams__send_message"
  # "mcp__discord__send_message"

  # ---------------------------------------------------------------------------
  # 2. OUTBOUND CAMPAIGNS (activating sends real outreach to strangers)
  # ---------------------------------------------------------------------------
  # "mcp__<outbound_tool>__pause_campaign"
  # "mcp__<outbound_tool>__add_leads_to_campaign"

  # ---------------------------------------------------------------------------
  # 3. FINANCIAL OPERATIONS
  # ---------------------------------------------------------------------------
  "mcp__stripe__stripe_api_execute"     # raw API = anything goes

  # ---------------------------------------------------------------------------
  # 4. BULK DATA OPERATIONS (mass changes that are hard to undo)
  # ---------------------------------------------------------------------------
  # "mcp__hubspot__bulk_create"
  # "mcp__salesforce__bulk_upsert"
  # "mcp__<crm>__bulk_add_contacts"

  # ---------------------------------------------------------------------------
  # 5. DATABASE ADMIN / INFRASTRUCTURE
  # ---------------------------------------------------------------------------
  "mcp__supabase__deploy_edge_function"
  "mcp__supabase__create_project"
  "mcp__supabase__pause_project"
  # "mcp__postgres__execute_query"
  # "mcp__vercel__deploy_project"
  # "mcp__terraform__apply"
)

# =============================================================================
# BLOCKED MCP PATTERNS
# =============================================================================
# Checked against the action part of every MCP tool name (the text after the
# last "__", lowercased), so they work for any server name.
# Format: "Category::extended-regex"
# =============================================================================

BLOCKED_PATTERNS=(
  "External messaging::(^|_)(send|reply|post_message|schedule_message)(_|$)"
  "Campaign launch::(activate|launch|resume|start)_[a-z_]*campaign|campaign[a-z_]*_(activate|launch|resume|start)"
  "Financial operation::(create|finalize|void|pay|issue|update|cancel)_[a-z_]*(invoice|refund|payment_link|payout|charge|subscription)"
  "Destructive delete::(^|_)(delete|trash|purge|destroy)(_|$)"
  "Database operation::(execute|run)_sql|apply_migration"
  "GitHub mutation::push_files|merge_pull_request|create_or_update_file"
  "Calendar mutation::(create|update|delete|respond_to)_event"
)

if [[ "$TOOL_NAME" == mcp__* ]]; then
  for allowed in "${ALLOWED_TOOLS[@]}"; do
    [ "$TOOL_NAME" = "$allowed" ] && exit 0
  done

  DETAILS=$(printf '%s' "$TOOL_INPUT" | head -c 300)

  for blocked in "${BLOCKED_TOOLS[@]}"; do
    [ "$TOOL_NAME" = "$blocked" ] && ask "Listed tool: $TOOL_NAME. Input: $DETAILS"
  done

  ACTION=$(printf '%s' "${TOOL_NAME##*__}" | tr '[:upper:]' '[:lower:]')
  for entry in "${BLOCKED_PATTERNS[@]}"; do
    if printf '%s' "$ACTION" | grep -qE "${entry#*::}"; then
      ask "${entry%%::*}: $TOOL_NAME. Input: $DETAILS"
    fi
  done
fi

# =============================================================================
# DANGEROUS BASH PATTERNS
# =============================================================================
# ponytail: regex heuristics, not a shell parser. They catch the common forms;
# a determined command can be written to slip past. Treat this as a seatbelt
# and keep real credentials scoped to what the agent should be able to do.
# =============================================================================

if [ "$TOOL_NAME" = "Bash" ]; then
  CMD=$(printf '%s' "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null)
  CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // "."' 2>/dev/null)

  if echo "$CMD" | grep -qE '\bgit\s+push\b'; then
    # git push --force / -f (rewrites remote history)
    if echo "$CMD" | grep -qE '\bgit\s+push\s+.*(-f|--force)\b'; then
      ask "git push --force rewrites remote history. Command: $CMD"
    fi

    # git push naming main/master ("origin main", "HEAD:main")
    if echo "$CMD" | grep -qE '\bgit\s+push\b.*[[:space:]:+](main|master)([[:space:];&|]|$)'; then
      ask "git push to main/master bypasses review. Command: $CMD"
    fi

    # git push with no branch named, while main/master is checked out
    PUSH_ARGS=$(echo "$CMD" | grep -oE '\bgit\s+push\b[^;&|]*' | head -1 | sed -E 's/^git[[:space:]]+push//')
    COUNT=0; REF=""
    for word in $PUSH_ARGS; do
      case "$word" in
        -*) ;;
        *) COUNT=$((COUNT + 1)); [ "$COUNT" -eq 2 ] && REF=$word ;;
      esac
    done
    if [ "$COUNT" -le 1 ] || [ "$REF" = "HEAD" ]; then
      BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        ask "git push while on $BRANCH bypasses review. Command: $CMD"
      fi
    fi
  fi

  # gh pr merge (merging without a human looking)
  if echo "$CMD" | grep -qE '\bgh\s+pr\s+merge\b'; then
    ask "gh pr merge. Command: $CMD"
  fi

  # git reset --hard (destroys uncommitted work)
  if echo "$CMD" | grep -qE '\bgit\s+reset\s+--hard\b'; then
    ask "git reset --hard discards uncommitted changes. Command: $CMD"
  fi

  # rm with both a recursive and a force flag, in any spelling (-rf, -fr, -Rf, -r -f)
  RM=$(echo "$CMD" | grep -oE '(^|[;&|[:space:]])rm[[:space:]][^;&|]*')
  if echo "$RM" | grep -qE '[[:space:]](-[a-zA-Z]*[rR]|--recursive)' && echo "$RM" | grep -qE '[[:space:]](-[a-zA-Z]*f|--force)'; then
    ask "Recursive force-delete is irreversible. Command: $CMD"
  fi

  # DROP TABLE/DATABASE/SCHEMA, TRUNCATE TABLE
  if echo "$CMD" | grep -qiE '\b(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE)\b'; then
    ask "Destructive SQL (DROP/TRUNCATE). Command: $CMD"
  fi

  # curl/wget piped to shell (remote code execution)
  if echo "$CMD" | grep -qE '(curl|wget)\s.*\|\s*(ba|z)?sh'; then
    ask "Piping remote content to a shell. Command: $CMD"
  fi

  # chmod 777 (world-writable permissions)
  if echo "$CMD" | grep -qE '\bchmod\s+(-R\s+)?777\b'; then
    ask "chmod 777 makes files world-writable. Command: $CMD"
  fi

  # Deleting .env or credentials files
  if echo "$CMD" | grep -qE '\brm\s.*\.(env|pem|key|credentials|secret)'; then
    ask "Deleting a file that may hold secrets. Command: $CMD"
  fi

  # ---------------------------------------------------------------------------
  # Direct API writes to tools that send, post or charge
  # ---------------------------------------------------------------------------
  # Stops the guard being sidestepped by calling the API from the shell instead
  # of the MCP tool. Add the API hosts of your sequencer, CRM and chat tools.
  # Some of these APIs use POST for searches too; those will prompt as well.
  # ---------------------------------------------------------------------------
  GUARDED_API_HOSTS='api\.instantly\.ai|server\.smartlead\.ai|api\.heyreach\.io|api\.lemlist\.com|slack\.com/api|gmail\.googleapis\.com|api\.stripe\.com'
  if echo "$CMD" | grep -qE '\b(curl|wget|http|https)\b' \
    && echo "$CMD" | grep -qE "$GUARDED_API_HOSTS" \
    && echo "$CMD" | grep -qE -- '-X\s*(POST|PUT|PATCH|DELETE)|--request|(^|\s)(-d|--data[a-z-]*|--json|-F|--form|--post-data|--method)\b|\b(POST|PUT|PATCH|DELETE)\s'; then
    ask "Direct API write to a guarded service. Command: $CMD"
  fi
fi

# =============================================================================
# All clear -- allow the tool call
# =============================================================================
exit 0

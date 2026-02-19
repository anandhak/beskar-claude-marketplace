#!/bin/bash
# Kadlekai Activity Tracker
# Captures significant Claude Code activity for time tracking reconciliation

# Configuration
ACTIVITY_DIR="${KADLEKAI_ACTIVITY_DIR:-$HOME/.kadlekai}"
ACTIVITY_FILE="$ACTIVITY_DIR/activity.jsonl"
MAX_PROMPT_LENGTH=200

# Ensure directory exists
mkdir -p "$ACTIVITY_DIR"

# Read JSON input from stdin
INPUT=$(cat)

# Extract fields using jq
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# For significant tools only - skip reads, searches, globs
case "$TOOL_NAME" in
    Read|Grep|Glob|WebSearch|ListMcpResourcesTool|ReadMcpResourceTool|TodoWrite|AskUserQuestion|BashOutput)
        # Skip non-significant tools
        exit 0
        ;;
esac

# Extract tool-specific context
case "$TOOL_NAME" in
    Write|Edit|MultiEdit|NotebookEdit)
        FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
        CONTEXT="file:$FILE_PATH"
        ;;
    Bash)
        COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | head -c 100)
        DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // empty')
        CONTEXT="bash:${DESCRIPTION:-$COMMAND}"
        ;;
    Task)
        DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // empty')
        SUBAGENT=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty')
        CONTEXT="task:$SUBAGENT - $DESCRIPTION"
        ;;
    WebFetch)
        URL=$(echo "$INPUT" | jq -r '.tool_input.url // empty')
        CONTEXT="web:$URL"
        ;;
    mcp__*)
        # MCP tool calls - extract tool name and key params
        CONTEXT="mcp:$TOOL_NAME"
        ;;
    *)
        # For unknown tools, just log the tool name
        CONTEXT="tool:$TOOL_NAME"
        ;;
esac

# Extract project name from cwd (last directory component)
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# Create activity log entry
ENTRY=$(jq -cn \
    --arg ts "$TIMESTAMP" \
    --arg event "$HOOK_EVENT" \
    --arg session "$SESSION_ID" \
    --arg project_dir "$CWD" \
    --arg project "$PROJECT_NAME" \
    --arg tool "$TOOL_NAME" \
    --arg context "$CONTEXT" \
    '{ts:$ts,event:$event,session_id:$session,project_dir:$project_dir,project:$project,tool:$tool,context:$context}')

# Append to activity log
echo "$ENTRY" >> "$ACTIVITY_FILE"

# Exit successfully (don't block tool execution)
exit 0

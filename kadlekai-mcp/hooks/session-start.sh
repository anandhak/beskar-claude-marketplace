#!/bin/bash
# Kadlekai Session Start Hook
# Logs session start, checks for updates, and displays reminder

# Configuration
ACTIVITY_DIR="${KADLEKAI_ACTIVITY_DIR:-$HOME/.kadlekai}"
ACTIVITY_FILE="$ACTIVITY_DIR/activity.jsonl"
LATEST_VERSION_URL="https://beskar-kadlekai-mcp.s3.amazonaws.com/latest-version.txt"

# Current installed version (updated on plugin install)
CURRENT_VERSION="1.0.15"

# Ensure directory exists
mkdir -p "$ACTIVITY_DIR"

# Read JSON input from stdin
INPUT=$(cat)

# Extract fields
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# Log session start
ENTRY=$(jq -cn \
    --arg ts "$TIMESTAMP" \
    --arg event "SessionStart" \
    --arg session "$SESSION_ID" \
    --arg project_dir "$CWD" \
    --arg project "$PROJECT_NAME" \
    --arg tool "" \
    --arg context "session_start" \
    '{ts:$ts,event:$event,session_id:$session,project_dir:$project_dir,project:$project,tool:$tool,context:$context}')

echo "$ENTRY" >> "$ACTIVITY_FILE"

# Check for plugin updates (with short timeout)
LATEST_VERSION=$(curl -s --connect-timeout 1 --max-time 2 "$LATEST_VERSION_URL" 2>/dev/null | tr -d '[:space:]')

# Build output message
if [ -n "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
    OUTPUT_MESSAGE="🆕 Kadlekai update available: $CURRENT_VERSION → $LATEST_VERSION. Run /time:plugin-update
⏱️ Activity tracking enabled. Use /time:reconcile at end of day."
else
    OUTPUT_MESSAGE="⏱️ Kadlekai (v$CURRENT_VERSION): Activity tracking enabled. Use /time:reconcile at end of day."
fi

# Return JSON output for Claude Code to display
jq -n --arg msg "$OUTPUT_MESSAGE" '{
    "systemMessage": $msg,
    "suppressOutput": false,
    "continue": true
}'

exit 0

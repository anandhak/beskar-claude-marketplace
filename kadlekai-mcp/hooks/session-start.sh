#!/bin/bash
# Kadlekai Session Start Hook
# Logs session start and displays reminder

# Configuration
ACTIVITY_DIR="${KADLEKAI_ACTIVITY_DIR:-$HOME/.kadlekai}"
ACTIVITY_FILE="$ACTIVITY_DIR/activity.jsonl"

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
ENTRY=$(jq -n \
    --arg ts "$TIMESTAMP" \
    --arg event "SessionStart" \
    --arg session "$SESSION_ID" \
    --arg project_dir "$CWD" \
    --arg project "$PROJECT_NAME" \
    --arg tool "" \
    --arg context "session_start" \
    '{
        ts: $ts,
        event: $event,
        session_id: $session,
        project_dir: $project_dir,
        project: $project,
        tool: $tool,
        context: $context
    }')

echo "$ENTRY" >> "$ACTIVITY_FILE"

# Display reminder with activity tracking info
echo "⏱️ Kadlekai: Activity tracking enabled. Use /time:reconcile at end of day."

exit 0

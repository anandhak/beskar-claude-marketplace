#!/bin/bash
# Kadlekai Session End Hook
# Logs session end with duration summary

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

# Count activities in this session
ACTIVITY_COUNT=$(grep -c "\"session_id\":\"$SESSION_ID\"" "$ACTIVITY_FILE" 2>/dev/null || echo "0")

# Log session end
ENTRY=$(jq -cn \
    --arg ts "$TIMESTAMP" \
    --arg event "SessionEnd" \
    --arg session "$SESSION_ID" \
    --arg project_dir "$CWD" \
    --arg project "$PROJECT_NAME" \
    --arg tool "" \
    --arg context "session_end:activities=$ACTIVITY_COUNT" \
    '{ts:$ts,event:$event,session_id:$session,project_dir:$project_dir,project:$project,tool:$tool,context:$context}')

echo "$ENTRY" >> "$ACTIVITY_FILE"

exit 0

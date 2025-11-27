#!/bin/bash
# Kadlekai User Prompt Tracker
# Captures user prompts for context in time entries

# Configuration
ACTIVITY_DIR="${KADLEKAI_ACTIVITY_DIR:-$HOME/.kadlekai}"
ACTIVITY_FILE="$ACTIVITY_DIR/activity.jsonl"
MAX_PROMPT_LENGTH=200

# Ensure directory exists
mkdir -p "$ACTIVITY_DIR"

# Read JSON input from stdin
INPUT=$(cat)

# Extract fields
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# Extract prompt (truncate to max length)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | head -c $MAX_PROMPT_LENGTH | tr '\n' ' ')

# Skip empty prompts
if [ -z "$PROMPT" ]; then
    exit 0
fi

# Log user prompt
ENTRY=$(jq -n \
    --arg ts "$TIMESTAMP" \
    --arg event "UserPrompt" \
    --arg session "$SESSION_ID" \
    --arg project_dir "$CWD" \
    --arg project "$PROJECT_NAME" \
    --arg tool "" \
    --arg context "prompt:$PROMPT" \
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

exit 0

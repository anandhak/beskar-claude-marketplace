#!/bin/bash
# Kadlekai Session Start Hook
# Logs session start, checks for updates, and displays reminder

# Configuration
ACTIVITY_DIR="${KADLEKAI_ACTIVITY_DIR:-$HOME/.kadlekai}"
ACTIVITY_FILE="$ACTIVITY_DIR/activity.jsonl"
VERSION_FILE="$ACTIVITY_DIR/installed_version"
LATEST_VERSION_URL="https://beskar-kadlekai-mcp.s3.amazonaws.com/latest-version.txt"

# Current installed version (updated on plugin install)
CURRENT_VERSION="1.0.5"

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

# Check for plugin updates (background, non-blocking, with timeout)
check_for_updates() {
    LATEST_VERSION=$(curl -s --connect-timeout 2 --max-time 3 "$LATEST_VERSION_URL" 2>/dev/null | tr -d '[:space:]')

    if [ -n "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
        echo "🆕 Kadlekai plugin update available: $CURRENT_VERSION → $LATEST_VERSION. Run /time:plugin-update"
    fi
}

# Run update check (silently fail if network unavailable)
check_for_updates 2>/dev/null &

# Display reminder with activity tracking info
echo "⏱️ Kadlekai: Activity tracking enabled. Use /time:reconcile at end of day."

exit 0

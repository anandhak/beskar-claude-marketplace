---
description: View raw activity log for debugging
argument-hint: [date - defaults to today]
---

# View Activity Log

Show activity log for: $ARGUMENTS (defaults to today)

## Instructions:

### Step 1: Read Activity Log

Read the activity log file at `~/.kadlekai/activity.jsonl` using the Read tool.

If the file doesn't exist or is empty:
- "No activity recorded yet."
- "Activity tracking is enabled via hooks. Activities are captured when you use significant tools (Edit, Write, Bash, etc.)."

### Step 2: Parse and Filter

1. Parse the date argument:
   - Empty or "today" → current date
   - "yesterday" → previous day
   - "all" → show all entries (last 100)
   - Specific date like "2025-11-27" → that date

2. Parse each line as JSON and filter by date

### Step 3: Display Activities

Show a chronological list:

```
## Activity Log for [DATE]

| Time | Event | Project | Tool | Context |
|------|-------|---------|------|---------|
| 09:15 | SessionStart | my-project | - | session_start |
| 09:16 | UserPrompt | my-project | - | prompt: Fix the auth bug... |
| 09:17 | PreToolUse | my-project | Edit | file: src/auth/handler.ts |
| 09:20 | PreToolUse | my-project | Bash | bash: Run tests |
| 09:45 | UserPrompt | my-project | - | prompt: Now add the... |
...

Total: [N] activities
Sessions: [M]
```

### Step 4: Summary Stats

```
## Summary

- Total activities: 45
- Sessions: 2
- Projects: my-project (40), other-project (5)
- Tools used:
  - Edit: 15
  - Write: 3
  - Bash: 8
  - Task: 2
- User prompts: 12
```

## Notes:

- Activity log location: ~/.kadlekai/activity.jsonl
- Each line is a JSON object with: ts, event, session_id, project_dir, project, tool, context
- Use `/time:reconcile` to convert activity into time entries

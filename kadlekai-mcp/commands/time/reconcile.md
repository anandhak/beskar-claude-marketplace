---
description: Reconcile Claude Code activity into time entries
argument-hint: [date - defaults to today]
---

# Reconcile Activity to Time Entries

Reconcile Claude Code activity for: $ARGUMENTS (defaults to today)

## Instructions:

### Step 1: Read Activity Log

Read the activity log file at `~/.kadlekai/activity.jsonl` using the Read tool.

If the file doesn't exist or is empty, inform the user:
- "No activity recorded yet. Activity tracking starts when you use Claude Code with the Kadlekai plugin installed."
- "Use `/time:log` to manually log time, or continue working and run `/time:reconcile` later."

### Step 2: Filter Activities for Target Date

1. Parse the date argument:
   - Empty or "today" → current date
   - "yesterday" → previous day
   - Specific date like "2025-11-27" → that date

2. Filter the JSONL entries to only include activities from the target date
   - Match entries where `ts` starts with the target date (YYYY-MM-DD)

### Step 3: Analyze Activity Sessions

Group activities into work sessions:

1. **Identify session boundaries**:
   - Use SessionStart/SessionEnd events as primary boundaries
   - If no explicit boundaries, use gaps > 30 minutes between activities

2. **For each session, extract**:
   - Start time (first activity timestamp)
   - End time (last activity timestamp or SessionEnd)
   - Project directory/name
   - List of user prompts (from UserPrompt events) - these describe what was worked on
   - Tools used (Edit, Write, Bash, etc.)
   - Files modified

3. **Calculate session duration**:
   - Duration = end_time - start_time
   - Round to nearest 5 minutes

### Step 4: Present Activity Summary

Display a summary table:

```
## Activity Summary for [DATE]

### Session 1: [PROJECT_NAME]
- Time: 09:15 - 11:45 (2h 30m)
- Activities:
  - "Fix the auth bug in handler" (user prompt)
  - "Add tests for auth module" (user prompt)
- Files: src/auth/handler.ts, src/auth/handler.test.ts
- Tools: Edit (5), Bash (3)

### Session 2: [PROJECT_NAME]
- Time: 14:00 - 16:30 (2h 30m)
- Activities:
  - "Implement user profile API"
- Files: src/api/profile.ts
- Tools: Write (2), Edit (8)

---
Total: 5h 0m across 2 sessions
```

### Step 5: Get Existing Worklogs

Call `mcp__kadlekai__list_worklogs` with the target date to see what's already logged.

Compare with detected sessions to identify:
- Sessions already logged (match by time overlap)
- Sessions missing time entries

### Step 6: Get Projects

Call `mcp__kadlekai__list_projects` to get available projects for matching.

### Step 7: Ask User for Confirmation

For each unlogged session, ask:

"I found [N] unlogged sessions. Would you like to create time entries for them?"

Options:
1. **Create all** - Create entries for all sessions
2. **Review each** - Review and approve each session individually
3. **Skip** - Don't create any entries

### Step 8: Create Worklogs

For approved sessions, call `mcp__kadlekai__create_worklog` with:
- description: **Keep it short** (max 100 chars). Use brief action words like "Auth bug fix", "API tests", "Profile endpoint". Summarize prompts concisely.
- start_time: Session start (ISO 8601)
- end_time: Session end (ISO 8601)
- project_id: Matched project ID
- billable: true

### Step 9: Final Summary

Show what was created:

```
## Created Time Entries

✅ 2h 30m - "Auth fix, tests" (Project X)
✅ 2h 30m - "Profile API" (Project Y)

Total logged: 5h 0m

Use /time:status to see today's complete log.
```

## Notes:

- Activity is tracked automatically via hooks when using Claude Code
- Sessions are detected by gaps in activity (>30 min) or explicit session boundaries
- User prompts are used to generate meaningful time entry descriptions
- Projects are matched by directory name or can be specified manually

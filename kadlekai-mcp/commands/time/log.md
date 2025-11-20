---
description: Manually log time for a completed task
argument-hint: [duration] [description]
---

# Log Time Manually

Log time for: $ARGUMENTS

## Instructions:

1. Parse the arguments to extract:
   - Duration (e.g., "2h", "30m", "1.5h", "2 hours", "30 minutes")
   - Task description
   - Time reference (e.g., "starting at 9am", "yesterday at 2pm", "at 14:30")

2. Get available projects using `mcp__kadlekai__list_projects`

3. Determine which project based on:
   - Project name mentioned in description
   - Ask user if unclear

4. Calculate timestamps:
   - Parse start time from arguments or ask user
   - Convert duration to hours/minutes
   - Calculate end_time = start_time + duration
   - Format as ISO 8601 with timezone (e.g., "2025-11-10T09:00:00+05:30")

5. Create worklog using `mcp__kadlekai__create_worklog` with:
   - description: Task description
   - start_time: ISO 8601 timestamp
   - end_time: ISO 8601 timestamp
   - project_id: Selected project ID
   - billable: true

6. Confirm creation:
   - Show duration logged
   - Show date and time range
   - Show project name
   - Display worklog ID

## Example Inputs:

- "2h iOS development starting at 9am"
- "30m code review yesterday at 2pm"
- "1.5 hours backend API work at 14:30"
- "2 hours debugging" (will ask for start time)

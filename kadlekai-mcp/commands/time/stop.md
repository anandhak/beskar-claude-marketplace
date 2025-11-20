---
description: Stop the currently running timer
argument-hint: [optional completion notes]
---

# Stop Time Tracking

Stop the currently running timer. Optional completion notes: $ARGUMENTS

## Instructions:

1. Check for running timer using `mcp__kadlekai__get_running_timer`

2. If no timer is running:
   - Inform the user there's no active timer
   - Ask if they want to manually log time instead
   - Exit

3. Show the current timer details:
   - Task description
   - Elapsed time
   - Project/task it's associated with

4. Determine the final description:
   - If $ARGUMENTS is provided, use it to update the description
   - Otherwise, keep the original timer description

5. Stop the timer using `mcp__kadlekai__stop_timer` with:
   - description: Final task description
   - project_id: The project ID from the running timer

6. Show summary:
   - Total time logged
   - Final description
   - Project name
   - Confirm worklog created successfully

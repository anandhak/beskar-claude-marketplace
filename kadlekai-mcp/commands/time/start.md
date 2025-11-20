---
description: Start tracking time on a task
argument-hint: [task description]
---

# Start Time Tracking

Start a timer for the task: $ARGUMENTS

## Instructions:

1. First check if there's already a running timer using `mcp__kadlekai__get_running_timer`

2. If a timer is already running:
   - Show the current timer details
   - Ask if they want to stop it and start a new one

3. Get available projects using `mcp__kadlekai__list_projects`

4. If task description mentions a project name, match it to the project list

5. If no project is clear from the description, ask which project to use

6. Start the timer using `mcp__kadlekai__start_timer` with:
   - description: The task description from $ARGUMENTS
   - project_id: The selected project ID

7. Confirm the timer started with:
   - Task description
   - Project name
   - Start time

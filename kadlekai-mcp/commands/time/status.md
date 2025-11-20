---
description: Check current timer status and today's time
---

# Time Tracking Status

Show current time tracking status and today's summary.

## Instructions:

1. Check for running timer using `mcp__kadlekai__get_running_timer`

2. If a timer is running, display:
   - Task description
   - Elapsed time
   - Project/task name
   - Start time

3. Get today's worklogs using `mcp__kadlekai__list_worklogs` with:
   - start_date: Today's date (YYYY-MM-DD)
   - end_date: Today's date (YYYY-MM-DD)

4. Display today's summary:
   - Total time logged today
   - Breakdown by project
   - List of all worklogs with descriptions and durations

5. Calculate totals:
   - Add running timer elapsed time (if any) to today's total
   - Show projected total if timer keeps running

## Output Format:

```
🏃 Currently Running:
   iOS development - 1h 23m elapsed
   Started at: 14:30

📊 Today's Summary:
   Total logged: 4h 15m
   With current timer: 5h 38m (projected)

   By Project:
   - iOS: 3h 0m
   - Backend: 1h 15m

   Recent worklogs:
   1. iOS bug fixing - 2h 0m (09:00-11:00)
   2. Backend API - 1h 15m (11:00-12:15)
   3. Code review - 1h 0m (13:00-14:00)
```

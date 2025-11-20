---
description: Generate time tracking report
argument-hint: [this week|last week|this month|custom range]
---

# Generate Time Report

Generate time tracking report for: $ARGUMENTS

## Instructions:

1. Parse the time period from $ARGUMENTS:
   - "this week" → Monday to today
   - "last week" → Previous Monday to Sunday
   - "this month" → First day of month to today
   - "last month" → Previous month
   - Custom: "2025-11-01 to 2025-11-10"
   - Default: "this week" if no arguments

2. Generate report using `mcp__kadlekai__generate_report` with:
   - start_date: Calculated start date (YYYY-MM-DD)
   - end_date: Calculated end date (YYYY-MM-DD)

3. Display comprehensive report:
   - Date range
   - Total hours tracked
   - Total billable hours
   - Breakdown by project
   - Breakdown by day
   - Top tasks/descriptions

4. Generate grouped report using `mcp__kadlekai__generate_grouped_report` with:
   - start_date: Same as above
   - end_date: Same as above
   - group_by: "project" (show drill-down by project)

5. Format output clearly:
   - Use tables for data
   - Show percentages
   - Highlight billable vs non-billable
   - Include daily averages

## Example Outputs:

```
📊 Time Report: Nov 4-10, 2025

Total Time: 32h 15m
Billable: 28h 30m (88%)
Non-billable: 3h 45m (12%)

By Project:
┌──────────────┬──────────┬────────┐
│ Project      │ Hours    │ %      │
├──────────────┼──────────┼────────┤
│ iOS App      │ 18h 30m  │ 57%    │
│ Backend API  │ 10h 0m   │ 31%    │
│ Code Review  │ 3h 45m   │ 12%    │
└──────────────┴──────────┴────────┘

Daily Average: 6h 27m
```

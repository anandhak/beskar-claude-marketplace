# Time Tracking Skill

Use this skill when the user wants to track time, manage worklogs, or generate time reports using Kadlekai.

## Available Tools

When Kadlekai MCP is connected, you have access to these tools:

### Timer Management
- `mcp__kadlekai__start_timer` - Start a new timer (optionally with project/task)
- `mcp__kadlekai__stop_timer` - Stop the running timer
- `mcp__kadlekai__get_running_timer` - Check if a timer is running

### Worklog Management
- `mcp__kadlekai__create_worklog` - Create a completed time entry
- `mcp__kadlekai__list_worklogs` - List worklogs with filters

### Projects & Reports
- `mcp__kadlekai__list_projects` - List available projects
- `mcp__kadlekai__generate_report` - Generate time reports
- `mcp__kadlekai__generate_grouped_report` - Grouped analytics

## Workflow Guidelines

1. **Starting Work**: Always check for running timer first before starting a new one
2. **Project Selection**: Match task descriptions to available projects when possible
3. **Stopping Work**: When stopping, use the same project_id from the running timer
4. **Reports**: Default to "this week" for reports unless specified otherwise

## Common Patterns

### Start a timer
```
1. Check for running timer
2. If running, ask user if they want to stop it
3. List projects
4. Match description to project or ask user
5. Start timer with description and project_id
```

### Stop a timer
```
1. Get running timer to retrieve worklog_id and project_id
2. Stop timer with description and project_id
3. Show summary of logged time
```

## User Commands

Users can use these slash commands:
- `/time:start <description>` - Start tracking time
- `/time:stop [notes]` - Stop current timer
- `/time:status` - Check timer status
- `/time:log <duration> <description>` - Manual time entry
- `/time:report [timeframe]` - Generate reports

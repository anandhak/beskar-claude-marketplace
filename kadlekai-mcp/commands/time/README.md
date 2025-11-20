# Time Tracking Slash Commands

Custom slash commands for automated time tracking using the Kadlekai MCP server.

## Setup

### First Time Setup

Run the interactive setup wizard to configure your Kadlekai MCP server:

```
/time:setup
```

This will guide you through:
1. Generating your API token
2. Configuring API URL (default: localhost:3000)
3. Getting your workspace ID
4. Automatically configuring the MCP server
5. Verification steps

**Important:** You'll need to restart Claude Code after setup completes.

### Manual Setup

Alternatively, use the installer script:

```bash
cd mcp-server
./install-plugin.sh
```

## Available Commands

### `/start` - Start Timer
**Usage:** `/start [task description]`

Start tracking time on a new task. Automatically detects project from description or asks which project to use.

**Examples:**
```
/start iOS bug fixing
/start Backend API development
/start Code review for PR #123
```

**What it does:**
1. Checks if a timer is already running
2. Lists available projects
3. Matches project from description or asks user
4. Starts timer with task description
5. Confirms timer started

---

### `/stop` - Stop Timer
**Usage:** `/stop [optional completion notes]`

Stop the currently running timer and log the time.

**Examples:**
```
/stop
/stop Completed user authentication flow
/stop Fixed iOS crash bug
```

**What it does:**
1. Checks for running timer
2. Shows elapsed time
3. Updates description if provided
4. Stops timer and creates worklog
5. Confirms time logged

---

### `/log` - Manual Time Entry
**Usage:** `/log [duration] [description]`

Manually log time for work already completed.

**Examples:**
```
/log 2h iOS development starting at 9am
/log 30m code review yesterday at 2pm
/log 1.5 hours backend API work at 14:30
/log 2 hours debugging
```

**What it does:**
1. Parses duration and time from arguments
2. Asks for missing information (project, start time)
3. Creates worklog entry
4. Confirms time logged

**Duration formats:**
- `2h` or `2 hours`
- `30m` or `30 minutes`
- `1.5h` or `1h 30m`

**Time formats:**
- `9am` or `09:00`
- `2pm` or `14:00`
- `yesterday at 2pm`
- `at 14:30`

---

### `/status` - Check Status
**Usage:** `/status`

View current timer status and today's time summary.

**Example:**
```
/status
```

**What it shows:**
- Currently running timer (if any)
- Elapsed time
- Today's total logged time
- Breakdown by project
- List of today's worklogs

---

### `/report` - Generate Report
**Usage:** `/report [time period]`

Generate detailed time tracking report.

**Examples:**
```
/report
/report this week
/report last week
/report this month
/report last month
```

**What it shows:**
- Total hours tracked
- Billable vs non-billable breakdown
- Time by project
- Daily breakdown
- Averages and percentages

---

## Quick Workflow Examples

### Daily Workflow

**Morning:**
```
/status                          # Check yesterday's time
/start iOS app development       # Start first task
```

**Task switching:**
```
/start Backend API work          # Auto-stops previous, starts new
```

**Lunch break:**
```
/stop                            # Stop timer for break
```

**Resume work:**
```
/start Backend API work          # Resume after lunch
```

**End of day:**
```
/stop Completed API endpoints    # Stop final task
/status                          # Review today's time
```

### Retroactive Logging

**Forgot to track time:**
```
/log 2h iOS debugging starting at 9am
/log 1.5h Backend API at 14:00
/log 30m Code review yesterday at 3pm
```

### Weekly Review

**Friday afternoon:**
```
/report this week                # See weekly breakdown
/status                          # Ensure all time logged
```

---

## Tips

1. **Start timers immediately** - Run `/start` before beginning work
2. **Be descriptive** - Include enough detail in task descriptions
3. **Review daily** - Use `/status` at end of each day
4. **Track everything** - Use `/log` for forgotten time
5. **Weekly check** - Run `/report this week` every Friday

---

## Technical Details

These commands use the Kadlekai MCP server tools:
- `mcp__kadlekai__start_timer`
- `mcp__kadlekai__stop_timer`
- `mcp__kadlekai__get_running_timer`
- `mcp__kadlekai__create_worklog`
- `mcp__kadlekai__list_worklogs`
- `mcp__kadlekai__list_projects`
- `mcp__kadlekai__generate_report`
- `mcp__kadlekai__generate_grouped_report`

For more details on the MCP server, see `/mcp-server/README.md` and `/mcp-server/CLAUDE.md`.

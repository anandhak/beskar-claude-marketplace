---
description: Interactive setup wizard for Kadlekai MCP integration
argument-hint: ""
---

# Kadlekai MCP Interactive Setup

Guide users through setting up Kadlekai time tracking integration with interactive configuration and validation.

## Workflow

### 1. Check Current State

Display welcome message and check existing configuration:
- Check if `~/.claude.json` exists
- Check if `kadlekai` MCP server is configured **globally** in `~/.claude.json` under `mcpServers.kadlekai`
- Check if `kadlekai` MCP server is configured **for this project** in `~/.claude.json` under `projects[cwd].mcpServers.kadlekai`
- If configured, show current settings (API URL, masked token) and scope (global/project)

ALWAYS offer to reconfigure, even if settings exist, because:
- User may want to update credentials
- User may want to change API URL (localhost vs production)
- User may want to use different workspace
- User may want to change scope (global vs project-specific)

Report status with checkmarks/warnings for each item.

### 2. API Token Setup

Find existing valid API token from database:
- Query: `ApiKey.where('expires_at > ?', Time.current).first`
- Display token (masked), user, and expiry date
- Ask user to confirm using this token OR generate a new one

If generating new token, show command:
```bash
bin/rails runner "
  user = User.find_by(email: 'your_email@example.com')
  auth_service = AuthenticationService.new(current_user: user, request: nil)
  result = auth_service.create_api_key_for_user(user, client_name: 'Claude Code MCP', expiry_hours: 720)
  puts 'Token: ' + result[:auth_token]
"
```

### 3. API URL Configuration

Ask for API URL or use default:
- Default: https://kadle.ai
- For local development, they can specify http://localhost:3000
- Validate URL format (must start with http:// or https://)

### 4. Configuration Scope Selection

Ask user to choose the configuration scope using AskUserQuestion:

**Question:** "Where would you like to configure Kadlekai MCP?"

| Option | Description |
|--------|-------------|
| **Global** (recommended) | Available in ALL projects. Best for users who want time tracking everywhere. |
| **Project-only** | Only available in the current project. Best for project-specific credentials or isolated setups. |

Explain the difference:
- **Global**: Configures in `~/.claude.json` → `mcpServers.kadlekai` (top-level)
- **Project-only**: Configures in `~/.claude.json` → `projects[cwd].mcpServers.kadlekai`

### 5. Configure MCP Server

Based on the scope selection, configure the Kadlekai MCP server in `~/.claude.json`.

**IMPORTANT**: Claude Code reads MCP servers from `~/.claude.json`:
- Global servers: Top-level `mcpServers` object
- Project servers: `projects["/path/to/project"].mcpServers` object

#### For GLOBAL Configuration:

```bash
# Update the global kadlekai MCP server
cat ~/.claude.json | jq --arg token "$API_TOKEN" --arg url "$API_URL" '
  .mcpServers.kadlekai = {
    "type": "stdio",
    "command": "npx",
    "args": ["--yes", "https://beskar-kadlekai-mcp.s3.amazonaws.com/packages/kadlekai-mcp-1.0.3.tgz"],
    "env": {
      "KADLEKAI_API_TOKEN": $token,
      "KADLEKAI_API_URL": $url
    }
  }
' > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
```

#### For PROJECT-ONLY Configuration:

```bash
# Get current working directory
CWD=$(pwd)

# First, ensure the project entry exists
cat ~/.claude.json | jq --arg cwd "$CWD" '
  if .projects[$cwd] == null then
    .projects[$cwd] = {
      "allowedTools": [],
      "mcpContextUris": [],
      "mcpServers": {},
      "hasTrustDialogAccepted": false,
      "projectOnboardingSeenCount": 0,
      "hasClaudeMdExternalIncludesApproved": false,
      "hasClaudeMdExternalIncludesWarningShown": false
    }
  else . end
' > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json

# Then update the kadlekai MCP server for this project
cat ~/.claude.json | jq --arg cwd "$CWD" --arg token "$API_TOKEN" --arg url "$API_URL" '
  .projects[$cwd].mcpServers.kadlekai = {
    "type": "stdio",
    "command": "npx",
    "args": ["--yes", "https://beskar-kadlekai-mcp.s3.amazonaws.com/packages/kadlekai-mcp-1.0.3.tgz"],
    "env": {
      "KADLEKAI_API_TOKEN": $token,
      "KADLEKAI_API_URL": $url
    }
  }
' > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
```

#### Cleanup Conflicting Configuration:

If user chooses **Global**, offer to remove any project-specific kadlekai config to avoid confusion:
```bash
# Remove project-specific config when going global
cat ~/.claude.json | jq --arg cwd "$CWD" '
  if .projects[$cwd].mcpServers.kadlekai then
    del(.projects[$cwd].mcpServers.kadlekai)
  else . end
' > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
```

If user chooses **Project-only** and global config exists, warn that project config takes precedence but global will still be used in other projects.

Offer options:
1. Configure automatically (update ~/.claude.json)
2. Show manual instructions
3. Skip (user will configure manually)

### 6. Restart Claude Code

**🔴 CRITICAL: Claude Code must be restarted for MCP changes to take effect!**

Display restart instructions:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  RESTART REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration saved! Now you must:

1. Completely quit Claude Code (Cmd+Q / Alt+F4)
2. Launch Claude Code from terminal:
   $ claude code

The MCP server will NOT work until restart!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask user: "Have you restarted Claude Code? (yes/no)"
- If no: Remind them to restart before testing
- If yes: Continue to verification

### 7. Verification

After restart, test complete configuration:
- Check if Kadlekai exists in ~/.claude.json (global or project-specific based on chosen scope)
- Test MCP connection by calling mcp__kadlekai__get_current_user
- Verify API token works

Display success message with next steps:
- Try `/time:start` to start tracking time
- Try `/time:status` to check current status
- Remind user of their chosen scope:
  - **Global**: "Kadlekai is now available in ALL your projects"
  - **Project-only**: "Kadlekai is configured only for this project"
- Can re-run setup to update settings, change credentials, or switch scope

### 8. Error Handling

If any step fails, enter troubleshooting mode:
- Explain the specific problem
- Provide troubleshooting steps
- Offer to retry, skip, get details, or contact support

## Key Principles

- Never expose API tokens in output (show only first 20 chars)
- Always ask before modifying files
- Validate at each step before proceeding
- Provide clear next actions
- Offer manual fallbacks for all automation
- Handle errors gracefully
- Configure MCP servers in ~/.claude.json:
  - **Global**: Top-level `mcpServers` object (available in all projects)
  - **Project-only**: Under `projects[cwd].mcpServers` (only this project)
- ALWAYS prompt for credentials even if config exists (user may want to update)
- ALWAYS ask for scope preference (global vs project-only)
- Remind users to restart Claude Code after configuration changes
- Clean up conflicting configurations when switching scopes

## Example Interaction

User: `/time:setup`
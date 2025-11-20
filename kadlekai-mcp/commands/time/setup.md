---
description: Interactive setup wizard for Kadlekai MCP integration
argument-hint: ""
---

# Kadlekai MCP Interactive Setup

Guide users through setting up Kadlekai time tracking integration with interactive configuration and validation.

## Workflow

### 1. Check Current State

Display welcome message and check project-specific configuration:
- Check if `.claude.json` exists in project root (NOT ~/.claude.json)
- Check if `kadlekai` MCP server is configured in `.claude.json`
- If configured, show current settings (API URL, masked token)

ALWAYS offer to reconfigure, even if settings exist, because:
- User may want to update credentials
- User may want to change API URL (localhost vs production)
- User may want to use different workspace

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
- Default: http://localhost:3000
- For production/staging, they can specify custom URL
- Validate URL format (must start with http:// or https://)

### 4. Configure Project-Specific MCP Server

Configure the Kadlekai MCP server in the GLOBAL ~/.claude.json under the project's entry.

**IMPORTANT**: Claude Code reads project MCP servers from `~/.claude.json` under `projects["/path/to/project"].mcpServers`, NOT from a local `.claude.json` file.

Steps:
1. Read the current ~/.claude.json
2. Find or create the project entry under `projects[cwd]`
3. Add/update the kadlekai MCP server configuration
4. Write back to ~/.claude.json

Use jq or similar to update the JSON:
```bash
# Get current working directory
CWD=$(pwd)

# Update ~/.claude.json with the kadlekai MCP server for this project
cat ~/.claude.json | jq --arg cwd "$CWD" --arg token "$API_TOKEN" --arg url "$API_URL" '
  .projects[$cwd].mcpServers.kadlekai = {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "https://beskar-kadlekai-mcp.s3.amazonaws.com/packages/kadlekai-mcp-latest.tgz"],
    "env": {
      "KADLEKAI_API_TOKEN": $token,
      "KADLEKAI_API_URL": $url
    }
  }
' > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
```

If the project entry doesn't exist, create it first:
```bash
cat ~/.claude.json | jq --arg cwd "$CWD" '
  if .projects[$cwd] == null then
    .projects[$cwd] = {
      "allowedTools": [],
      "mcpContextUris": [],
      "mcpServers": {},
      "hasTrustDialogAccepted": true
    }
  else . end
' > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
```

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
- Check if Kadlekai exists in ~/.claude.json under projects[cwd].mcpServers
- Test MCP connection by calling mcp__kadlekai__get_current_user
- Verify API token works

Display success message with next steps:
- Try `/time:start` to start tracking time
- Try `/time:status` to check current status
- Configuration is project-specific (only works in this project)
- Can re-run setup to update settings or use different credentials

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
- Configure MCP servers in ~/.claude.json under projects[cwd].mcpServers (NOT local .claude.json)
- ALWAYS prompt for credentials even if config exists (user may want to update)
- Remind users to restart Claude Code after configuration changes

## Example Interaction

User: `/time:setup`
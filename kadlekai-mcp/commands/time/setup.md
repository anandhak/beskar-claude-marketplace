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

Configure the Kadlekai MCP server in PROJECT ROOT .claude.json (not ~/.claude.json):

Check if .claude.json exists in project root:
- If not, create it with minimal structure
- If yes, backup existing file

Add/Update Kadlekai MCP configuration:
- Use actual credential values
- Add to .mcpServers.kadlekai in .claude.json
- Use npx with S3 package URL (not local file path)
- NO workspace_id needed (API determines workspace from token)

Create configuration file:
```bash
cat > .claude.json << EOF
{
  "mcpServers": {
    "kadlekai": {
      "command": "npx",
      "args": ["--yes", "https://beskar-kadlekai-mcp.s3.amazonaws.com/packages/kadlekai-mcp-latest.tgz"],
      "env": {
        "KADLEKAI_API_TOKEN": "$API_TOKEN",
        "KADLEKAI_API_URL": "$API_URL"
      }
    }
  }
}
EOF
```

Offer options:
1. Configure automatically (create the file)
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
- Check if Kadlekai exists in project .claude.json
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
- Use project-specific .claude.json configuration (NOT global ~/.claude.json)
- ALWAYS prompt for credentials even if config exists (user may want to update)
- Remind users to restart Claude Code after configuration changes

## Example Interaction

User: `/time:setup`
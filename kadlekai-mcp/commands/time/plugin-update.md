# Update Kadlekai Plugin

Update to the latest version of the Kadlekai plugin from the marketplace.

## Instructions

Run the following commands to update the plugin and MCP server:

```bash
claude plugins update kadlekai-mcp@kadlekai-marketplace && rm -rf ~/.npm/_npx/*kadlekai* 2>/dev/null && echo "Updated! Restart Claude Code to use the new version."
```

After running, restart your Claude Code session to load the updated plugin.

## What this does

1. **Updates plugin** - Downloads latest commands, hooks, and configuration from marketplace
2. **Clears MCP cache** - Ensures fresh MCP server download on next session
3. **Restart required** - New version loads when you start a new Claude Code session

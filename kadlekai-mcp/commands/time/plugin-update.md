# Update Kadlekai Plugin

To update to the latest version, run these commands in a **separate terminal** (not via Claude):

```bash
# Step 1: Update plugin from marketplace
claude plugins update kadlekai-mcp@kadlekai-marketplace

# Step 2: Clear MCP server cache
rm -rf ~/.npm/_npx/*kadlekai*

# Step 3: Restart Claude Code (exit and reopen)
```

The `claude plugins update` command is interactive and needs to run in your terminal directly.

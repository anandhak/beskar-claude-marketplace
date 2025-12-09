# Update Kadlekai Plugin

Update the marketplace and clear MCP cache to get the latest version.

## Instructions

Run these commands:

```bash
claude plugin marketplace update kadlekai-marketplace && rm -rf ~/.npm/_npx/*kadlekai* 2>/dev/null && echo "Done! Restart Claude Code."
```

Then restart Claude Code to load the updated plugin.

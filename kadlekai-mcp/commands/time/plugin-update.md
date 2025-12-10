# Update Kadlekai Plugin

Update to the latest version of the Kadlekai plugin.

## Instructions

Run these commands:

```bash
claude plugin marketplace update kadlekai-marketplace && claude plugin uninstall kadlekai-mcp@kadlekai-marketplace && claude plugin install kadlekai-mcp@kadlekai-marketplace && echo "Done! Restart Claude Code."
```

Then restart Claude Code to load the updated plugin.

## What this does

1. Updates marketplace index from GitLab
2. Uninstalls current plugin
3. Reinstalls plugin with latest version
4. Restart loads everything fresh

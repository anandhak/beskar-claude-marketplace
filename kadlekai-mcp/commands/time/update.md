# Update Kadlekai MCP Server

Update to the latest version of the Kadlekai MCP server.

## Instructions

Run the following command to clear the npx cache and download the latest MCP server:

```bash
rm -rf ~/.npm/_npx/*kadlekai* 2>/dev/null; echo "Cache cleared. Restart Claude Code to use the latest version."
```

After running, restart your Claude Code session to load the updated MCP server.

## What this does

1. **Clears npx cache** - Removes cached versions of the Kadlekai MCP package
2. **Next session loads latest** - When Claude Code restarts, npx will download fresh from `kadlekai-mcp-latest.tgz`

## To update the plugin itself (commands, hooks)

To update the plugin (not just the MCP server), run:

```bash
claude plugins update kadlekai-mcp@kadlekai-marketplace
```

Or update all plugins:

```bash
claude plugins update
```

## Version info

- The MCP server uses a `-latest.tgz` URL, so clearing cache always gets the newest version
- Plugin version and MCP server version are kept in sync
- Current version: 1.0.4

#!/bin/bash
# Setup MCP Servers (Playwright) for macOS

set -e

# Configuration for Playwright MCP
MCP_CONFIG='{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    }
  }
}'

# 1. Configure for Claude Desktop on macOS
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required. Please install it with 'brew install jq'"
    exit 1
fi

echo "Setting up Playwright MCP for Claude Desktop..."

mkdir -p "$CLAUDE_CONFIG_DIR"

if [ -f "$CLAUDE_CONFIG_FILE" ]; then
    # Merge existing config with new MCP config
    # This uses jq to recursively merge (. * $MCP_CONFIG)
    TEMP_FILE=$(mktemp)
    jq --argjson new "$MCP_CONFIG" '. * $new' "$CLAUDE_CONFIG_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$CLAUDE_CONFIG_FILE"
else
    # Create new file
    echo "$MCP_CONFIG" | jq '.' > "$CLAUDE_CONFIG_FILE"
fi

echo "Updated Claude Desktop config at: $CLAUDE_CONFIG_FILE"

# 2. Output for other editors (Cursor, Windsurf)
echo ""
echo "=== Configuration for Other Editors ==="
echo "For Cursor, Windsurf, or VS Code, add the following to your MCP settings:"
echo "$MCP_CONFIG" | jq '.mcpServers'

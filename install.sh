#!/bin/bash
set -e

echo "Starting wbw-daemon plugin installation..."

# Discover or prompt for AGY_WORKSPACE_ROOT
if [ -z "$AGY_WORKSPACE_ROOT" ]; then
    read -p "Enter AGY_WORKSPACE_ROOT (e.g., /home/user/workspace): " AGY_WORKSPACE_ROOT
fi

# Discover or prompt for AGY_OPERATOR_ID
if [ -z "$AGY_OPERATOR_ID" ]; then
    read -p "Enter AGY_OPERATOR_ID: " AGY_OPERATOR_ID
fi

# Export for sub-processes if necessary
export AGY_WORKSPACE_ROOT
export AGY_OPERATOR_ID

PLUGIN_TARGET="$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon"

echo "Workspace Root: $AGY_WORKSPACE_ROOT"
echo "Operator ID: $AGY_OPERATOR_ID"

# Ensure plugins directory exists
mkdir -p "$AGY_WORKSPACE_ROOT/.agents/plugins"

# Remove existing symlink or directory
if [ -e "$PLUGIN_TARGET" ] || [ -L "$PLUGIN_TARGET" ]; then
    echo "Removing existing installation at $PLUGIN_TARGET"
    rm -rf "$PLUGIN_TARGET"
fi

# Symlink current repository to the plugins directory
echo "Symlinking $(pwd) to $PLUGIN_TARGET"
ln -s "$(pwd)" "$PLUGIN_TARGET"

# Dynamically rewrite mcp_config.json with absolute path
echo "Updating mcp_config.json with absolute path..."
sed -i "s|\"[^\"]*bin/mcp-bridge.sh\"|\"$PLUGIN_TARGET/bin/mcp-bridge.sh\"|g" "$(pwd)/mcp_config.json"

# Create an executable symlink in ~/.local/bin
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"

DAEMON_SYMLINK="$LOCAL_BIN_DIR/wbw-daemon"
echo "Symlinking wbw-daemon to $DAEMON_SYMLINK"

# Ensure the source script is executable
chmod +x "$PLUGIN_TARGET/bin/wbw-daemon"
# Create the symlink
ln -sf "$PLUGIN_TARGET/bin/wbw-daemon" "$DAEMON_SYMLINK"

echo "wbw-daemon installed successfully."
echo "Note: Ensure $LOCAL_BIN_DIR is in your system PATH."

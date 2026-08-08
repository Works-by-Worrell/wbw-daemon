#!/bin/bash
set -e

echo "Starting wbw-daemon plugin installation..."

# Discover AGY_OPERATOR_ID with a pseudo-interactive prompt defaulting to $USER
if [ -z "$AGY_OPERATOR_ID" ]; then
    read -p "Enter AGY_OPERATOR_ID [$USER]: " INPUT_ID
    AGY_OPERATOR_ID="${INPUT_ID:-$USER}"
fi

# Derive AGY_WORKSPACE_ROOT dynamically
AGY_WORKSPACE_ROOT="/home/${AGY_OPERATOR_ID}/Works-by-Worrell"

# Discover Warlock Service with a pseudo-interactive prompt
if [ -z "$WBW_WARLOCK_SERVICE" ]; then
    read -p "Enter Warlock Service [warlock-mcp-nprd]: " INPUT_SERVICE
    WBW_WARLOCK_SERVICE="${INPUT_SERVICE:-warlock-mcp-nprd}"
fi

# Discover Warlock Region with a pseudo-interactive prompt
if [ -z "$WBW_WARLOCK_REGION" ]; then
    read -p "Enter Warlock Region [us-central1]: " INPUT_REGION
    WBW_WARLOCK_REGION="${INPUT_REGION:-us-central1}"
fi

# Export for sub-processes if necessary
export AGY_WORKSPACE_ROOT
export AGY_OPERATOR_ID
export WBW_WARLOCK_SERVICE
export WBW_WARLOCK_REGION

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
cp "$(pwd)/mcp_config.json.template" "$(pwd)/mcp_config.json"
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

# Update ~/.bashrc
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    echo "Configuring ~/.bashrc..."
    # Remove existing exports to prevent duplicates
    sed -i '/export AGY_WORKSPACE_ROOT=/d' "$BASHRC"
    sed -i '/export AGY_OPERATOR_ID=/d' "$BASHRC"
    sed -i '/export WBW_WARLOCK_SERVICE=/d' "$BASHRC"
    sed -i '/export WBW_WARLOCK_REGION=/d' "$BASHRC"
    sed -i '/alias wbw-daemon=/d' "$BASHRC"
    
    echo "" >> "$BASHRC"
    echo "# Works-by-Worrell Config" >> "$BASHRC"
    echo "export AGY_OPERATOR_ID=\"$AGY_OPERATOR_ID\"" >> "$BASHRC"
    echo "export AGY_WORKSPACE_ROOT=\"$AGY_WORKSPACE_ROOT\"" >> "$BASHRC"
    echo "export WBW_WARLOCK_SERVICE=\"$WBW_WARLOCK_SERVICE\"" >> "$BASHRC"
    echo "export WBW_WARLOCK_REGION=\"$WBW_WARLOCK_REGION\"" >> "$BASHRC"
    echo "Successfully updated ~/.bashrc"
fi

echo "wbw-daemon installed successfully."
echo "Note: Ensure $LOCAL_BIN_DIR is in your system PATH."

echo ""
echo "============================================================"
echo "    REQUIRED ACTION: RELOAD YOUR TERMINAL ENVIRONMENT       "
echo "============================================================"
echo " You MUST execute the following command before continuing:"
echo ""
echo "                   source ~/.bashrc                       "
echo ""
echo "============================================================"
echo ""

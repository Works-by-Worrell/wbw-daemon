#!/bin/bash
set -e

# ANSI Color Codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

# Clear screen and display banner
clear
echo -e "${CYAN}${BOLD}"
echo "    __      __  ___ _      __    ___                             "
echo "    \ \    / / | _ ) \    / /___|   \ __ _ ___ _ __  ___ _ _   "
echo "     \ \/\/ /  | _ \\ \/\/ /|___| |) / _\` / -_) '  \/ _ \ ' \  "
echo "      \_/\_/   |___/ \_/\_/     |___/\__,_\___|_|_|_\___/_||_| "
echo "                                                               "
echo -e "${RESET}"
echo -e " ${BOLD}Daemon Configuration Wizard${RESET}"
echo -e " ${DIM}========================================================${RESET}\n"

# ---------------------------------------------------------
# Phase 1: Configuration
# ---------------------------------------------------------
echo -e "${BLUE}${BOLD}[1/3] Environment Configuration${RESET}"

# Operator ID
DEFAULT_OP_ID="${AGY_OPERATOR_ID:-$USER}"
echo -ne "  ${BOLD}? Enter AGY_OPERATOR_ID${RESET} ${DIM}[${DEFAULT_OP_ID}]${RESET}: "
read INPUT_ID
AGY_OPERATOR_ID="${INPUT_ID:-$DEFAULT_OP_ID}"

# GitHub Token
DEFAULT_TOKEN="${GITHUB_TOKEN:-}"
echo -ne "  ${BOLD}? Enter GitHub Personal Access Token (for Edge-Execution)${RESET} ${DIM}[${DEFAULT_TOKEN:0:5}...${DEFAULT_TOKEN: -4}]${RESET}: "
read INPUT_TOKEN
GITHUB_TOKEN="${INPUT_TOKEN:-$DEFAULT_TOKEN}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "  ${YELLOW}⚠ WARNING: GITHUB_TOKEN is required for daemon identity resolution.${RESET}"
fi

# YouTrack Configuration
DEFAULT_YT_URL="${YOUTRACK_URL:-https://warlock-exfil.youtrack.cloud}"
echo -ne "  ${BOLD}? Enter YouTrack URL${RESET} ${DIM}[${DEFAULT_YT_URL}]${RESET}: "
read INPUT_YT_URL
YOUTRACK_URL="${INPUT_YT_URL:-$DEFAULT_YT_URL}"

DEFAULT_YT_TOKEN="${YOUTRACK_TOKEN:-}"
echo -ne "  ${BOLD}? Enter YouTrack Permanent Token${RESET} ${DIM}[${DEFAULT_YT_TOKEN:0:5}...${DEFAULT_YT_TOKEN: -4}]${RESET}: "
read INPUT_YT_TOKEN
YOUTRACK_TOKEN="${INPUT_YT_TOKEN:-$DEFAULT_YT_TOKEN}"

if [ -z "$YOUTRACK_TOKEN" ]; then
    echo -e "  ${YELLOW}⚠ WARNING: YOUTRACK_TOKEN is required for the Warlock MCP agent to manage Kanban boards.${RESET}"
fi

# Derive Workspace
AGY_WORKSPACE_ROOT="/home/${AGY_OPERATOR_ID}/Works-by-Worrell"

# Export for sub-processes
export AGY_WORKSPACE_ROOT
export AGY_OPERATOR_ID
export GITHUB_TOKEN
export YOUTRACK_URL
export YOUTRACK_TOKEN

PLUGIN_TARGET="$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon"
LOCAL_BIN_DIR="$HOME/.local/bin"

echo -e "\n  ${GREEN}✓ Configuration captured.${RESET}\n"


# ---------------------------------------------------------
# Phase 2: Configuration & MCP Compilation
# ---------------------------------------------------------
echo -e "${BLUE}${BOLD}[2/3] System Integration${RESET}"

mkdir -p "$HOME/.gemini/config/plugins"

PLUGIN_TARGET="$HOME/.gemini/config/plugins/wbw-daemon"

# Clean up legacy symlink or directory if it exists
if [ -e "$PLUGIN_TARGET" ] || [ -L "$PLUGIN_TARGET" ]; then
    rm -rf "$PLUGIN_TARGET"
fi

cp "$(pwd)/mcp_config.json.template" "$(pwd)/mcp_config.json"
sed -i "s|_PLUGIN_DIR_|$PLUGIN_TARGET|g" "$(pwd)/mcp_config.json"
echo -e "  ${GREEN}✓ Compiled mcp_config.json${RESET} ${DIM}(Stdio bridge activated)${RESET}"

# Ensure gatekeeper hook script is executable
chmod +x "$(pwd)/bin/gatekeeper.sh" 2>/dev/null || true

# We must use a hard copy because the Antigravity CLI's plugin scanner (filepath.WalkDir) 
# strictly ignores symlinks, and plugins.json workspace-relative paths have edge cases.
cp -r "$(pwd)" "$PLUGIN_TARGET"

# Also sync plugin copy directly into workspace .agents plugin directory
WS_PLUGIN_TARGET="$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon"
mkdir -p "$(dirname "$WS_PLUGIN_TARGET")"
rm -rf "$WS_PLUGIN_TARGET"
cp -r "$(pwd)" "$WS_PLUGIN_TARGET"

agy plugin enable wbw-daemon >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ Installed and enabled plugin${RESET} ${DIM}($PLUGIN_TARGET)${RESET}"
echo -e "  ${GREEN}✓ Configured command gatekeeper hook${RESET} ${DIM}(hooks.json & bin/gatekeeper.sh)${RESET}"

mkdir -p "$LOCAL_BIN_DIR"

# Symlink wbw-daemon
DAEMON_SYMLINK="$LOCAL_BIN_DIR/wbw-daemon"
chmod +x "$(pwd)/bin/wbw-daemon"
ln -sf "$(pwd)/bin/wbw-daemon" "$DAEMON_SYMLINK"
echo -e "  ${GREEN}✓ Bound executable${RESET} ${DIM}($DAEMON_SYMLINK)${RESET}"

# Symlink wbw-mcp-inspect
INSPECT_SYMLINK="$LOCAL_BIN_DIR/wbw-mcp-inspect"
chmod +x "$(pwd)/bin/wbw-mcp-inspect"
ln -sf "$(pwd)/bin/wbw-mcp-inspect" "$INSPECT_SYMLINK"
echo -e "  ${GREEN}✓ Bound executable${RESET} ${DIM}($INSPECT_SYMLINK)${RESET}\n"


# ---------------------------------------------------------
# Phase 3: Profile Injection
# ---------------------------------------------------------
echo -e "${BLUE}${BOLD}[3/3] Profile Injection${RESET}"

BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    sed -i '/export AGY_WORKSPACE_ROOT=/d' "$BASHRC"
    sed -i '/export AGY_OPERATOR_ID=/d' "$BASHRC"
    sed -i '/export WBW_WARLOCK_SERVICE=/d' "$BASHRC"
    sed -i '/export WBW_WARLOCK_REGION=/d' "$BASHRC"
    sed -i '/alias wbw-daemon=/d' "$BASHRC"
    
    echo "" >> "$BASHRC"
    echo "# Works-by-Worrell Config" >> "$BASHRC"
    echo "export AGY_OPERATOR_ID=\"$AGY_OPERATOR_ID\"" >> "$BASHRC"
    echo "export AGY_WORKSPACE_ROOT=\"$AGY_WORKSPACE_ROOT\"" >> "$BASHRC"
    
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "export GITHUB_TOKEN=\"$GITHUB_TOKEN\"" >> "$BASHRC"
    fi
    
    if [ -n "$YOUTRACK_URL" ]; then
        echo "export YOUTRACK_URL=\"$YOUTRACK_URL\"" >> "$BASHRC"
    fi
    
    if [ -n "$YOUTRACK_TOKEN" ]; then
        echo "export YOUTRACK_TOKEN=\"$YOUTRACK_TOKEN\"" >> "$BASHRC"
    fi
    
    echo -e "  ${GREEN}✓ Environment variables persisted to ~/.bashrc${RESET}\n"
else
    echo -e "  ${YELLOW}⚠ ~/.bashrc not found. Environment variables were not saved.${RESET}\n"
fi


# ---------------------------------------------------------
# Summary & Handoff
# ---------------------------------------------------------
echo -e "${GREEN}${BOLD}Installation Complete!${RESET}"
echo -e "${DIM}wbw-daemon is now fully configured and bound to your local environment.${RESET}\n"

echo -e "${YELLOW}============================================================${RESET}"
echo -e "${YELLOW}${BOLD}    REQUIRED ACTION: RELOAD YOUR TERMINAL ENVIRONMENT       ${RESET}"
echo -e "${YELLOW}============================================================${RESET}"
echo -e "${BOLD} You MUST execute the following command before continuing:${RESET}\n"
echo -e "                   ${CYAN}source ~/.bashrc${RESET}\n"
echo -e "${YELLOW}============================================================${RESET}\n"

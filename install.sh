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

# Derive Workspace
AGY_WORKSPACE_ROOT="/home/${AGY_OPERATOR_ID}/Works-by-Worrell"

# Warlock Service
DEFAULT_SERVICE="${WBW_WARLOCK_SERVICE:-warlock-mcp-nprd}"
echo -ne "  ${BOLD}? Enter Warlock Service${RESET} ${DIM}[${DEFAULT_SERVICE}]${RESET}: "
read INPUT_SERVICE
WBW_WARLOCK_SERVICE="${INPUT_SERVICE:-$DEFAULT_SERVICE}"

# Warlock Region
DEFAULT_REGION="${WBW_WARLOCK_REGION:-us-central1}"
echo -ne "  ${BOLD}? Enter Warlock Region${RESET}  ${DIM}[${DEFAULT_REGION}]${RESET}: "
read INPUT_REGION
WBW_WARLOCK_REGION="${INPUT_REGION:-$DEFAULT_REGION}"

# Export for sub-processes
export AGY_WORKSPACE_ROOT
export AGY_OPERATOR_ID
export WBW_WARLOCK_SERVICE
export WBW_WARLOCK_REGION

PLUGIN_TARGET="$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon"
LOCAL_BIN_DIR="$HOME/.local/bin"

echo -e "\n  ${GREEN}✓ Configuration captured.${RESET}\n"


# ---------------------------------------------------------
# Phase 2: Symlinks & MCP Compilation
# ---------------------------------------------------------
echo -e "${BLUE}${BOLD}[2/3] System Integration${RESET}"

mkdir -p "$AGY_WORKSPACE_ROOT/.agents/plugins"

if [ -e "$PLUGIN_TARGET" ] || [ -L "$PLUGIN_TARGET" ]; then
    rm -rf "$PLUGIN_TARGET"
fi

ln -s "$(pwd)" "$PLUGIN_TARGET"
echo -e "  ${GREEN}✓ Created plugin symlink${RESET} ${DIM}(.agents/plugins/wbw-daemon)${RESET}"

cp "$(pwd)/mcp_config.json.template" "$(pwd)/mcp_config.json"
sed -i "s|\"[^\"]*bin/mcp-bridge.sh\"|\"$PLUGIN_TARGET/bin/mcp-bridge.sh\"|g" "$(pwd)/mcp_config.json"
echo -e "  ${GREEN}✓ Compiled mcp_config.json${RESET} ${DIM}(Absolute path injected)${RESET}"

mkdir -p "$LOCAL_BIN_DIR"
DAEMON_SYMLINK="$LOCAL_BIN_DIR/wbw-daemon"
chmod +x "$PLUGIN_TARGET/bin/wbw-daemon"
ln -sf "$PLUGIN_TARGET/bin/wbw-daemon" "$DAEMON_SYMLINK"
echo -e "  ${GREEN}✓ Bound executable${RESET} ${DIM}($DAEMON_SYMLINK)${RESET}\n"


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
    echo "export WBW_WARLOCK_SERVICE=\"$WBW_WARLOCK_SERVICE\"" >> "$BASHRC"
    echo "export WBW_WARLOCK_REGION=\"$WBW_WARLOCK_REGION\"" >> "$BASHRC"
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

#!/bin/bash
set -e

# ANSI Formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}Works-by-Worrell Daemon SDK Setup${RESET}\n"

# Ensure vault directory exists
WBW_DIR="$HOME/.wbw"
mkdir -p "$WBW_DIR"
WBW_ENV="$WBW_DIR/.env"
touch "$WBW_ENV"

# Prompt for GITHUB_API_KEY if not already set
if ! grep -q "^GITHUB_API_KEY=" "$WBW_ENV"; then
    echo -e "${YELLOW}Warlock requires a GitHub Personal Access Token to fetch your organizational definitions.${RESET}"
    read -rp "Enter your GITHUB_API_KEY: " GITHUB_API_KEY
    if [ -n "$GITHUB_API_KEY" ]; then
        echo "GITHUB_API_KEY=\"$GITHUB_API_KEY\"" >> "$WBW_ENV"
        echo -e "  ${GREEN}✓ GITHUB_API_KEY securely stored in $WBW_ENV${RESET}\n"
    else
        echo -e "  ${YELLOW}⚠ Token skipped. Warlock will not have private API access.${RESET}\n"
    fi
else
    echo -e "  ${GREEN}✓ GITHUB_API_KEY is already configured in $WBW_ENV${RESET}\n"
fi

echo -e "${GREEN}${BOLD}Setup Complete!${RESET}"
echo -e "${DIM}You can now boot the daemon by running:${RESET}"
echo -e "${CYAN}uv run wbw-daemon${RESET}\n"

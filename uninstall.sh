#!/usr/bin/env bash
#
# FileDrop Mac uninstaller — removes everything.
#

set -euo pipefail

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo
echo -e "${BOLD}Uninstalling FileDrop...${RESET}"
echo

# Remove shell profile block
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if grep -q '# filedrop start' "$rc" 2>/dev/null; then
        sed -i '' '/# filedrop start/,/# filedrop end/d' "$rc"
        echo -e "${GREEN}✓${RESET} Removed auto-start from $rc"
    fi
done

# Remove old LaunchAgent if present
PLIST="$HOME/Library/LaunchAgents/com.filedrop.server.plist"
if [[ -f "$PLIST" ]]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm "$PLIST"
    echo -e "${GREEN}✓${RESET} Removed LaunchAgent"
fi

# Kill running server
if pgrep -f "mac-server.py" &>/dev/null; then
    pkill -f "mac-server.py"
    echo -e "${GREEN}✓${RESET} Stopped running server"
fi

echo
echo -e "${DIM}FileDrop removed. You can delete ~/filedrop if you no longer need it.${RESET}"
echo

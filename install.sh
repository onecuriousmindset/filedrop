#!/usr/bin/env bash
#
# FileDrop Mac installer — adds auto-start to shell profile.
# Run this once on your Mac: ./install.sh [--port PORT]
#

set -euo pipefail

# Colors
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
RESET='\033[0m'

PORT=8857

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port) PORT="$2"; shift 2 ;;
        *) echo "Usage: ./install.sh [--port PORT]"; exit 1 ;;
    esac
done

FILEDROP_DIR="$(cd "$(dirname "$0")" && pwd)"
TOKEN_FILE="$FILEDROP_DIR/.filedrop-token"

# Generate a fixed token (or reuse existing)
if [[ -f "$TOKEN_FILE" ]]; then
    TOKEN=$(<"$TOKEN_FILE")
else
    TOKEN=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    echo "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
fi

# Remove old LaunchAgent if present
PLIST_PATH="$HOME/Library/LaunchAgents/com.filedrop.server.plist"
if [[ -f "$PLIST_PATH" ]]; then
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    rm "$PLIST_PATH"
fi

# Add to shell profile
SHELL_RC="$HOME/.zshrc"
[[ -f "$HOME/.bashrc" && ! -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.bashrc"

# Remove old filedrop block if present, then add new one
if grep -q '# filedrop' "$SHELL_RC" 2>/dev/null; then
    sed -i '' '/# filedrop start/,/# filedrop end/d' "$SHELL_RC"
fi

cat >> "$SHELL_RC" <<SHELL
# filedrop start
if ! lsof -i :${PORT} &>/dev/null; then
    python3 ${FILEDROP_DIR}/mac-server.py --token "${TOKEN}" --port ${PORT} &>/dev/null &
    disown
fi
# filedrop end
SHELL

# Start it now too
if ! lsof -i :${PORT} &>/dev/null; then
    python3 "${FILEDROP_DIR}/mac-server.py" --token "${TOKEN}" --port ${PORT} &>/dev/null &
    disown
fi

# --- Output ---

echo
echo -e "${GREEN}✓ FileDrop installed.${RESET} Server starts automatically when you open a terminal."
echo
echo -e "${BOLD}${WHITE}Next steps:${RESET}"
echo
echo -e "${CYAN}Step 1${RESET} ${DIM}— Add this to${RESET} ${BOLD}~/.ssh/config${RESET} ${DIM}on this Mac:${RESET}"
echo
echo -e "    ${WHITE}Host ${YELLOW}<your-server-alias>${RESET}"
echo -e "        ${WHITE}HostName ${YELLOW}<your-server-ip>${RESET}"
echo -e "        ${WHITE}RemoteForward ${PORT} localhost:${PORT}${RESET}"
echo
echo -e "    ${DIM}Replace ${YELLOW}<your-server-alias>${DIM} with a name like 'dev' or 'prod'${RESET}"
echo -e "    ${DIM}Replace ${YELLOW}<your-server-ip>${DIM} with the IP or hostname of your server${RESET}"
echo -e "    ${DIM}Then use: ssh user@your-server-alias${RESET}"
echo
echo -e "${CYAN}Step 2${RESET} ${DIM}— SSH into your server and run:${RESET}"
echo
echo -e "    ${WHITE}git clone https://github.com/onecuriousmindset/filedrop.git ~/filedrop${RESET}"
if [[ "$PORT" == "8857" ]]; then
    echo -e "    ${WHITE}cd ~/filedrop && ./setup-server.sh ${GREEN}${TOKEN}${RESET}"
else
    echo -e "    ${WHITE}cd ~/filedrop && ./setup-server.sh --port ${PORT} ${GREEN}${TOKEN}${RESET}"
fi
echo
echo -e "${DIM}That's it. Drag a file into your terminal and the agent will fetch it.${RESET}"
echo

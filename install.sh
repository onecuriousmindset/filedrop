#!/usr/bin/env bash
#
# FileDrop Mac installer — sets up LaunchAgent + fixed token.
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
PLIST_NAME="com.filedrop.server"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"
TOKEN_FILE="$FILEDROP_DIR/.filedrop-token"
PYTHON3=$(which python3)

# Generate a fixed token (or reuse existing)
if [[ -f "$TOKEN_FILE" ]]; then
    TOKEN=$(<"$TOKEN_FILE")
else
    TOKEN=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    echo "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
fi

# Create LaunchAgent plist
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${PYTHON3}</string>
        <string>${FILEDROP_DIR}/mac-server.py</string>
        <string>--token</string>
        <string>${TOKEN}</string>
        <string>--port</string>
        <string>${PORT}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${FILEDROP_DIR}/filedrop.log</string>
    <key>StandardErrorPath</key>
    <string>${FILEDROP_DIR}/filedrop.log</string>
</dict>
</plist>
PLIST

# Load the agent (unload first if already running)
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

# --- Output ---

echo
echo -e "${GREEN}✓ FileDrop installed.${RESET} Server is running on port ${PORT} and will start automatically on login."
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

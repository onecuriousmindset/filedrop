#!/usr/bin/env bash
#
# FileDrop Mac installer — sets up LaunchAgent + fixed token.
# Run this once on your Mac: ./install.sh
#

set -euo pipefail

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

echo "FileDrop installed. Starts automatically on login."
echo
echo "Your token (use this on remote servers):"
echo "  $TOKEN"

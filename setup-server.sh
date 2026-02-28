#!/usr/bin/env bash
#
# FileDrop remote server setup.
# Run this once on each remote server you want to use FileDrop with.
#
# Usage: ./setup-server.sh <token>
#

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: ./setup-server.sh <token>"
    echo
    echo "The token is printed when you run install.sh on your Mac."
    exit 1
fi

TOKEN="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Save token
echo "$TOKEN" > "$HOME/.filedrop-token"
chmod 600 "$HOME/.filedrop-token"
echo "Token saved to ~/.filedrop-token"

# Install fetch-file command
mkdir -p "$HOME/bin"
cp "$SCRIPT_DIR/fetch-file" "$HOME/bin/fetch-file"
chmod +x "$HOME/bin/fetch-file"
echo "Installed fetch-file to ~/bin/fetch-file"

# Ensure ~/bin is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "$HOME/bin"; then
    SHELL_RC="$HOME/.bashrc"
    [[ -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.zshrc"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
    echo "Added ~/bin to PATH in $SHELL_RC"
fi

# Install Claude Code skill
mkdir -p "$HOME/.claude/skills/fetch-file"
cp "$SCRIPT_DIR/SKILL.md" "$HOME/.claude/skills/fetch-file/SKILL.md"
echo "Installed Claude Code skill to ~/.claude/skills/fetch-file/"

echo
echo "Done. Start a new shell or run: export PATH=\"\$HOME/bin:\$PATH\""

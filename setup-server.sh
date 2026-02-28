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

# Install skill for all agents (cross-agent standard + Claude Code + OpenCode)
for dir in "$HOME/.agents/skills/fetch-file" \
           "$HOME/.claude/skills/fetch-file" \
           "$HOME/.config/opencode/skills/fetch-file"; do
    mkdir -p "$dir"
    cp "$SCRIPT_DIR/SKILL.md" "$dir/SKILL.md"
done
echo "Installed skill for Claude Code, Codex, OpenCode, Cursor, Windsurf"

echo
echo "Done. Start a new shell or run: export PATH=\"\$HOME/bin:\$PATH\""
echo
echo "Or install via skills.sh (works with any agent):"
echo "  npx skills add onecuriousmindset/filedrop"

#!/usr/bin/env bash
#
# FileDrop remote server uninstaller — removes everything.
#

set -euo pipefail

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
RESET='\033[0m'

echo
echo -e "${BOLD}Uninstalling FileDrop from server...${RESET}"
echo

# Remove fetch-file command
if [[ -f "$HOME/bin/fetch-file" ]]; then
    rm "$HOME/bin/fetch-file"
    echo -e "${GREEN}✓${RESET} Removed ~/bin/fetch-file"
fi

# Remove token and port files
for f in "$HOME/.filedrop-token" "$HOME/.filedrop-port"; do
    if [[ -f "$f" ]]; then
        rm "$f"
        echo -e "${GREEN}✓${RESET} Removed $f"
    fi
done

# Remove skills from all agents
for dir in "$HOME/.agents/skills/fetch-file" \
           "$HOME/.claude/skills/fetch-file" \
           "$HOME/.config/opencode/skills/fetch-file"; do
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
        echo -e "${GREEN}✓${RESET} Removed $dir"
    fi
done

# Remove downloaded files
if [[ -d "$HOME/filedrop" ]] && [[ -n "$(ls -A "$HOME/filedrop/"*.png 2>/dev/null || ls -A "$HOME/filedrop/"*.jpg 2>/dev/null || true)" ]]; then
    read -p "Delete downloaded files in ~/filedrop? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$HOME/filedrop/"*.png "$HOME/filedrop/"*.jpg "$HOME/filedrop/"*.jpeg \
              "$HOME/filedrop/"*.gif "$HOME/filedrop/"*.webp "$HOME/filedrop/"*.pdf \
              "$HOME/filedrop/"*.mp4 "$HOME/filedrop/"*.mov "$HOME/filedrop/"*.webm
        echo -e "${GREEN}✓${RESET} Deleted downloaded files"
    fi
fi

echo
echo -e "${DIM}FileDrop removed. You can delete ~/filedrop if you no longer need it.${RESET}"
echo

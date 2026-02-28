# FileDrop

Fetch files from your local Mac into a remote server terminal. Drag-drop a file into your terminal, the agent fetches it via SSH reverse tunnel.

Works with Claude Code, Codex, OpenCode, Cursor, Windsurf, and any agent that supports [SKILL.md](https://skills.sh).

## Setup

On your Mac:

```bash
git clone https://github.com/onecuriousmindset/filedrop.git ~/filedrop
cd ~/filedrop && ./install.sh
```

Follow the steps it prints.

## Usage

### With any AI agent

Drag a file from Finder into your terminal. It pastes the local Mac path. Just send it as a message — the agent recognizes the path, fetches the file, and reads it automatically.

### Manual

```bash
fetch-file "/Users/you/Desktop/Screenshot 2026-02-27.png"
```

## Security

- Server binds to `localhost` only — not network-accessible
- Tunnel only exists while your SSH session is active
- Whitelisted directories: `~/Desktop`, `~/Screenshots`, `~/Downloads`, `~/Documents/Screenshots`, `/var/folders`
- Whitelisted extensions: images, PDFs, videos only
- Auth token required on every request

## Uninstall

Mac:
```bash
launchctl unload ~/Library/LaunchAgents/com.filedrop.server.plist
rm ~/Library/LaunchAgents/com.filedrop.server.plist
```

Remote server:
```bash
rm ~/bin/fetch-file ~/.filedrop-token
rm -rf ~/.agents/skills/fetch-file ~/.claude/skills/fetch-file ~/.config/opencode/skills/fetch-file
```

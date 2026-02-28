# FileDrop

Fetch files from your local Mac into a remote server terminal. Drag-drop a file into iTerm2, the agent fetches it via SSH reverse tunnel.

Works with Claude Code, Codex, OpenCode, Cursor, Windsurf, and any agent that supports [SKILL.md](https://skills.sh).

## Setup

### 1. Mac (one-time)

```bash
git clone https://github.com/onecuriousmindset/filedrop.git ~/filedrop
cd ~/filedrop && ./install.sh
```

This generates a fixed token, installs a LaunchAgent that auto-starts FileDrop on login, and survives sleep/wake. Note down the token it prints — you'll need it for step 3.

### 2. SSH config (~/.ssh/config)

Add `RemoteForward` to your server entry:

```
# Replace "myserver" with whatever alias you want to use for `ssh myserver`
# Replace "1.2.3.4" with your server's actual IP or hostname
Host myserver
    HostName 1.2.3.4
    RemoteForward 8856 localhost:8856
```

### 3. Remote server (one-time)

Clone the repo and run the setup script with the token from step 1:

```bash
git clone https://github.com/onecuriousmindset/filedrop.git ~/filedrop
cd ~/filedrop && ./setup-server.sh REPLACE_WITH_YOUR_TOKEN
```

This installs the `fetch-file` command and registers the skill for all supported agents.

Or install just the skill via [skills.sh](https://skills.sh):

```bash
npx skills add onecuriousmindset/filedrop
```

Note: `npx skills add` only installs the skill file. You still need to run `setup-server.sh` for the `fetch-file` command and token.

## Usage

### With any AI agent

Drag a file from Finder into your iTerm2 terminal. It pastes the local Mac path. Just send it as a message — the agent recognizes the path, fetches the file, and reads it automatically.

### Manual (without an agent)

```bash
fetch-file "/Users/you/Desktop/Screenshot 2026-02-27.png"
```

Prints the remote path where the file was saved (e.g. `~/filedrop/20260228_131601_Screenshot.png`).

## Security

- Server binds to `localhost` only — not network-accessible
- Tunnel only exists while your SSH session is active
- Whitelisted directories: `~/Desktop`, `~/Screenshots`, `~/Downloads`, `~/Documents/Screenshots`, `/var/folders` (macOS temp)
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

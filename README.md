# FileDrop

Fetch files from your local Mac into a remote server terminal. Drag-drop a file into iTerm2, the agent fetches it via SSH reverse tunnel.

## Setup

### 1. Mac (one-time)

```bash
git clone git@github.com:onecuriousmindset/filedrop.git ~/filedrop
cd ~/filedrop && ./install.sh
```

This generates a fixed token, installs a LaunchAgent that auto-starts FileDrop on login, and survives sleep/wake.

### 2. SSH config (~/.ssh/config)

Add `RemoteForward` to your server entry:

```
Host myserver
    HostName ...
    RemoteForward 8856 localhost:8856
```

### 3. Remote server (one-time)

```bash
# Save the token (printed by install.sh)
echo "THE_TOKEN" > ~/.filedrop-token && chmod 600 ~/.filedrop-token

# Install fetch-file command
cp ~/filedrop/fetch-file ~/bin/fetch-file
chmod +x ~/bin/fetch-file
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# Install Claude Code skill
mkdir -p ~/.claude/skills/fetch-file
cp ~/filedrop/SKILL.md ~/.claude/skills/fetch-file/SKILL.md
```

## Usage

Drag a file into iTerm2. It pastes the local path. Send it. The agent fetches and reads it automatically.

Manual:

```bash
fetch-file "/Users/you/Desktop/Screenshot 2026-02-27.png"
```

## Security

- Server binds to `localhost` only — not network-accessible
- Tunnel only exists while your SSH session is active
- Whitelisted directories: `~/Desktop`, `~/Screenshots`, `~/Downloads`, `~/Documents/Screenshots`, `/var/folders` (macOS temp)
- Whitelisted extensions: images, PDFs, videos only
- Auth token required on every request

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.filedrop.server.plist
rm ~/Library/LaunchAgents/com.filedrop.server.plist
```

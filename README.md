# FileDrop

Fetch files from your local Mac into a remote server terminal. Drag-drop a file into iTerm2, the agent fetches it via SSH reverse tunnel.

## Setup

### 1. Mac (one-time)

```bash
git clone git@github.com:onecuriousmindset/filedrop.git ~/filedrop
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
git clone git@github.com:onecuriousmindset/filedrop.git ~/filedrop
cd ~/filedrop && ./setup-server.sh REPLACE_WITH_YOUR_TOKEN
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

Mac:
```bash
launchctl unload ~/Library/LaunchAgents/com.filedrop.server.plist
rm ~/Library/LaunchAgents/com.filedrop.server.plist
```

Remote server:
```bash
rm ~/bin/fetch-file ~/.filedrop-token
rm -rf ~/.claude/skills/fetch-file
```

# FileDrop

Fetch files from your local Mac into a remote server terminal. Drag-drop a file into iTerm2, the agent fetches it via SSH reverse tunnel.

## Setup

### 1. Mac (one-time)

Clone this repo somewhere on your Mac:

```bash
git clone git@github.com:onecuriousmindset/filedrop.git ~/filedrop
```

### 2. SSH config (~/.ssh/config)

Add the reverse tunnel to your server entry:

```
Host myserver
    HostName ...
    RemoteForward 8856 localhost:8856
```

### 3. Remote server (one-time)

```bash
# Copy the fetch script and make it available
cp ~/filedrop/fetch-file ~/bin/fetch-file
chmod +x ~/bin/fetch-file
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# Install the Claude Code skill
mkdir -p ~/.claude/skills/fetch-file
cp ~/filedrop/SKILL.md ~/.claude/skills/fetch-file/SKILL.md
```

## Usage

### Start the Mac server

```bash
python3 ~/filedrop/mac-server.py
```

It prints a token. Copy it to the remote server:

```bash
echo "THE_TOKEN" > ~/.filedrop-token
chmod 600 ~/.filedrop-token
```

You only need to redo this if the token changes (it regenerates each time unless you pass `--token`).

### In Claude Code

Drag a file into iTerm2. It pastes the local path. Send it. The agent fetches and reads it automatically.

Manual usage:

```bash
fetch-file "/Users/you/Desktop/Screenshot 2026-02-27.png"
```

## Security

- Server binds to `localhost` only — not network-accessible
- Tunnel only exists while your SSH session is active
- Whitelisted directories: `~/Desktop`, `~/Screenshots`, `~/Downloads`, `~/Documents/Screenshots`
- Whitelisted extensions: images, PDFs, videos only
- Auth token required on every request

## Options

```bash
python3 mac-server.py --token fixedtoken  # Reuse same token across restarts
python3 mac-server.py --port 9999         # Different port
python3 mac-server.py --show-dirs         # Show allowed directories
```

# FileDrop

Fetch files from your local Mac into a remote server terminal. Drag-drop a file into your terminal, the agent fetches it via SSH reverse tunnel.

Works with Claude Code, Codex, OpenCode, Gemini CLI, and any terminal-based agent that supports [SKILL.md](https://skills.sh).

## Setup

On your Mac:

```bash
git clone https://github.com/onecuriousmindset/filedrop.git ~/filedrop
cd ~/filedrop && ./install.sh
```

Follow the steps it prints. Default port is `8857`. If that's taken, use `./install.sh --port 9999`.

**Important:** Your terminal app (iTerm2, Ghostty, etc.) needs **Full Disk Access** to support drag-and-drop screenshots. macOS stores screenshots in a protected temp directory (`/var/folders/.../NSIRD_screencaptureui_*/`) that no app can read without this permission.

Go to **System Settings > Privacy & Security > Full Disk Access** and enable your terminal app. Files from `~/Desktop` or `~/Downloads` work without this.

## Usage

### With any AI agent

Drag a file from Finder into your terminal. It pastes the local Mac path. Just send it as a message — the agent recognizes the path, fetches the file, and reads it automatically.

If the agent doesn't pick up the skill and says it can't access the file, add this to your `CLAUDE.md` (or `AGENTS.md` for Codex):

```
When running on this remote server, if the user pastes a macOS file path
(starting with /Users/ or /var/folders/), use the `fetch-file` skill to
retrieve the file from their local Mac via the SSH reverse tunnel.
Do not tell the user the file doesn't exist locally — instead, fetch it first.
```

### Manual

```bash
fetch-file "/Users/you/Desktop/Screenshot 2026-02-27.png"
```

## Security

- Server only runs when your terminal is open — not a background daemon
- Server binds to `localhost` only — not network-accessible
- Tunnel only exists while your SSH session is active
- Whitelisted directories: `~/Desktop`, `~/Screenshots`, `~/Downloads`, `~/Documents/Screenshots`, `/var/folders`
- Whitelisted extensions: images, PDFs, videos only
- Auth token required on every request

## Uninstall

Mac:
```bash
cd ~/filedrop && ./uninstall.sh
```

Remote server:
```bash
cd ~/filedrop && ./uninstall-server.sh
```

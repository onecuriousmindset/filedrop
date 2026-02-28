---
name: fetch-file
description: Fetch files from the user's local Mac when they share a macOS file path (starting with /Users/). The file is pulled via SSH reverse tunnel and saved locally for viewing.
user-invocable: true
argument-hint: /Users/.../file.png
allowed-tools: Bash, Read
---

# Fetch File from Local Mac (FileDrop)

When the user provides a **macOS file path** (starting with `/Users/`), they want you to fetch that file from their local machine.

## How it works

A reverse SSH tunnel connects this server back to the user's Mac. The `fetch-file` command pulls files through it.

## Steps

1. Run: `fetch-file "<the_mac_path>"`
2. The command prints the **remote path** where the file was saved (in `~/filedrop/`)
3. Use the `Read` tool on that remote path to view the image
4. Respond to the user about what you see

## Example

User sends: `/Users/john/Desktop/Screenshot 2026-02-27 at 14.30.00.png`

```bash
fetch-file "/Users/john/Desktop/Screenshot 2026-02-27 at 14.30.00.png"
```

Output: `/home/agent/filedrop/20260227_143512_Screenshot_2026-02-27_at_14.30.00.png`

Then read that file with the Read tool to see the image.

## Troubleshooting

If `fetch-file` fails:
- **Connection refused**: The SSH tunnel may not be active, or the Mac-side server isn't running. Ask the user to check.
- **401 Unauthorized**: Token mismatch. Ask the user to verify the token in `~/.filedrop-token`.
- **403 Forbidden**: The file is outside allowed directories (Desktop, Screenshots, Downloads) or has a disallowed extension.

## Notes

- Files are saved to `~/filedrop/` with a timestamp prefix
- Only image/video/pdf files from Desktop, Screenshots, and Downloads are allowed
- The tunnel must be active (user's SSH session includes the reverse port forward)

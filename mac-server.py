#!/usr/bin/env python3
"""
FileDrop - Mac-side file server.

Serves local files over HTTP for retrieval from a remote server via SSH reverse tunnel.
Restricted to specific directories and file extensions for security.

Usage:
    python3 mac-server.py                    # Start with auto-generated token
    python3 mac-server.py --token mysecret   # Start with specific token
    python3 mac-server.py --port 8856        # Custom port

Then SSH to your remote server with reverse tunnel:
    ssh -R 8856:localhost:8856 user@server
"""

import http.server
import json
import os
import sys
import argparse
import secrets
import urllib.parse
from pathlib import Path
from datetime import datetime

# --- Configuration ---

DEFAULT_PORT = 8856

ALLOWED_DIRS = [
    Path.home() / "Desktop",
    Path.home() / "Screenshots",
    Path.home() / "Downloads",
    Path.home() / "Documents" / "Screenshots",
    Path("/var/folders"),
]

ALLOWED_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".tiff",
    ".pdf", ".svg", ".heic", ".heif",
    ".mp4", ".mov", ".webm",
}

MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

# --- Server ---

AUTH_TOKEN = None


def is_path_allowed(file_path: Path) -> tuple[bool, str]:
    """Check if a file path is allowed to be served."""
    try:
        resolved = file_path.resolve()
    except (OSError, ValueError):
        return False, "invalid path"

    if not resolved.is_file():
        return False, "file not found"

    # Check directory whitelist
    in_allowed_dir = False
    for allowed_dir in ALLOWED_DIRS:
        try:
            resolved.relative_to(allowed_dir.resolve())
            in_allowed_dir = True
            break
        except ValueError:
            continue

    if not in_allowed_dir:
        allowed = ", ".join(str(d) for d in ALLOWED_DIRS)
        return False, f"path not in allowed directories: {allowed}"

    # Check extension
    ext = resolved.suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        return False, f"extension '{ext}' not allowed"

    # Check file size
    size = resolved.stat().st_size
    if size > MAX_FILE_SIZE:
        return False, f"file too large ({size // 1024 // 1024}MB, max {MAX_FILE_SIZE // 1024 // 1024}MB)"

    return True, "ok"


class FileDropHandler(http.server.BaseHTTPRequestHandler):

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        params = urllib.parse.parse_qs(parsed.query)

        if path == "/health":
            self._json(200, {"status": "ok", "timestamp": datetime.now().isoformat()})
            return

        if path == "/":
            self._json(200, {
                "service": "filedrop",
                "endpoints": {
                    "/health": "Health check",
                    "/fetch?path=<local_path>": "Fetch a file (requires auth)",
                },
            })
            return

        if path == "/fetch":
            # Auth check
            auth = self.headers.get("Authorization", "")
            if auth != f"Bearer {AUTH_TOKEN}":
                self._json(401, {"error": "unauthorized"})
                return

            # Get file path
            file_path_str = params.get("path", [None])[0]
            if not file_path_str:
                self._json(400, {"error": "missing 'path' parameter"})
                return

            file_path = Path(file_path_str)
            allowed, reason = is_path_allowed(file_path)
            if not allowed:
                self._json(403, {"error": reason})
                return

            # Serve the file
            resolved = file_path.resolve()
            try:
                data = resolved.read_bytes()
            except OSError as e:
                self._json(500, {"error": str(e)})
                return

            ext = resolved.suffix.lower()
            content_types = {
                ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
                ".gif": "image/gif", ".webp": "image/webp", ".bmp": "image/bmp",
                ".tiff": "image/tiff", ".pdf": "application/pdf", ".svg": "image/svg+xml",
                ".heic": "image/heic", ".heif": "image/heif",
                ".mp4": "video/mp4", ".mov": "video/quicktime", ".webm": "video/webm",
            }
            content_type = content_types.get(ext, "application/octet-stream")

            self.send_response(200)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("X-Original-Path", str(resolved))
            self.send_header("X-Filename", resolved.name)
            self.end_headers()
            self.wfile.write(data)
            print(f"  Served: {resolved} ({len(data)} bytes)")
            return

        self._json(404, {"error": "not found"})

    def _json(self, code, data):
        body = json.dumps(data).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        # Only log errors, not every request
        if args and str(args[0]).startswith("4") or str(args[0]).startswith("5"):
            super().log_message(format, *args)


def main():
    global AUTH_TOKEN

    parser = argparse.ArgumentParser(description="FileDrop - Mac file server")
    parser.add_argument("-p", "--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("-t", "--token", type=str, default=None,
                        help="Auth token (auto-generated if not set)")
    parser.add_argument("--show-dirs", action="store_true",
                        help="Show allowed directories and exit")
    args = parser.parse_args()

    if args.show_dirs:
        print("Allowed directories:")
        for d in ALLOWED_DIRS:
            exists = "  (exists)" if d.exists() else "  (not found)"
            print(f"  {d}{exists}")
        print(f"\nAllowed extensions: {', '.join(sorted(ALLOWED_EXTENSIONS))}")
        sys.exit(0)

    AUTH_TOKEN = args.token or secrets.token_urlsafe(32)

    # Write token to a file for easy retrieval
    token_file = Path(__file__).parent / ".filedrop-token"
    token_file.write_text(AUTH_TOKEN)
    token_file.chmod(0o600)

    print("FileDrop")
    print(f"  Port:  {args.port}")
    print(f"  Token: {AUTH_TOKEN}")
    print(f"  Token saved to: {token_file}")
    print()
    print("Allowed directories:")
    for d in ALLOWED_DIRS:
        if d.exists():
            print(f"  {d}")
    print()
    print("SSH tunnel command:")
    print(f"  ssh -R {args.port}:localhost:{args.port} user@server")
    print()
    print("Waiting for requests... (Ctrl+C to stop)")
    print()

    server = http.server.HTTPServer(("127.0.0.1", args.port), FileDropHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
        server.server_close()


if __name__ == "__main__":
    main()

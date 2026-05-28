#!/usr/bin/env bash
# Serve the Unity WebGL build at <project>/Build over HTTP (avoids file:// CORS issues).
# Usage: ./.scripts/run-local-build.sh [port]

set -euo pipefail

PORT="${1:-8989}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/Build"

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "Build folder not found: $BUILD_DIR" >&2
  echo "Build WebGL to <project>/Build first (File > Build Settings > Build)." >&2
  exit 1
fi

if [[ ! -f "$BUILD_DIR/index.html" ]]; then
  echo "index.html not found in $BUILD_DIR" >&2
  echo "Build WebGL to <project>/Build first." >&2
  exit 1
fi

find_python() {
  local cmd major
  for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
      major="$("$cmd" -c 'import sys; print(sys.version_info[0])' 2>/dev/null)" || continue
      if [[ "$major" == "3" ]]; then
        echo "$cmd"
        return 0
      fi
    fi
  done
  return 1
}

if ! PYTHON="$(find_python)"; then
  echo ""
  echo "Python 3 is not installed or not on PATH."
  echo ""
  echo "Install Python 3 from https://www.python.org/downloads/"
  echo "  macOS:   brew install python3"
  echo "  Ubuntu:  sudo apt install python3"
  echo ""
  echo "Then run this script again."
  echo ""
  exit 1
fi

URL="http://localhost:${PORT}/"
echo ""
echo "Serving WebGL build from:"
echo "  $BUILD_DIR"
echo ""
echo "Opening in your default browser:"
echo "  $URL"
echo ""
echo "Press Ctrl+C to stop the server."
echo ""

# Bash: xdg-open (Linux), open (macOS), or cmd.exe //c start (Git Bash on Windows)
if command -v xdg-open >/dev/null 2>&1; then xdg-open "$URL" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then open "$URL" >/dev/null 2>&1 &
elif command -v cmd.exe >/dev/null 2>&1; then cmd.exe //c start "" "$URL" >/dev/null 2>&1 &
fi

cd "$BUILD_DIR"
exec "$PYTHON" -m http.server "$PORT"

#!/bin/bash
# Start Vite development server
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: cmd-dev.sh <directory>"
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "Error: No package.json found in $DIR"
    exit 1
fi

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache="${HOME}/.npm-cache"

echo "Starting development server in $DIR..."
echo "Note: Server will run on http://localhost:5173 by default"
npm run dev

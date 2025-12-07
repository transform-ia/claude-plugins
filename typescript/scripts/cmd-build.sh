#!/bin/bash
# Build TypeScript/React project
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: cmd-build.sh <directory>"
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "Error: No package.json found in $DIR"
    exit 1
fi

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache=/workspace/.npm-cache

echo "Building project in $DIR..."
npm run build

echo "Build completed successfully!"

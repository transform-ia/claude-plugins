#!/bin/bash
# Install npm dependencies
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: cmd-install.sh <directory>"
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "Error: No package.json found in $DIR"
    exit 1
fi

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache=/workspace/.npm-cache

echo "Installing dependencies in $DIR..."
npm install

echo "Dependencies installed successfully!"

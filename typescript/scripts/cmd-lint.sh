#!/bin/bash
# Run ESLint on TypeScript project
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: cmd-lint.sh <directory>"
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "Error: No package.json found in $DIR"
    exit 1
fi

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache="${HOME}/.npm-cache"

echo "Running ESLint in $DIR..."
npm run lint || {
    echo ""
    echo "Lint errors found. Fix the issues above."
    exit 1
}

echo "Lint passed!"

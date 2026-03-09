#!/bin/bash
# Run TypeScript type checking
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: cmd-typecheck.sh <directory>"
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "Error: No package.json found in $DIR"
    exit 1
fi

if [[ ! -f "$DIR/tsconfig.json" ]]; then
    echo "Error: No tsconfig.json found in $DIR"
    exit 1
fi

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache="${HOME}/.npm-cache"

echo "Running TypeScript type check in $DIR..."
npx tsc --noEmit || {
    echo ""
    echo "Type errors found. Fix the issues above."
    exit 1
}

echo "Type check passed!"

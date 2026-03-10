#!/bin/bash
# Run GraphQL Codegen
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: gql-types.sh <directory>"
    exit 1
fi

if [[ ! -f "$DIR/package.json" ]]; then
    echo "Error: No package.json found in $DIR"
    exit 1
fi

if [[ ! -f "$DIR/codegen.ts" ]]; then
    echo "Error: No codegen.ts found in $DIR"
    echo "Create codegen.ts with your GraphQL Codegen configuration"
    exit 1
fi

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache="${HOME}/.npm-cache"

echo "Running GraphQL Codegen in $DIR..."
npm run codegen || {
    echo ""
    echo "Codegen failed. Check your GraphQL endpoint and configuration."
    exit 1
}

echo "GraphQL types generated successfully!"

#!/bin/bash
# Initialize a Vite + React + TypeScript project
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
    echo "Error: directory required"
    echo "Usage: vite-init.sh <directory>"
    exit 1
fi

# Ensure directory exists
mkdir -p "$DIR"

cd "$DIR"

# Set npm cache to writable location
export npm_config_cache="${HOME}/.npm-cache"

# Check if already initialized
if [[ -f "package.json" ]]; then
    echo "Project already initialized at $DIR"
    exit 0
fi

echo "Initializing Vite + React + TypeScript project in $DIR..."

# Initialize with Vite
npm create vite@latest . -- --template react-ts --yes

# Install base dependencies
npm install

# Install additional dependencies
npm install \
    @apollo/client \
    @emotion/react \
    @emotion/styled \
    @hookform/resolvers \
    @mui/icons-material \
    @mui/material \
    @mui/x-data-grid \
    @mui/x-date-pickers \
    date-fns \
    graphql \
    react-hook-form \
    react-router-dom \
    zod

# Install dev dependencies for GraphQL Codegen
npm install -D \
    @graphql-codegen/cli \
    @graphql-codegen/typescript \
    @graphql-codegen/typescript-operations \
    @graphql-codegen/typescript-react-apollo

# Create directory structure
mkdir -p src/{config,generated,graphql/{fragments,queries,mutations},components,pages,hooks,utils}

echo "Project initialized successfully!"
echo ""
echo "Next steps:"
echo "1. Configure src/config/apollo.ts with your GraphQL endpoint"
echo "2. Configure src/config/theme.ts with your theme"
echo "3. Create codegen.ts for GraphQL Codegen"
echo "4. Add .env with VITE_GRAPHQL_ENDPOINT"

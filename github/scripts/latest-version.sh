#!/bin/bash
# Get latest semantic version tag from a git repository
# Usage: latest-version-exec.sh <path>
set -euo pipefail

# === SECTION 1: Argument Parsing ===

if [[ -z "${1:-}" ]]; then
    echo "Usage: /github:latest-version <path>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /github:latest-version ~/my-project" >&2
    echo "  /github:latest-version ." >&2
    exit 1
fi

PATH_ARG="$1"

# === SECTION 2: Validate Directory and Git Repository ===

# Change to directory
cd "$PATH_ARG" 2>/dev/null || {
    echo "Error: Cannot access directory: $PATH_ARG" >&2
    exit 1
}

# Verify it's a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not a git repository: $PATH_ARG" >&2
    exit 1
fi

# === SECTION 3: Get Latest Semantic Version Tag ===

# List all tags, filter semantic versions, sort properly, get highest
LATEST=$(git tag -l | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

# === SECTION 4: Output Result ===

if [[ -z "$LATEST" ]]; then
    echo "v0.0.0"
else
    echo "$LATEST"
fi

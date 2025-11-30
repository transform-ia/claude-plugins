#!/bin/bash
# Query GitHub Actions workflow status using gh CLI
# Usage: status-exec.sh <owner/repo> [limit]
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /github:status <owner/repo> [limit]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /github:status transform-ia/hooks" >&2
    echo "  /github:status transform-ia/hooks 10" >&2
    exit 1
fi

REPO="$1"
LIMIT="${2:-5}"

echo "Workflow runs for $REPO:"
echo "---"
gh run list --repo "$REPO" --limit "$LIMIT"

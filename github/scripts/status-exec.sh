#!/bin/bash
# Query GitHub Actions workflow status using gh CLI
set -euo pipefail

REPO="${1:-}"
LIMIT="${2:-5}"

# If no repo specified, try to detect from git remote
if [[ -z "$REPO" ]]; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$REMOTE_URL" ]]; then
        # Extract owner/repo from URL
        REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$|\1|')
    fi
fi

if [[ -z "$REPO" ]]; then
    echo "Usage: /github:status <owner/repo> [limit]" >&2
    echo "Or run from a directory with git remote set to GitHub" >&2
    exit 1
fi

echo "Workflow runs for $REPO:"
echo "---"
gh run list --repo "$REPO" --limit "$LIMIT"

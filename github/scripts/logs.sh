#!/bin/bash
# Get logs for a GitHub Actions workflow run
set -euo pipefail

RUN_ID="${1:-}"
REPO="${2:-}"

if [[ -z "$RUN_ID" ]]; then
    echo "Usage: /github:logs <run-id> [owner/repo]" >&2
    exit 1
fi

# If no repo specified, try to detect from git remote
if [[ -z "$REPO" ]]; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$REMOTE_URL" ]]; then
        REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$|\1|')
    fi
fi

if [[ -z "$REPO" ]]; then
    echo "Error: Cannot determine repository. Specify as second argument." >&2
    exit 1
fi

echo "Logs for run $RUN_ID in $REPO:"
echo "---"
gh run view "$RUN_ID" --repo "$REPO" --log-failed 2>/dev/null || \
gh run view "$RUN_ID" --repo "$REPO" --log

#!/bin/bash
# Push code and wait for ALL GitHub Actions workflows to complete
# Usage: push-and-wait.sh [owner/repo]
set -euo pipefail

# === SECTION 1: Repository Detection ===
REPO="${1:-}"

if [[ -z "$REPO" ]]; then
    # Auto-detect from git remote
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$REMOTE_URL" ]]; then
        REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$|\1|')
    fi
fi

if [[ -z "$REPO" ]]; then
    echo "Error: Cannot detect repository. Usage: /github:push-and-wait [owner/repo]" >&2
    exit 1
fi

# === SECTION 2: Pre-flight Checks ===

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Commit or stash before building." >&2
    echo "" >&2
    git status --short >&2
    exit 1
fi

# Get current commit SHA (before push, in case push fails)
CURRENT_SHA=$(git rev-parse HEAD)

# === SECTION 3: Git Push ===

echo "Pushing to $REPO..."
git push origin HEAD

echo "Push completed. Commit SHA: $CURRENT_SHA"
echo ""

# === SECTION 4: Wait for Workflow Triggers ===

echo "Waiting for GitHub Actions to trigger workflows..."
sleep 10  # Give GitHub time to trigger workflows

# === SECTION 5: Find All Workflow Runs for This Commit ===

echo "Finding workflow runs for commit $CURRENT_SHA..."

# Get all runs for this commit
RUNS_JSON=$(gh run list --repo "$REPO" --commit "$CURRENT_SHA" --json databaseId,workflowName,status,conclusion --limit 100)

# Count runs
RUN_COUNT=$(echo "$RUNS_JSON" | jq '. | length')

if [[ "$RUN_COUNT" -eq 0 ]]; then
    echo "Warning: No workflows found for commit $CURRENT_SHA" >&2
    echo "This repository may not have any GitHub Actions workflows configured." >&2
    exit 0  # Not an error, just no workflows
fi

echo "Found $RUN_COUNT workflow run(s) for this commit"
echo ""

# Extract run IDs and names
RUN_IDS=$(echo "$RUNS_JSON" | jq -r '.[].databaseId')

# === SECTION 6: Monitor All Runs ===

echo "Monitoring workflows (no timeout, will wait indefinitely):"
echo "---"

# Display initial status
echo "$RUNS_JSON" | jq -r '.[] | "  - \(.workflowName): \(.status)"'
echo ""

# Watch each run (in parallel background processes)
PIDS=()
FAILED_RUNS=()

for RUN_ID in $RUN_IDS; do
    RUN_NAME=$(echo "$RUNS_JSON" | jq -r ".[] | select(.databaseId == $RUN_ID) | .workflowName")

    echo "Watching: $RUN_NAME (ID: $RUN_ID)..."

    # Watch run in background, capture exit code
    (
        gh run watch "$RUN_ID" --repo "$REPO" --exit-status >/dev/null 2>&1
        echo $? > "/tmp/run-${RUN_ID}.exit"
    ) &

    PIDS+=($!)
done

# Wait for all background processes
echo "Waiting for all workflows to complete..."
for PID in "${PIDS[@]}"; do
    wait "$PID"
done

# === SECTION 7: Check Results ===

echo ""
echo "All workflows completed. Checking results..."
echo "---"

ALL_SUCCESS=true

for RUN_ID in $RUN_IDS; do
    RUN_NAME=$(echo "$RUNS_JSON" | jq -r ".[] | select(.databaseId == $RUN_ID) | .workflowName")
    EXIT_CODE=$(cat "/tmp/run-${RUN_ID}.exit" 2>/dev/null || echo "1")

    # Get final status
    FINAL_JSON=$(gh run view "$RUN_ID" --repo "$REPO" --json conclusion,status)
    CONCLUSION=$(echo "$FINAL_JSON" | jq -r '.conclusion')
    STATUS=$(echo "$FINAL_JSON" | jq -r '.status')

    if [[ "$CONCLUSION" == "success" ]]; then
        echo "✓ $RUN_NAME: SUCCESS"
    else
        echo "✗ $RUN_NAME: FAILED ($CONCLUSION)" >&2
        FAILED_RUNS+=("$RUN_ID|$RUN_NAME")
        ALL_SUCCESS=false
    fi

    # Cleanup temp file
    rm -f "/tmp/run-${RUN_ID}.exit"
done

echo ""

# === SECTION 8: Report Results ===

if [[ "$ALL_SUCCESS" == "true" ]]; then
    echo "SUCCESS: All workflows passed for commit $CURRENT_SHA"
    exit 0
else
    echo "FAILURE: Some workflows failed" >&2
    echo "" >&2
    echo "Failed workflows:" >&2

    for FAILED in "${FAILED_RUNS[@]}"; do
        RUN_ID="${FAILED%%|*}"
        RUN_NAME="${FAILED##*|}"

        echo "" >&2
        echo "=== $RUN_NAME (ID: $RUN_ID) ===" >&2
        gh run view "$RUN_ID" --repo "$REPO" --log-failed 2>&1 | head -100 >&2
    done

    exit 1
fi

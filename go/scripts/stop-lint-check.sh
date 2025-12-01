#!/bin/bash
# Stop hook: Auto-lint Go files after completion
# Uses kubectl to run golangci-lint in the dev pod
#
# Exit codes (per Claude Code docs):
#   0 = Success - linting passed or not applicable
#   2 = BLOCKING error - lint failures that must be fixed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read hook input from stdin
input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"

# Detect caller from transcript - only run for /go:* commands
# Test mode: use TEST_CALLER env var
if [[ -n "${TEST_CALLER:-}" ]]; then
    caller="$TEST_CALLER"
# Production mode: require transcript and use detect-caller.py
elif [[ -z "$transcript_path" ]]; then
    # No transcript = not in plugin context (skip)
    exit 0
else
    # Verify detect-caller.py exists and is executable
    if [[ ! -x "$DETECT_CALLER" ]]; then
        echo "HOOK ERROR: detect-caller.py not found or not executable" >&2
        echo "Path: $DETECT_CALLER" >&2
        exit 2
    fi

    # Call detect-caller.py - fail-closed on script failure
    if ! caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>&1); then
        echo "HOOK ERROR: Caller detection failed" >&2
        echo "Output: $caller" >&2
        exit 2
    fi
fi

# Empty caller = not from plugin command (skip)
if [[ -z "$caller" ]] || [[ "$caller" != /go:* ]]; then
    exit 0
fi

# Find git root from cwd
if [[ -z "$cwd" ]]; then
    cwd="/workspace"
fi

root=$("$SCRIPT_DIR/find-git-root.sh" "$cwd" 2>/dev/null) || {
    echo "No git repository found, skipping Go lint."
    exit 0
}

# Check for go.mod (we're in a Go project)
if [[ ! -f "$root/go.mod" ]]; then
    echo "No go.mod found at git root, skipping Go lint."
    exit 0
fi

# Check for modified Go files
MODIFIED_FILES=$(git -C "$root" diff --name-only --diff-filter=AM 2>/dev/null | grep -E '\.go$' || true)

if [[ -z "$MODIFIED_FILES" ]]; then
    echo "No modified Go files to lint."
    exit 0
fi

# Find the dev pod for this project
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root" 2>/dev/null) || {
    echo "No Go dev pod found for $root, skipping lint."
    echo "Deploy a golang-chart for this project to enable auto-linting."
    exit 0
}

echo "Linting Go files in $root using pod $pod..."

ERRORS=0

# Format first
echo "=== golangci-lint fmt ==="
kubectl exec "$pod" -- golangci-lint fmt ./... 2>&1 || true

# Lint with fixes
echo ""
echo "=== golangci-lint run --fix ==="
kubectl exec "$pod" -- golangci-lint run --fix ./... || ERRORS=1

if [[ $ERRORS -ne 0 ]]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "LINT ERRORS: Please fix the issues above before completing."
    echo "═══════════════════════════════════════════════════════════════"
    exit 2  # Exit 2 = BLOCKING error (stops Claude)
fi

exit 0

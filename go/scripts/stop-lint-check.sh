#!/bin/bash
# Stop hook: Auto-lint Go files before completion
# Uses kubectl to run golangci-lint in the dev pod
set -euo pipefail

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/go"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read hook input from stdin
input=$(cat)

# Detect caller from transcript - only run for /go:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /go:* ]]; then
    exit 0  # Not from Go plugin command, skip
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
fi

exit $ERRORS

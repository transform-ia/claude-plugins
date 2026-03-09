#!/bin/bash
# Stop hook: Auto-lint Go files after completion
# Runs golangci-lint locally
#
# Exit codes (per Claude Code docs):
#   0 = Success - linting passed or not applicable
#   2 = BLOCKING error - lint failures that must be fixed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DETECT_CALLER="$(cd "$PLUGIN_ROOT/../scripts" && pwd)/detect-caller.py"

# Read hook input from stdin
input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

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
    cwd="."
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

# Verify golangci-lint is available locally
command -v golangci-lint >/dev/null 2>&1 || {
    echo "golangci-lint not found locally, skipping lint."
    echo "Install: https://golangci-lint.run/welcome/install/"
    exit 0
}

echo "Linting Go files in $root..."

ERRORS=0

cd "$root"

# Format first
echo "=== golangci-lint fmt ==="
golangci-lint fmt ./... 2>&1 || true

# Lint with fixes
echo ""
echo "=== golangci-lint run --fix ==="
golangci-lint run --fix ./... || ERRORS=1

if [[ $ERRORS -ne 0 ]]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "LINT ERRORS: Please fix the issues above before completing."
    echo "═══════════════════════════════════════════════════════════════"
    exit 2  # Exit 2 = BLOCKING error (stops Claude)
fi

exit 0

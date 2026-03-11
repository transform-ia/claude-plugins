#!/bin/bash
# Stop hook: Auto-lint Go files after completion
# Runs golangci-lint locally
#
# Exit codes (per Claude Code docs):
#   0 = Success - linting passed or not applicable
#   2 = BLOCKING error - lint failures that must be fixed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read hook input from stdin
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')

# Find git root from cwd
if [[ -z "$cwd" ]]; then
    cwd="."
fi

root=$("$SCRIPT_DIR/find-git-root.sh" "$cwd" 2>/dev/null) || {
    exit 0
}

# Only run in Go projects
if [[ ! -f "$root/go.mod" ]]; then
    exit 0
fi

# Only run when Go files were actually modified
MODIFIED_FILES=$(git -C "$root" diff --name-only --diff-filter=AM 2>/dev/null | grep -E '\.go$' || true)

if [[ -z "$MODIFIED_FILES" ]]; then
    exit 0
fi

# Verify golangci-lint is available
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

#!/bin/bash
# Stop hook: Run linter before agent stops
# If lint fails, block stopping and force agent to fix issues
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success) - lint passed, agent can stop
#   2 = BLOCKING error - lint failed, agent must fix issues
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in stop-lint-check.sh" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in a Go project
if [[ ! -f "go.mod" ]]; then
    exit 0  # Not a Go project, allow stop
fi

# Run linter via the plugin script
# Capture both stdout and stderr, and the exit code separately
set +e  # Temporarily disable errexit to capture exit code
output=$("$SCRIPT_DIR/lint-exec.sh" 2>&1)
lint_exit_code=$?
set -e  # Re-enable errexit

if [[ $lint_exit_code -ne 0 ]]; then
    # Lint failed - block stopping, agent must fix
    echo "BLOCKED: Linter found issues that must be fixed before completing:" >&2
    echo "$output" >&2
    exit 2  # Block - agent continues to fix
fi

exit 0  # Lint passed - allow stop

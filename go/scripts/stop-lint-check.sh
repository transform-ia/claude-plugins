#!/bin/bash
# Stop hook: Run linter before agent stops
# If lint fails, block stopping and force agent to fix issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in a Go project
if [[ ! -f "go.mod" ]]; then
    exit 0  # Not a Go project, allow stop
fi

# Run linter via the plugin script
output=$("$SCRIPT_DIR/lint-exec.sh" 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    # Lint failed - block stopping, agent must fix
    echo "Linter found issues that must be fixed before completing:" >&2
    echo "$output" >&2
    exit 2  # Block - agent continues to fix
fi

exit 0  # Lint passed - allow stop

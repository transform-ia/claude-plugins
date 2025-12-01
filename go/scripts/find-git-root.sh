#!/bin/bash
# Find git repository root from given directory
# Usage: find-git-root.sh <directory>
#
# Exit codes (per Claude Code docs):
#   0 = Success - prints git root to stdout
#   2 = BLOCKING error - not in a git repository

set -euo pipefail

dir="${1:?ERROR: Directory argument required}"

root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || {
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: Not inside a git repository: $dir" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    echo "Please navigate to a git repository or clone one first." >&2
    echo "" >&2
    exit 2
}

echo "$root"

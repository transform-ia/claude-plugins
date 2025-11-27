#!/bin/bash
# Find git repository root from current or given directory
# Usage: find-git-root.sh [directory]
# Exit 1 if not in a git repo

dir="${1:-$PWD}"
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$root" ]]; then
    echo "ERROR: Not inside a git repository." >&2
    echo "Please navigate to a git repository or clone one first." >&2
    exit 1
fi

echo "$root"

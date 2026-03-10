#!/bin/bash
# Execute 'go run .' locally
# Usage: run.sh <directory> [args...]
#
# Exit codes:
#   0 = Success - program ran successfully
#   2 = BLOCKING error - run failed or go not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:run <directory> [args...]}"
shift

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

command -v go >/dev/null 2>&1 || {
    echo "ERROR: go not found. Install Go: https://go.dev/dl/" >&2
    exit 2
}

cd "$root" && go run . "$@" || exit 2

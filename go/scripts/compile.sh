#!/bin/bash
# Execute 'go build' locally
# Usage: compile.sh <directory>
#
# Exit codes:
#   0 = Success - build completed
#   2 = BLOCKING error - build failed or go not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:compile <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

command -v go >/dev/null 2>&1 || {
    echo "ERROR: go not found. Install Go: https://go.dev/dl/" >&2
    exit 2
}

cd "$root" && go build . || exit 2

#!/bin/bash
# Execute 'golangci-lint' locally
# Usage: cmd-lint.sh <directory>
#
# Exit codes:
#   0 = Success - no lint errors
#   2 = BLOCKING error - lint failures or golangci-lint not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-lint <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

command -v golangci-lint >/dev/null 2>&1 || {
    echo "ERROR: golangci-lint not found. Install: https://golangci-lint.run/welcome/install/" >&2
    exit 2
}

cd "$root" && golangci-lint run --fix ./... || exit 2

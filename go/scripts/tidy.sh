#!/bin/bash
# Execute 'go mod tidy' locally
# Usage: tidy.sh <directory>
#
# Exit codes:
#   0 = Success - dependencies updated
#   2 = BLOCKING error - tidy failed or go not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:tidy <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

command -v go >/dev/null 2>&1 || {
    echo "ERROR: go not found. Install Go: https://go.dev/dl/" >&2
    exit 2
}

cd "$root" && go mod tidy || exit 2

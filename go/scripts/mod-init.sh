#!/bin/bash
# Execute 'go mod init' locally
# Usage: mod-init.sh <directory> <package-name>
#
# Exit codes:
#   0 = Success - go.mod created
#   2 = BLOCKING error - init failed or go not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:mod-init <directory> <package-name>}"
shift
pkg="${1:?ERROR: Package name required. Usage: /go:mod-init <directory> <package-name>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

command -v go >/dev/null 2>&1 || {
    echo "ERROR: go not found. Install Go: https://go.dev/dl/" >&2
    exit 2
}

cd "$root" && go mod init "$pkg" || exit 2

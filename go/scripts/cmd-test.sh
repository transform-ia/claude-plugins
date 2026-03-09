#!/bin/bash
# Execute 'go test' locally
# Usage: cmd-test.sh <directory> [package]
# Package defaults to ./... if not specified
#
# Exit codes:
#   0 = Success - all tests passed
#   2 = BLOCKING error - tests failed or go not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-test <directory> [package]}"
shift
pkg="${1:-./...}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

command -v go >/dev/null 2>&1 || {
    echo "ERROR: go not found. Install Go: https://go.dev/dl/" >&2
    exit 2
}

cd "$root" && go test -v "$pkg" || exit 2

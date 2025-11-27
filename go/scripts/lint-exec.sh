#!/bin/bash
# Execute 'golangci-lint' in dev pod
# Usage: lint-exec.sh [directory]
# Default: run --fix ./...
# With directory: run --fix <directory>/...

set -euo pipefail

trap 'echo "SCRIPT ERROR: Unexpected failure in lint-exec.sh" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If first arg is a directory, use it as the target
target="./..."
if [[ $# -ge 1 && -d "$1" ]]; then
    target="$1/..."
    shift
fi

root=$("$SCRIPT_DIR/find-git-root.sh")
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

kubectl exec "$pod" -- golangci-lint run --fix "$target" "$@"

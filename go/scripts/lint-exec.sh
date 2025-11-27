#!/bin/bash
# Execute 'golangci-lint' in dev pod
# Usage: lint-exec.sh [args...]
# Default: run --fix ./...

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

root=$("$SCRIPT_DIR/find-git-root.sh")
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

if [[ $# -eq 0 ]]; then
    kubectl exec "$pod" -- golangci-lint run --fix ./...
else
    kubectl exec "$pod" -- golangci-lint "$@"
fi

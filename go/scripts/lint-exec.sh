#!/bin/bash
# Execute 'golangci-lint' in dev pod
# Usage: lint-exec.sh <directory>
#
# Exit codes:
#   0 = Success - no lint errors
#   2 = BLOCKING error - lint failures or pod not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-lint <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root") || exit 2

kubectl exec "$pod" -- golangci-lint run --fix ./... || exit 2

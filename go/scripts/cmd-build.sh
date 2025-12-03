#!/bin/bash
# Execute 'go build' in dev pod
# Usage: cmd-build.sh <directory>
#
# Exit codes:
#   0 = Success - build completed
#   2 = BLOCKING error - build failed or pod not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-build <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root") || exit 2

kubectl exec "$pod" -- go build . || exit 2

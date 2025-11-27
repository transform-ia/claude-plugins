#!/bin/bash
# Execute 'go run .' in dev pod
# Usage: run-exec.sh <directory> [args...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:run <directory> [args...]}"
shift

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root") || exit 2

kubectl exec "$pod" -- go run . "$@" || exit 2

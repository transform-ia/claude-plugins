#!/bin/bash
# Execute 'go run .' in dev pod
# Usage: run-exec.sh <directory> [args...]
# Finds git root from directory and runs go run . there

set -euo pipefail
trap 'echo "SCRIPT ERROR: Unexpected failure in run-exec.sh" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:run <directory> [args...]}"
shift

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir")
pod_ref=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

# pod_ref is namespace/podname
ns="${pod_ref%%/*}"
pod="${pod_ref##*/}"

kubectl exec -n "$ns" "$pod" -- sh -c "cd $root && go run . $*"

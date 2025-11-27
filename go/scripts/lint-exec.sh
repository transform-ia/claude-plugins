#!/bin/bash
# Execute 'golangci-lint' in dev pod
# Usage: lint-exec.sh <directory>
# Finds git root from directory and runs golangci-lint run --fix ./... there

set -euo pipefail
trap 'echo "SCRIPT ERROR: Unexpected failure in lint-exec.sh" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:lint <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir")
pod_ref=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

# pod_ref is namespace/podname
ns="${pod_ref%%/*}"
pod="${pod_ref##*/}"

kubectl exec -n "$ns" "$pod" -- sh -c "cd $root && golangci-lint run --fix ./..."

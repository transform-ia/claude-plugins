#!/bin/bash
# Execute 'go build' in dev pod
# Usage: build-exec.sh <directory>
# Finds git root from directory and runs go build . there

set -euo pipefail
trap 'echo "SCRIPT ERROR: Unexpected failure in build-exec.sh" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:build <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir")
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

kubectl exec "$pod" -- sh -c "cd $root && go build ."

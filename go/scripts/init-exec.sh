#!/bin/bash
# Execute 'go mod init' in dev pod
# Usage: init-exec.sh <directory> <package-name>
# Finds git root from directory and runs go mod init there

set -euo pipefail
trap 'echo "SCRIPT ERROR: Unexpected failure in init-exec.sh" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:init <directory> <package-name>}"
shift
pkg="${1:?ERROR: Package name required. Usage: /go:init <directory> <package-name>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir")
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

kubectl exec "$pod" -- sh -c "cd $root && go mod init $pkg"

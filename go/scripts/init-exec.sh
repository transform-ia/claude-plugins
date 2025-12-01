#!/bin/bash
# Execute 'go mod init' in dev pod
# Usage: init-exec.sh <directory> <package-name>
#
# Exit codes:
#   0 = Success - go.mod created
#   2 = BLOCKING error - init failed or pod not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-init <directory> <package-name>}"
shift
pkg="${1:?ERROR: Package name required. Usage: /go:cmd-init <directory> <package-name>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root") || exit 2

kubectl exec "$pod" -- go mod init "$pkg" || exit 2

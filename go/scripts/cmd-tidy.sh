#!/bin/bash
# Execute 'go mod tidy' in dev pod
# Usage: cmd-tidy.sh <directory>
#
# Exit codes:
#   0 = Success - dependencies updated
#   2 = BLOCKING error - tidy failed or pod not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-tidy <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root") || exit 2

kubectl exec "$pod" -- go mod tidy || exit 2

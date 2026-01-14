#!/bin/bash
# Execute 'go mod init' in golang-chart deployment
# Usage: cmd-init.sh <directory> <package-name>
#
# Exit codes:
#   0 = Success - go.mod created
#   2 = BLOCKING error - init failed or deployment not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-init <directory> <package-name>}"
shift
pkg="${1:?ERROR: Package name required. Usage: /go:cmd-init <directory> <package-name>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

# Find golang-chart deployment by label
deployment=$(kubectl get deployment -l app.kubernetes.io/name=golang-chart -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) || {
    echo "ERROR: No golang-chart deployment found. Install with: helm install golang-dev oci://ghcr.io/transform-ia/golang-chart" >&2
    exit 2
}

kubectl exec "deployment/$deployment" -- sh -c "cd '$root' && go mod init '$pkg'" || exit 2

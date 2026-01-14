#!/bin/bash
# Execute 'golangci-lint' in golang-chart deployment
# Usage: cmd-lint.sh <directory>
#
# Exit codes:
#   0 = Success - no lint errors
#   2 = BLOCKING error - lint failures or deployment not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-lint <directory>}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

# Find golang-chart deployment by label
deployment=$(kubectl get deployment -l app.kubernetes.io/name=golang-chart -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) || {
    echo "ERROR: No golang-chart deployment found. Install with: helm install golang-dev oci://ghcr.io/transform-ia/golang-chart" >&2
    exit 2
}

kubectl exec "deployment/$deployment" -- sh -c "cd '$root' && golangci-lint run --fix ./..." || exit 2

#!/bin/bash
# Execute 'go run .' in golang-chart deployment
# Usage: cmd-run.sh <directory> [args...]
#
# Exit codes:
#   0 = Success - program ran successfully
#   2 = BLOCKING error - run failed or deployment not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-run <directory> [args...]}"
shift

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

# Find golang-chart deployment by label
deployment=$(kubectl get deployment -l app.kubernetes.io/name=golang-chart -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) || {
    echo "ERROR: No golang-chart deployment found. Install with: helm install golang-dev oci://ghcr.io/transform-ia/golang-chart" >&2
    exit 2
}

# Build the command with args properly escaped
if [[ $# -eq 0 ]]; then
    kubectl exec "deployment/$deployment" -- bash -c "cd '$root' && go run ." || exit 2
else
    # Properly escape arguments for passing through bash -c
    args=""
    for arg in "$@"; do
        args="$args $(printf '%q' "$arg")"
    done
    kubectl exec "deployment/$deployment" -- bash -c "cd '$root' && go run .$args" || exit 2
fi

#!/bin/bash
# Execute 'go test' in golang-chart deployment
# Usage: cmd-test.sh <directory> [package]
# Package defaults to ./... if not specified
#
# Exit codes:
#   0 = Success - all tests passed
#   2 = BLOCKING error - tests failed or deployment not found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:cmd-test <directory> [package]}"
shift
pkg="${1:-./...}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2

# Find golang-chart deployment by label
deployment=$(kubectl get deployment -l app.kubernetes.io/name=golang-chart -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) || {
    echo "ERROR: No golang-chart deployment found. Install with: helm install golang-dev oci://ghcr.io/transform-ia/golang-chart" >&2
    exit 2
}

kubectl exec "deployment/$deployment" -- bash -c "cd '$root' && go test -v '$pkg'" || exit 2

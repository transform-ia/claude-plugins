#!/bin/bash
# Execute 'go test' in dev pod
# Usage: test-exec.sh <directory> [package]
# Package defaults to ./... if not specified

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir="${1:?ERROR: Directory argument required. Usage: /go:test <directory> [package]}"
shift
pkg="${1:-./...}"

root=$("$SCRIPT_DIR/find-git-root.sh" "$dir") || exit 2
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root") || exit 2

kubectl exec "$pod" -- go test -v "$pkg" || exit 2

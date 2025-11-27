#!/bin/bash
# Execute 'go' command in dev pod
# Usage: go-exec.sh <go-args...>
# Automatically finds git root and dev pod

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

root=$("$SCRIPT_DIR/find-git-root.sh")
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

kubectl exec "$pod" -- go "$@"

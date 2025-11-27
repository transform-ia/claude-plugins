#!/bin/bash
# Run the built binary in dev pod
# Usage: run-exec.sh [args...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

root=$("$SCRIPT_DIR/find-git-root.sh")
pod=$("$SCRIPT_DIR/find-dev-pod.sh" "$root")

kubectl exec "$pod" -- /tmp/cmd "$@"

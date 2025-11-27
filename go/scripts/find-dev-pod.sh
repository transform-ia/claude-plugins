#!/bin/bash
# Find golang-chart dev pod for given workspace path
# Usage: find-dev-pod.sh <workspace-path>
# Exit 1 if no matching pod found

set -euo pipefail

workspace="$1"
if [[ -z "$workspace" ]]; then
    echo "ERROR: Workspace path required" >&2
    exit 1
fi

# Convert path to label format: /workspace/sandbox/org/repo -> workspace-sandbox-org-repo
label_value=$(echo "$workspace" | tr '/' '-' | sed 's/^-//' | cut -c1-63)

pod=$(kubectl get pods \
    -l "golang.dev/workdir=$label_value" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -z "$pod" ]]; then
    echo "ERROR: No Go development pod found for workdir: $workspace" >&2
    echo "" >&2
    echo "Deploy one using the k8s-manager agent:" >&2
    echo "  'Deploy a golang-chart for $workspace'" >&2
    exit 1
fi

echo "$pod"

#!/bin/bash
# Find golang-chart dev pod for given workspace path
# Usage: find-dev-pod.sh <workspace-path>
# Exit 2 if no matching pod found (blocking error)

set -euo pipefail

workspace="$1"
if [[ -z "$workspace" ]]; then
    echo "ERROR: Workspace path required" >&2
    exit 2
fi

# Convert path to label format: /workspace/sandbox/org/repo -> workspace-sandbox-org-repo
label_value=$(echo "$workspace" | tr '/' '-' | sed 's/^-//' | cut -c1-63)

pod=$(kubectl get pods \
    -l "golang.dev/workdir=$label_value" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -z "$pod" ]]; then
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: No Go development pod found for workdir: $workspace" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    echo "The golang-chart must be deployed with:" >&2
    echo "  workdir: $workspace" >&2
    echo "" >&2
    echo "This adds label: golang.dev/workdir=$label_value" >&2
    echo "" >&2
    echo "Update the ArgoCD application to use golang-chart >= 0.0.21" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    exit 2
fi

echo "$pod"

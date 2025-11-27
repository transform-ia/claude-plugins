#!/bin/bash
# Find golang-chart dev pod for given workspace path
# Usage: find-dev-pod.sh <workspace-path>
# Exit 1 if no matching pod found

workspace="$1"
if [[ -z "$workspace" ]]; then
    echo "ERROR: Workspace path required" >&2
    exit 1
fi

pod=$(kubectl get pods \
    -l "app.kubernetes.io/name=golang-chart,transformia.ca/workspace=$workspace" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -z "$pod" ]]; then
    echo "ERROR: No Go development pod found for workspace: $workspace" >&2
    echo "" >&2
    echo "Deploy one using the k8s-manager agent:" >&2
    echo "  'Deploy a golang-chart for $workspace'" >&2
    exit 1
fi

echo "$pod"

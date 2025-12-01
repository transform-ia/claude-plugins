#!/bin/bash
# Find golang-chart dev pod for given workspace path
# Usage: find-dev-pod.sh <workspace-path>
#
# Exit codes (per Claude Code docs):
#   0 = Success - prints pod name to stdout
#   2 = BLOCKING error - no matching pod found

set -euo pipefail

if [[ $# -eq 0 ]] || [[ -z "${1:-}" ]]; then
    echo "ERROR: Directory argument required. Usage: find-dev-pod.sh <workspace-path>" >&2
    exit 2
fi

workspace="$1"

# Convert path to label format: /workspace/sandbox/org/repo -> workspace-sandbox-org-repo
label_value=$(echo "$workspace" | tr '/' '-' | sed 's/^-//' | cut -c1-63)

# Try to find pod with the label
pod=$(kubectl get pods \
    -l "golang.dev/workdir=$label_value" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) || true

if [[ -n "$pod" ]]; then
    echo "$pod"
    exit 0
fi

# Pod not found - show helpful debugging info
echo "" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "ERROR: No Go development pod found" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "" >&2
echo "Looking for pod with label:" >&2
echo "  golang.dev/workdir=$label_value" >&2
echo "" >&2

# Show existing golang-chart pods and their labels
echo "Existing golang-chart pods:" >&2
existing=$(kubectl get pods -l "app.kubernetes.io/name=golang-chart" \
    -o custom-columns='NAME:.metadata.name,WORKDIR:.metadata.labels.golang\.dev/workdir' \
    --no-headers 2>/dev/null) || true

if [[ -n "$existing" ]]; then
    echo "$existing" | while read -r name workdir; do
        echo "  $name -> $workdir" >&2
    done
else
    echo "  (none found)" >&2
fi

echo "" >&2
echo "To fix this:" >&2
echo "1. Update the ArgoCD application to use golang-chart >= 0.0.21" >&2
echo "2. Ensure the chart has: workdir: $workspace" >&2
echo "3. Sync the application to recreate pods with the new label" >&2
echo "" >&2
exit 2

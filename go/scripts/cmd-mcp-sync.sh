#!/bin/bash
# Sync golang-chart MCP servers to .mcp.json
# - Discovers golang-chart pods using golang.dev/workdir label
# - Adds new golang-* entries
# - Removes stale golang-* entries
# - Uses /mcp endpoint path on port 81
#
# Exit codes:
#   0 = Success - .mcp.json updated
#   2 = BLOCKING error - failed to query Kubernetes

set -euo pipefail

MCP_FILE="/workspace/.mcp.json"

# Get pods with golang.dev/workdir label (from golang-chart deployments)
pods=$(kubectl get pods \
    -l "golang.dev/workdir" \
    -o jsonpath='{range .items[*]}{.metadata.labels.golang\.dev/workdir}{" "}{.metadata.labels.app\.kubernetes\.io/instance}{" "}{.metadata.namespace}{"\n"}{end}') || {
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: Failed to get golang-chart pods from Kubernetes" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    exit 2
}

# Build list of expected MCP server names
declare -A expected_servers
while read -r workdir instance ns; do
    [[ -z "$instance" ]] && continue
    # Use service instance name (e.g., hooks-dev)
    key="${instance}"
    url="http://${instance}.${ns}.svc.cluster.local:81/mcp"
    expected_servers["$key"]="$url"
done <<< "$pods"

# Read existing .mcp.json
if [[ ! -f "$MCP_FILE" ]]; then
    echo '{}' > "$MCP_FILE"
fi

# Build new servers JSON
new_servers=$(for key in "${!expected_servers[@]}"; do
    echo "{\"$key\": {\"type\": \"http\", \"url\": \"${expected_servers[$key]}\"}}"
done | jq -s 'add // {}')

# Update .mcp.json - remove old golang-chart entries and add new ones
# Keep non-golang-chart entries (those not on port 81 /mcp endpoint)
jq --argjson new "$new_servers" '
    # Remove entries that match golang-chart URL pattern (port 81 /mcp)
    to_entries |
    map(select(.value.url // "" | test(":\\d+/mcp$") | not)) |
    from_entries |
    . + $new
' "$MCP_FILE" > "${MCP_FILE}.tmp" && mv "${MCP_FILE}.tmp" "$MCP_FILE"

# Report changes
echo ""
echo "MCP servers synced to $MCP_FILE:"
for key in "${!expected_servers[@]}"; do
    echo "  + $key -> ${expected_servers[$key]}"
done
echo ""

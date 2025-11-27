#!/bin/bash
# Sync golang-chart MCP servers to .mcp.json
# - Adds new golang-* entries
# - Removes stale golang-* entries
# - Uses /mcp endpoint path

set -euo pipefail

MCP_FILE="/workspace/.mcp.json"

# Get current golang-chart services
services=$(kubectl get svc \
    -l "app.kubernetes.io/name=golang-chart" \
    -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.namespace}{"\n"}{end}') || {
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: Failed to get golang-chart services from Kubernetes" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    exit 2
}

# Build list of expected MCP server names
declare -A expected_servers
while read -r name ns; do
    [[ -z "$name" ]] && continue
    # Use service name directly (e.g., hooks-dev -> hooks-dev)
    key="${name}"
    url="http://${name}.${ns}.svc.cluster.local:81/mcp"
    expected_servers["$key"]="$url"
done <<< "$services"

# Read existing .mcp.json
if [[ ! -f "$MCP_FILE" ]]; then
    echo '{}' > "$MCP_FILE"
fi

# Build new servers JSON
new_servers=$(for key in "${!expected_servers[@]}"; do
    echo "{\"$key\": {\"type\": \"http\", \"url\": \"${expected_servers[$key]}\"}}"
done | jq -s 'add // {}')

# Update .mcp.json - remove old golang-chart entries and add new ones
jq --argjson new "$new_servers" '
    # Remove entries that look like golang-chart services (contain -dev suffix)
    to_entries |
    map(select(.key | endswith("-dev") | not)) |
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

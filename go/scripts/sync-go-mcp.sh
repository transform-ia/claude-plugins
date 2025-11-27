#!/bin/bash
# Sync golang-chart MCP servers to .mcp.json
# - Adds new golang-* entries
# - Removes stale golang-* entries
# - Uses /sse endpoint path

set -e

MCP_FILE="/workspace/.mcp.json"

# Get current golang-chart services
services=$(kubectl get svc \
    -l "app.kubernetes.io/name=golang-chart" \
    -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.namespace}{"\n"}{end}')

# Build list of expected MCP server names
declare -A expected_servers
while read -r name ns; do
    [[ -z "$name" ]] && continue
    key="golang-${name}"
    url="http://${name}.${ns}.svc.cluster.local:81/sse"
    expected_servers["$key"]="$url"
done <<< "$services"

# Read existing .mcp.json
if [[ ! -f "$MCP_FILE" ]]; then
    echo '{"mcpServers":{}}' > "$MCP_FILE"
fi

# Use jq to update .mcp.json:
# 1. Remove all golang-* entries
# 2. Add current golang-* entries
new_servers=$(for key in "${!expected_servers[@]}"; do
    echo "{\"$key\": {\"type\": \"sse\", \"url\": \"${expected_servers[$key]}\"}}"
done | jq -s 'add // {}')

# Update .mcp.json
jq --argjson new "$new_servers" '
    .mcpServers = (
        (.mcpServers // {}) |
        to_entries |
        map(select(.key | startswith("golang-") | not)) |
        from_entries
    ) + $new
' "$MCP_FILE" > "${MCP_FILE}.tmp" && mv "${MCP_FILE}.tmp" "$MCP_FILE"

# Report changes
echo "MCP servers synced:"
for key in "${!expected_servers[@]}"; do
    echo "  + $key -> ${expected_servers[$key]}"
done

echo ""
echo "Removed stale golang-* entries (if any)"

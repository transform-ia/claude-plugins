#!/bin/bash
# Block most bash commands in MCP plugin context
# Allow only: claude mcp, kubectl (for testing), curl, nc (for connectivity)
set -euo pipefail

input=$(cat)

# Detect caller from transcript - only enforce for /mcp:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /mcp:* ]]; then
    exit 0  # Not from MCP plugin command, allow
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ -z "$command" ]]; then
    exit 0
fi

# Allow claude mcp commands
if [[ "$command" =~ ^claude[[:space:]]+mcp ]]; then
    exit 0
fi

# Allow rm for .mcp.json files only
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        if [[ "$filename" == ".mcp.json" ]]; then
            continue  # Allowed
        else
            echo "BLOCKED: Can only delete .mcp.json files in MCP plugin." >&2
            echo "Attempted to delete: $file" >&2
            exit 2
        fi
    done
    exit 0
fi

# Allow ONLY read-only kubectl commands for connectivity testing
# BLOCKED: create, apply, delete, patch, edit, replace, run, exec (security risk)
if [[ "$command" =~ ^kubectl[[:space:]] ]]; then
    # Block dangerous kubectl operations
    if [[ "$command" =~ kubectl[[:space:]]+(create|apply|delete|patch|edit|replace|run|exec|cp|attach|port-forward) ]]; then
        echo "BLOCKED: kubectl write operations not allowed in MCP plugin." >&2
        echo "Only read operations allowed: get, describe, logs" >&2
        exit 2
    fi
    # Allow only read operations
    if [[ "$command" =~ kubectl[[:space:]]+(get|describe|logs)[[:space:]] ]]; then
        exit 0
    fi
    echo "BLOCKED: Only 'kubectl get', 'kubectl describe', 'kubectl logs' allowed." >&2
    exit 2
fi

# Allow curl for endpoint testing
if [[ "$command" =~ ^curl[[:space:]] ]]; then
    exit 0
fi

# Allow nc for port testing
if [[ "$command" =~ ^nc[[:space:]] ]] || [[ "$command" =~ ^timeout[[:space:]].*nc[[:space:]] ]]; then
    exit 0
fi

# Allow nslookup for DNS testing
if [[ "$command" =~ ^nslookup[[:space:]] ]]; then
    exit 0
fi

# Allow cat for reading .mcp.json
if [[ "$command" =~ ^cat[[:space:]] ]] && [[ "$command" =~ \.mcp\.json ]]; then
    exit 0
fi

# Block everything else
echo "BLOCKED: MCP plugin restricts bash commands." >&2
echo "" >&2
echo "Available slash commands:" >&2
echo "  /mcp:add     - Add MCP server to .mcp.json" >&2
echo "  /mcp:list    - List configured MCP servers" >&2
echo "  /mcp:remove  - Remove MCP server from config" >&2
echo "  /mcp:test    - Test MCP server connectivity" >&2
echo "" >&2
echo "Allowed bash for testing:" >&2
echo "  - cat .mcp.json (read config)" >&2
echo "  - rm .mcp.json (remove config)" >&2
echo "  - curl (endpoint testing)" >&2
echo "  - kubectl get/describe/logs (connectivity testing)" >&2
echo "  - nc, nslookup (network testing)" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2

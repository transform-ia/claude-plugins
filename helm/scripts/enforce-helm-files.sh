#!/bin/bash
# PreToolUse: Enforce helm-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-helm-files.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/helm"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
filename=$(basename "$file_path")

# Check if path contains templates/ directory
if [[ "$file_path" == */templates/* ]]; then
    case "$filename" in
        *.yaml|*.yml|*.tpl|NOTES.txt)
            exit 0
            ;;
    esac
fi

# Allow specific helm chart files
case "$filename" in
    Chart.yaml|values.yaml|.helmignore|.yamllint.yaml|.yamllint.yml)
        exit 0
        ;;
    *)
        echo "BLOCKED: Helm plugin can only modify Chart.yaml, values.yaml, templates/*, .helmignore, .yamllint.yaml" >&2
        echo "For README.md, use /markdown:lint. For other files, exit the plugin context." >&2
        exit 2
        ;;
esac

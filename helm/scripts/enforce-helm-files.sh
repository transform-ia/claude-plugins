#!/bin/bash
# PreToolUse: Enforce helm-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-helm-files.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /helm:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /helm:* ]]; then
    exit 0  # Not from helm plugin command, allow
fi

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

# Block linter config - agent cannot modify (prevents disabling linters)
case "$filename" in
    .yamllint.yaml|.yamllint.yml|.yamllint)
        echo "BLOCKED: Helm plugin cannot modify linter configuration." >&2
        echo "If lint rules are too strict, discuss with the user first." >&2
        echo "The user can modify .yamllint.yaml after agreeing on changes." >&2
        exit 2
        ;;
esac

# Allow specific helm chart files
case "$filename" in
    Chart.yaml|values.yaml|.helmignore)
        exit 0
        ;;
    *)
        echo "BLOCKED: Helm plugin can only modify Chart.yaml, values.yaml, templates/*, .helmignore" >&2
        echo "For other files, exit the plugin context first." >&2
        exit 2
        ;;
esac

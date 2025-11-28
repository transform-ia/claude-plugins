#!/bin/bash
# PreToolUse: Block Bash commands when in helm plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/helm"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/helm/scripts/* ]]; then
    exit 0
fi

# Allow rm for helm chart files only (NOT linter config)
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        # Block linter config deletion
        case "$filename" in
            .yamllint.yaml|.yamllint.yml|.yamllint)
                echo "BLOCKED: Helm plugin cannot delete linter configuration." >&2
                echo "Discuss with the user before removing lint rules." >&2
                exit 2
                ;;
        esac
        case "$filename" in
            Chart.yaml|Chart.lock|values.yaml|values-*.yaml|.helmignore)
                # Allowed file type
                ;;
            *)
                # Check if in templates directory
                if [[ "$file" == */templates/* ]]; then
                    case "$filename" in
                        *.yaml|*.yml|*.tpl|_helpers.tpl|NOTES.txt)
                            # Allowed template file
                            ;;
                        *)
                            echo "BLOCKED: Can only delete .yaml/.yml/.tpl files in templates/ in helm plugin." >&2
                            echo "Attempted to delete: $file" >&2
                            exit 2
                            ;;
                    esac
                else
                    echo "BLOCKED: Can only delete Chart.yaml, values*.yaml, .helmignore, or templates/ files in helm plugin." >&2
                    echo "Attempted to delete: $file" >&2
                    exit 2
                fi
                ;;
        esac
    done
    exit 0
fi

# Provide helpful redirects
if [[ "$command" =~ ^helm[[:space:]]lint ]]; then
    echo "BLOCKED: Use /helm:lint instead of direct helm lint." >&2
    exit 2
fi

if [[ "$command" =~ ^yamllint ]]; then
    echo "BLOCKED: Use /helm:lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$command" =~ ^prettier ]]; then
    echo "BLOCKED: Use /helm:format instead of direct prettier." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in helm plugin context." >&2
echo "Use /helm:lint, /helm:format, /helm:template, or exit the plugin context." >&2
exit 2

#!/bin/bash
# PreToolUse: Block Bash commands when in Helm plugin context
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

# Source shared hook library
source "/workspace/sandbox/transform-ia/claude-plugins/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Helm plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "helm"; then
    exit 0  # Not in scope - allow
fi

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$COMMAND" == */claude-plugins/helm/scripts/* ]]; then
    exit 0
fi

# Allow rm for Helm chart files only (NOT linter config)
if [[ "$COMMAND" =~ ^rm[[:space:]] ]]; then
    # Improved rm argument parsing: handle --long-options and more flags
    files=$(echo "$COMMAND" | sed 's/^rm[[:space:]]*//; s/--[a-z-]*[[:space:]]*//g; s/-[rfivRdPW]*[[:space:]]*//g' | tr ' ' '\n')
    for file in $files; do
        # Skip empty lines from tr
        [[ -z "$file" ]] && continue
        filename=$(basename "$file")
        # Block linter config deletion
        case "$filename" in
            .yamllint.yaml|.yamllint.yml|.yamllint)
                echo "BLOCKED: Helm plugin cannot delete linter configuration." >&2
                echo "" >&2
                echo "File: $file" >&2
                echo "" >&2
                echo "Linter config is read-only. Discuss lint issues with the user first." >&2
                exit 2
                ;;
        esac
        case "$filename" in
            Chart.yaml|Chart.lock|values.yaml|values-*.yaml|.helmignore)
                # Allowed Helm file type
                ;;
            *)
                # Check if in templates directory
                if [[ "$file" == */templates/* ]]; then
                    case "$filename" in
                        *.tpl|NOTES.txt)
                            # Allowed template file
                            ;;
                        *)
                            echo "BLOCKED: Can only delete .tpl files in templates/ in Helm plugin." >&2
                            echo "" >&2
                            echo "Attempted to delete: $file" >&2
                            echo "" >&2
                            echo "To delete other files, exit the Helm plugin scope first." >&2
                            exit 2
                            ;;
                    esac
                else
                    echo "BLOCKED: Can only delete Chart.yaml, values*.yaml, .helmignore, or templates/ files in Helm plugin." >&2
                    echo "" >&2
                    echo "Attempted to delete: $file" >&2
                    echo "" >&2
                    echo "To delete other files, exit the Helm plugin scope first." >&2
                    exit 2
                fi
                ;;
        esac
    done
    exit 0
fi

# Provide helpful redirects
if [[ "$COMMAND" =~ ^helm[[:space:]]lint ]]; then
    echo "BLOCKED: Use /helm:cmd-lint instead of direct helm lint." >&2
    exit 2
fi

if [[ "$COMMAND" =~ ^yamllint ]]; then
    echo "BLOCKED: Use /helm:cmd-lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$COMMAND" =~ ^prettier ]]; then
    echo "BLOCKED: Use /helm:cmd-format instead of direct prettier." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in Helm plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /helm:cmd-lint                  - Lint chart with helm lint + yamllint" >&2
echo "  /helm:cmd-format                - Format YAML files with prettier" >&2
echo "  /helm:cmd-template              - Preview rendered templates" >&2
echo "  /helm:cmd-check-unused-values   - Find unused values in values.yaml" >&2
echo "" >&2
echo "For other operations, exit the Helm plugin scope first." >&2
exit 2

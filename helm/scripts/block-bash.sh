#!/bin/bash
# PreToolUse: Block Bash commands when in helm plugin context
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /helm:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"

# If no transcript_path (test scenario), fall back to CLAUDE_PLUGIN_ROOT check
if [[ -z "$transcript_path" ]]; then
    # Test/legacy mode: use CLAUDE_PLUGIN_ROOT environment variable
    if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PWD"* ]] && [[ "${CLAUDE_PLUGIN_ROOT:-}" != "/workspace/sandbox/transform-ia/claude-plugins/helm" ]]; then
        exit 0  # Not in helm plugin context
    fi
else
    # Production mode: use detect-caller.py with fail-closed behavior
    if [[ ! -x "$DETECT_CALLER" ]]; then
        echo "HOOK ERROR: detect-caller.py not found or not executable" >&2
        echo "Path: $DETECT_CALLER" >&2
        exit 2
    fi

    # Call detect-caller.py - fail loudly on script failure
    if ! caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>&1); then
        echo "HOOK ERROR: Caller detection failed" >&2
        echo "Output: $caller" >&2
        exit 2
    fi

    # Check if caller is from helm plugin
    if [[ "$caller" != /helm:* ]]; then
        exit 0  # Not from helm plugin command, allow
    fi
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/helm/scripts/* ]]; then
    exit 0
fi

# Allow rm for helm chart files only (NOT linter config)
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    # Improved rm argument parsing: handle --long-options and more flags
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/--[a-z-]*[[:space:]]*//g; s/-[rfivRdPW]*[[:space:]]*//g' | tr ' ' '\n')
    for file in $files; do
        # Skip empty lines from tr
        [[ -z "$file" ]] && continue
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
    echo "BLOCKED: Use /helm:cmd-lint instead of direct helm lint." >&2
    exit 2
fi

if [[ "$command" =~ ^yamllint ]]; then
    echo "BLOCKED: Use /helm:cmd-lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$command" =~ ^prettier ]]; then
    echo "BLOCKED: Use /helm:cmd-format instead of direct prettier." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in helm plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /helm:cmd-lint                  - Lint chart with helm lint + yamllint" >&2
echo "  /helm:cmd-format                - Format YAML files with prettier" >&2
echo "  /helm:cmd-template              - Preview rendered templates" >&2
echo "  /helm:cmd-check-unused-values   - Find unused values in values.yaml" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2

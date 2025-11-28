#!/bin/bash
# PreToolUse: Block most Bash commands when in github plugin context
# Exception: github:builder skill needs gh CLI access
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/github"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_PATH" ]]; then
    exit 0
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/github/scripts/* ]]; then
    exit 0
fi

# Allow rm for GitHub workflow files only
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        # Must be in .github/ directory
        if [[ "$file" == */.github/* ]] || [[ "$file" == .github/* ]]; then
            filename=$(basename "$file")
            case "$filename" in
                *.yml|*.yaml|*.md)
                    # Allowed GitHub file type
                    ;;
                *)
                    echo "BLOCKED: Can only delete .yml/.yaml/.md files in .github/ in github plugin." >&2
                    echo "Attempted to delete: $file" >&2
                    exit 2
                    ;;
            esac
        else
            echo "BLOCKED: Can only delete files in .github/ directory in github plugin." >&2
            echo "Attempted to delete: $file" >&2
            exit 2
        fi
    done
    exit 0
fi

# Allow ONLY safe read-only gh CLI commands (needed for builder skill)
# BLOCKED: delete, cancel, set, remove, close, merge, create (security risk)
if [[ "$command" =~ ^gh[[:space:]] ]]; then
    # Block dangerous gh operations
    if [[ "$command" =~ gh[[:space:]]+(repo|release|secret|variable|label|issue|pr)[[:space:]]+(delete|remove|close|create|edit|set) ]]; then
        echo "BLOCKED: gh write/delete operations not allowed in GitHub plugin." >&2
        echo "Only read operations allowed: list, view, status" >&2
        exit 2
    fi
    if [[ "$command" =~ gh[[:space:]]+run[[:space:]]+(cancel|delete|rerun) ]]; then
        echo "BLOCKED: gh run cancel/delete/rerun not allowed." >&2
        exit 2
    fi
    if [[ "$command" =~ gh[[:space:]]+auth ]]; then
        echo "BLOCKED: gh auth operations not allowed." >&2
        exit 2
    fi
    # Allow only read operations
    if [[ "$command" =~ gh[[:space:]]+(run|pr|issue|release|repo|workflow)[[:space:]]+(list|view|watch|status|diff) ]]; then
        exit 0
    fi
    if [[ "$command" =~ gh[[:space:]]+api[[:space:]] ]]; then
        # Allow GET API calls, block others
        if [[ "$command" =~ --method[[:space:]]+(POST|PUT|PATCH|DELETE) ]]; then
            echo "BLOCKED: gh api write methods not allowed." >&2
            exit 2
        fi
        exit 0
    fi
    echo "BLOCKED: Only read-only gh commands allowed (list, view, watch, status)." >&2
    exit 2
fi

# Provide helpful redirects
if [[ "$command" =~ ^yamllint ]]; then
    echo "BLOCKED: Use /github:lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$command" =~ ^prettier ]]; then
    echo "BLOCKED: Use /github:lint instead of direct prettier." >&2
    exit 2
fi

echo "BLOCKED: Bash not allowed in github plugin context (except gh CLI)." >&2
echo "Use /github:lint, /github:status, or exit the plugin context." >&2
exit 2

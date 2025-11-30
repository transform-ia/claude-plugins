#!/bin/bash
# PreToolUse: Block most Bash commands when in github plugin context
# Exception: github:builder skill needs gh CLI access
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /github:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /github:* ]]; then
    exit 0  # Not from github plugin command, allow
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$command" == */claude-plugins/github/scripts/* ]]; then
    exit 0
fi

# Allow rm for GitHub workflow files only (.yaml convention)
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        # Must be in .github/ directory
        if [[ "$file" == */.github/* ]] || [[ "$file" == .github/* ]]; then
            filename=$(basename "$file")
            case "$filename" in
                *.yaml|*.md)
                    # Allowed GitHub file type
                    ;;
                *.yml)
                    echo "BLOCKED: Use .yaml extension (not .yml) - project convention" >&2
                    exit 2
                    ;;
                *)
                    echo "BLOCKED: Can only delete .yaml/.md files in .github/ in github plugin." >&2
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

# Allow git commands for /github:release workflow
if [[ "$command" =~ ^git[[:space:]] ]]; then
    if [[ "$caller" == "/github:release" ]]; then
        exit 0  # Allow all git commands for release workflow
    fi
    echo "BLOCKED: git commands only allowed in /github:release context." >&2
    exit 2
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
echo "" >&2
echo "Available commands:" >&2
echo "  /github:lint     - Lint .github workflow files" >&2
echo "  /github:status   - Check workflow status" >&2
echo "  /github:logs     - Get workflow logs" >&2
echo "  /github:release  - Full release workflow" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2

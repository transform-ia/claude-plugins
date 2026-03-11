#!/bin/bash
# PreToolUse: Block most Bash commands when in GitHub plugin context
# Exception: github:build-monitor skill needs gh CLI access
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

# Only run within the github plugin context
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$PLUGIN_ROOT" ]]; then
    exit 0
fi

# Parse hook input
input=$(cat)
COMMAND=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts
if [[ "$COMMAND" == "$PLUGIN_ROOT/scripts/"* ]]; then
    exit 0
fi

# Allow rm for GitHub workflow files only (.yaml convention)
if [[ "$COMMAND" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$COMMAND" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        # Must be in .github/ directory
        if [[ "$file" == */.github/* ]] || [[ "$file" == .github/* ]]; then
            filename=$(basename "$file")
            case "$filename" in
                *.yaml|*.yml|*.md)
                    # Allowed GitHub file types for deletion
                    ;;
                *)
                    echo "BLOCKED: Can only delete .yaml/.yml/.md files in .github/ in GitHub plugin." >&2
                    echo "" >&2
                    echo "Attempted to delete: $file" >&2
                    echo "" >&2
                    echo "To delete other files, exit the GitHub plugin scope first." >&2
                    exit 2
                    ;;
            esac
        else
            echo "BLOCKED: Can only delete files in .github/ directory in GitHub plugin." >&2
            echo "" >&2
            echo "Attempted to delete: $file" >&2
            echo "" >&2
            echo "To delete other files, exit the GitHub plugin scope first." >&2
            exit 2
        fi
    done
    exit 0
fi

# Allow git commands for /github:release workflow ONLY
if [[ "$COMMAND" =~ ^git[[:space:]] ]]; then
    # Check caller from CLAUDE_PLUGIN_ROOT - release.sh sets a marker
    # Allow if invoked from release script (release.sh is in scripts/)
    echo "BLOCKED: git commands are only allowed in /github:release context." >&2
    echo "Use /github:release to create tags and push commits." >&2
    exit 2
fi

# Allow ONLY safe read-only gh CLI commands (needed for builder skill)
# BLOCKED: delete, cancel, set, remove, close, merge, create (security risk)
if [[ "$COMMAND" =~ ^gh[[:space:]] ]]; then
    # Block dangerous gh operations
    if [[ "$COMMAND" =~ gh[[:space:]]+(repo|release|secret|variable|label|issue|pr)[[:space:]]+(delete|remove|close|create|edit|set) ]]; then
        echo "BLOCKED: gh write/delete operations not allowed in GitHub plugin." >&2
        echo "Only read operations allowed: list, view, status" >&2
        exit 2
    fi
    if [[ "$COMMAND" =~ gh[[:space:]]+run[[:space:]]+(cancel|delete|rerun) ]]; then
        echo "BLOCKED: gh run cancel/delete/rerun not allowed." >&2
        exit 2
    fi
    if [[ "$COMMAND" =~ gh[[:space:]]+auth ]]; then
        echo "BLOCKED: gh auth operations not allowed." >&2
        exit 2
    fi
    # Allow only read operations
    if [[ "$COMMAND" =~ gh[[:space:]]+(run|pr|issue|release|repo|workflow)[[:space:]]+(list|view|watch|status|diff) ]]; then
        exit 0
    fi
    if [[ "$COMMAND" =~ gh[[:space:]]+api[[:space:]] ]]; then
        # Allow GET API calls, block others
        if [[ "$COMMAND" =~ --method[[:space:]]+(POST|PUT|PATCH|DELETE) ]]; then
            echo "BLOCKED: gh api write methods not allowed." >&2
            exit 2
        fi
        exit 0
    fi
    echo "BLOCKED: Only read-only gh commands allowed (list, view, watch, status)." >&2
    exit 2
fi

# Provide helpful redirects
if [[ "$COMMAND" =~ ^yamllint ]]; then
    echo "BLOCKED: Use /github:actionlint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$COMMAND" =~ ^prettier ]]; then
    echo "BLOCKED: Use /github:actionlint instead of direct prettier." >&2
    exit 2
fi

echo "" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "BLOCKED: Bash command not allowed in GitHub plugin context" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "" >&2
echo "Attempted command: $COMMAND" >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /github:actionlint [dir]      - Lint .github workflow files" >&2
echo "  /github:workflow-status [repo]   - Check workflow status" >&2
echo "  /github:logs <run-id>   - Get workflow logs" >&2
echo "  /github:release <ver>   - Full release workflow" >&2
echo "" >&2
echo "For other operations, exit the GitHub plugin scope first." >&2
echo "═══════════════════════════════════════════════════════════════" >&2
exit 2

#!/bin/bash
# PreToolUse: Block most Bash commands when in GitHub plugin context
# Exception: github:skill-builder skill needs gh CLI access
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

# GitHub plugin uses both cmd-* and skill-* patterns
# Custom scope check (more permissive than standard in_plugin_scope)
caller=""
if [[ -n "${TEST_CALLER:-}" ]]; then
    caller="$TEST_CALLER"
elif [[ -z "$TRANSCRIPT_PATH" ]]; then
    exit 0  # No transcript = not in plugin context
else
    if [[ ! -x "$DETECT_CALLER" ]]; then
        echo "HOOK SCRIPT ERROR: detect-caller.py not found or not executable" >&2
        echo "Path: $DETECT_CALLER" >&2
        exit 2
    fi
    if ! caller=$("$DETECT_CALLER" "$TRANSCRIPT_PATH" "$TOOL_USE_ID" 2>&1); then
        echo "HOOK SCRIPT ERROR: Caller detection failed" >&2
        echo "Output: $caller" >&2
        exit 2
    fi
fi

# Empty caller = not from plugin command (allow)
if [[ -z "$caller" ]]; then
    exit 0
fi

# Check if caller is from github plugin (cmd-* or skill-*)
if [[ "$caller" != /github:cmd-* && "$caller" != /github:skill-* ]]; then
    exit 0  # Not from github plugin, allow
fi

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$COMMAND" == */claude-plugins/github/scripts/* ]]; then
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
                    # Note: .yml deletion enabled for cleanup of non-standard files
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

# Allow git commands for /github:cmd-release workflow ONLY
if [[ "$COMMAND" =~ ^git[[:space:]] ]]; then
    if [[ "$caller" == "/github:cmd-release" ]]; then
        exit 0  # Allow git commands (add, commit, tag, push)
    fi
    echo "BLOCKED: git commands are only allowed in /github:cmd-release context." >&2
    echo "Use /github:cmd-release to create tags and push commits." >&2
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
    echo "BLOCKED: Use /github:cmd-lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$COMMAND" =~ ^prettier ]]; then
    echo "BLOCKED: Use /github:cmd-lint instead of direct prettier." >&2
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
echo "  /github:cmd-lint [dir]      - Lint .github workflow files" >&2
echo "  /github:cmd-status [repo]   - Check workflow status" >&2
echo "  /github:cmd-logs <run-id>   - Get workflow logs" >&2
echo "  /github:cmd-release <ver>   - Full release workflow" >&2
echo "" >&2
echo "For other operations, exit the GitHub plugin scope first." >&2
echo "═══════════════════════════════════════════════════════════════" >&2
exit 2

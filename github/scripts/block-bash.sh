#!/bin/bash
# PreToolUse: Block most Bash commands when in github plugin context
# Exception: github:skill-builder skill needs gh CLI access
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: block-bash.sh failed" >&2; exit 2' ERR

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"

# Detect caller from transcript - only enforce for /github:* commands
# Test mode: use TEST_CALLER env var
if [[ -n "${TEST_CALLER:-}" ]]; then
    caller="$TEST_CALLER"
# Production mode: require transcript and use detect-caller.py
elif [[ -z "$transcript_path" ]]; then
    # No transcript = not in plugin context (allow)
    exit 0
else
    # Verify detect-caller.py exists and is executable
    if [[ ! -x "$DETECT_CALLER" ]]; then
        echo "" >&2
        echo "HOOK ERROR: detect-caller.py not found or not executable" >&2
        echo "Path: $DETECT_CALLER" >&2
        echo "" >&2
        exit 2
    fi

    # Call detect-caller.py - fail-closed on script failure
    if ! caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>&1); then
        echo "" >&2
        echo "HOOK ERROR: Caller detection failed" >&2
        echo "Script output: $caller" >&2
        echo "" >&2
        exit 2
    fi
fi

# Empty caller = not from plugin command (allow)
if [[ -z "$caller" ]]; then
    exit 0
fi

# Check if caller is from github plugin
if [[ "$caller" != /github:cmd-* && "$caller" != /github:skill-* ]]; then
    exit 0  # Not from github plugin, allow
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
                *.yaml|*.yml|*.md)
                    # Allowed GitHub file types for deletion
                    # Note: .yml deletion enabled for cleanup of non-standard files
                    ;;
                *)
                    echo "BLOCKED: Can only delete .yaml/.yml/.md files in .github/ in github plugin." >&2
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

# Allow git commands for /github:cmd-release workflow ONLY
if [[ "$command" =~ ^git[[:space:]] ]]; then
    if [[ "$caller" == "/github:cmd-release" ]]; then
        exit 0  # Allow git commands (add, commit, tag, push)
    fi
    echo "BLOCKED: git commands are only allowed in /github:cmd-release context." >&2
    echo "Use /github:cmd-release to create tags and push commits." >&2
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
    echo "BLOCKED: Use /github:cmd-lint instead of direct yamllint." >&2
    exit 2
fi

if [[ "$command" =~ ^prettier ]]; then
    echo "BLOCKED: Use /github:cmd-lint instead of direct prettier." >&2
    exit 2
fi

echo "" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "BLOCKED: Bash command not allowed in GitHub plugin context" >&2
echo "═══════════════════════════════════════════════════════════════" >&2
echo "" >&2
echo "Attempted command: $command" >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /github:cmd-lint [dir]      - Lint .github workflow files" >&2
echo "  /github:cmd-status [repo]   - Check workflow status" >&2
echo "  /github:cmd-logs <run-id>   - Get workflow logs" >&2
echo "  /github:cmd-release <ver>   - Full release workflow" >&2
echo "" >&2
echo "For other operations, the GitHub plugin cannot help." >&2
echo "═══════════════════════════════════════════════════════════════" >&2
exit 2

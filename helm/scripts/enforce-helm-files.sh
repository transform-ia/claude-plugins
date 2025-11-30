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

tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
filename=$(basename "$file_path")
# Normalize path to catch ../templates tricks and resolve symlinks
normalized_path=$(readlink -m "$file_path" 2>/dev/null || echo "$file_path")

# Check if path contains templates/ directory
if [[ "$normalized_path" == */templates/* ]]; then
    case "$filename" in
        *.yaml|*.yml|*.tpl|_helpers.tpl|NOTES.txt)
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

#!/bin/bash
# PreToolUse: Enforce Helm-only file restrictions for Write/Edit operations
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-helm-files.sh" >&2; exit 2' ERR

# Source shared hook library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Helm plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "helm"; then
    exit 0  # Not in scope - allow
fi

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

# Normalize path to prevent traversal attacks
normalized_path=$(normalize_path "$FILE_PATH")
filename=$(basename "$normalized_path")

# Check if path contains templates/ directory
if [[ "$normalized_path" == */templates/* ]]; then
    case "$filename" in
        *.tpl|NOTES.txt)
            exit 0  # Allow
            ;;
    esac
fi

# Block linter config - agent cannot modify (prevents disabling linters)
case "$filename" in
    .yamllint.yaml|.yamllint.yml|.yamllint)
        echo "BLOCKED: Helm plugin cannot modify linter configuration." >&2
        echo "" >&2
        echo "Attempted to modify: $FILE_PATH" >&2
        echo "" >&2
        echo "Linter config is read-only. Discuss lint issues with the user first." >&2
        exit 2  # Block
        ;;
esac

# Allow specific Helm chart files
case "$filename" in
    Chart.yaml|values.yaml|.helmignore)
        exit 0  # Allow
        ;;
    *)
        echo "BLOCKED: Helm plugin can only modify Chart.yaml, values.yaml, templates/*, .helmignore" >&2
        echo "" >&2
        echo "Attempted to modify: $FILE_PATH" >&2
        echo "" >&2
        echo "For other file types:" >&2
        echo "  - Go files (*.go) → use go:skill-dev" >&2
        echo "  - Dockerfile → use docker:skill-dev" >&2
        echo "  - GitHub workflows → use github:skill-dev" >&2
        echo "  - Other files → exit Helm plugin scope first" >&2
        exit 2  # Block
        ;;
esac

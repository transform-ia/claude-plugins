#!/bin/bash
# PreToolUse: Enforce Dockerfile-only restrictions for Write/Edit operations
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-docker-files.sh" >&2; exit 2' ERR

# Source shared hook library
source "/workspace/sandbox/transform-ia/claude-plugins/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Docker plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "docker"; then
    exit 0  # Not in scope - allow
fi

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

# Normalize path to prevent traversal attacks
normalized_path=$(normalize_path "$FILE_PATH")
filename=$(basename "$normalized_path")

# Allow Dockerfile and .dockerignore only
case "$filename" in
    Dockerfile|Dockerfile.*|.dockerignore)
        exit 0  # Allow
        ;;
    *)
        echo "BLOCKED: Docker plugin can only modify Dockerfile and .dockerignore." >&2
        echo "" >&2
        echo "Attempted to modify: $FILE_PATH" >&2
        echo "" >&2
        echo "For other file types:" >&2
        echo "  - Go files (*.go) → use go:skill-dev" >&2
        echo "  - Helm charts (*.yaml) → use helm:skill-dev" >&2
        echo "  - GitHub workflows → use github:skill-dev" >&2
        echo "  - Other files → exit Docker plugin scope first" >&2
        exit 2  # Block
        ;;
esac

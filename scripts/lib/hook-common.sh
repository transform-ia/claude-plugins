#!/bin/bash
# Shared hook utilities for all plugins
# Source this from plugin hook scripts
#
# Usage:
#   source "<plugins-root>/scripts/lib/hook-common.sh"

set -euo pipefail

# Normalize file path to prevent traversal attacks
# Usage: normalized=$(normalize_path "$file_path")
normalize_path() {
    local path="$1"
    readlink -m "$path" 2>/dev/null || echo "$path"
}

# Parse hook input from stdin and extract common fields
# Usage: parse_hook_input
# Sets: HOOK_INPUT, TRANSCRIPT_PATH, TOOL_USE_ID, TOOL_NAME, FILE_PATH, COMMAND
parse_hook_input() {
    HOOK_INPUT=$(cat)
    TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')
    TOOL_USE_ID=$(echo "$HOOK_INPUT" | jq -r '.tool_use_id // empty')
    TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
    FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')
    COMMAND=$(echo "$HOOK_INPUT" | jq -r '.tool_input.command // empty')
}

#!/bin/bash
# Shared hook utilities for all plugins
# Source this from plugin hook scripts
#
# Usage:
#   source "<plugins-root>/scripts/lib/hook-common.sh"
#   if ! in_plugin_scope "$transcript_path" "$tool_use_id" "go"; then
#       exit 0  # Not in scope
#   fi

set -euo pipefail

# Resolve path relative to this script's location
_HOOK_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DETECT_CALLER="$_HOOK_COMMON_DIR/../detect-caller.py"

# Check if in plugin scope
# Usage: in_plugin_scope "$transcript_path" "$tool_use_id" "plugin_prefix"
# Returns: 0 if in scope, 1 if not, exits 2 on error (fail-closed)
in_plugin_scope() {
    local transcript_path="$1"
    local tool_use_id="$2"
    local plugin_prefix="$3"

    # Test mode: use TEST_CALLER env var
    if [[ -n "${TEST_CALLER:-}" ]]; then
        [[ "$TEST_CALLER" == /${plugin_prefix}:* ]] && return 0 || return 1
    fi

    # No transcript = not in plugin context (allow)
    [[ -z "$transcript_path" ]] && return 1

    # Verify detect-caller.py exists and is executable
    if [[ ! -x "$DETECT_CALLER" ]]; then
        echo "HOOK ERROR: detect-caller.py not found or not executable" >&2
        echo "Path: $DETECT_CALLER" >&2
        exit 2
    fi

    # Call detect-caller.py - fail-closed on script failure
    local caller
    if ! caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>&1); then
        echo "HOOK ERROR: Caller detection failed" >&2
        echo "Output: $caller" >&2
        exit 2
    fi

    # Empty caller = not from plugin command (not in scope)
    [[ -z "$caller" ]] && return 1

    # Check pattern match
    [[ "$caller" == /${plugin_prefix}:* ]] && return 0 || return 1
}

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

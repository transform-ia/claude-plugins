#!/bin/bash
# Shared validation logic for markdown plugin hooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Determine if in plugin scope via CLAUDE_PLUGIN_ROOT
# Returns: 0 if in scope, 1 if not
in_plugin_scope() {
    local plugin_root
    plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    [[ "${CLAUDE_PLUGIN_ROOT:-}" == "$plugin_root" ]]
}

# Validate file extension
# Returns: 0 if allowed, 1 if not
validate_file_extension() {
    local file_path="$1"
    is_file_allowed "$file_path"
}

# Validate bash command using allowlist (NO PARSING)
# Returns: 0 if allowed, 1 if not
validate_bash_command() {
    local command="$1"
    is_command_allowed "$command"
}

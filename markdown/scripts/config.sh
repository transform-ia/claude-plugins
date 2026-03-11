#!/bin/bash
# Markdown plugin configuration - Single source of truth

# Plugin identity
readonly PLUGIN_NAME="markdown"

# File patterns
readonly ALLOWED_EXTENSIONS=("md")

# Bash command allowlist (exact patterns only, no parsing)
readonly ALLOWED_BASH_COMMANDS=(
    "rm *.md"
    "rm **/*.md"
    "rm -f *.md"
    "rm -rf *.md"
)

# Error messages (single definition)
readonly MSG_BLOCKED_FILE="BLOCKED: Markdown plugin can only modify *.md files."
readonly MSG_BLOCKED_BASH="BLOCKED: Bash operations restricted in markdown plugin context."

# Helper: Check if command is in allowlist
is_command_allowed() {
    local command="$1"
    local pattern

    # Check plugin scripts (starts with CLAUDE_PLUGIN_ROOT)
    if [[ "$command" == "${CLAUDE_PLUGIN_ROOT}/scripts/"* ]]; then
        return 0
    fi

    # Check exact allowlist patterns
    for pattern in "${ALLOWED_BASH_COMMANDS[@]}"; do
        if [[ "$command" == "$pattern" ]]; then
            return 0
        fi
    done

    return 1
}

# Helper: Check if file extension is allowed
is_file_allowed() {
    local file_path="$1"
    local extension="${file_path##*.}"
    local allowed

    for allowed in "${ALLOWED_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$allowed" ]]; then
            return 0
        fi
    done

    return 1
}

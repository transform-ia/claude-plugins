#!/bin/bash
# Shared validation logic for markdown plugin hooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Determine if in plugin scope via caller detection
# Returns: 0 if in scope, 1 if not
# Exits: 2 if detection fails and FAIL_CLOSED=true
in_plugin_scope() {
    local transcript_path="$1"
    local tool_use_id="$2"

    if [[ ! "$USE_CALLER_DETECTION" == true ]]; then
        return 1  # Caller detection disabled
    fi

    # Validate inputs
    if [[ -z "$transcript_path" ]] || [[ -z "$tool_use_id" ]]; then
        if [[ "$FAIL_CLOSED" == true ]]; then
            echo "$MSG_SECURITY_ERROR Missing transcript metadata." >&2
            exit 2
        fi
        return 1
    fi

    # Verify detect-caller.py exists
    local detect_caller="${CLAUDE_PLUGIN_ROOT}/../scripts/detect-caller.py"
    if [[ ! -x "$detect_caller" ]]; then
        if [[ "$FAIL_CLOSED" == true ]]; then
            echo "$MSG_SECURITY_ERROR Caller detector missing." >&2
            exit 2
        fi
        return 1
    fi

    # Attempt caller detection
    local caller
    caller=$("$detect_caller" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "__DETECTION_FAILED__")

    # Handle detection failure (FAIL CLOSED)
    if [[ "$caller" == "__DETECTION_FAILED__" ]] || [[ -z "$caller" ]]; then
        if [[ "$FAIL_CLOSED" == true ]]; then
            echo "$MSG_DETECTION_FAILED" >&2
            exit 2
        fi
        return 1
    fi

    # Check if caller matches markdown plugin pattern
    if [[ "$caller" == /"$PLUGIN_NAME":* ]]; then
        return 0  # In scope
    else
        return 1  # Not in scope
    fi
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

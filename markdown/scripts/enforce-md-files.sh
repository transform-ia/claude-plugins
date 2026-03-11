#!/bin/bash
# PreToolUse: Enforce markdown-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-md-files.sh failed" >&2; exit 2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/validators.sh"

input=$(cat)

# Parse hook input
tool=$(echo "$input" | jq -r '.tool_name // empty')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Check if in plugin scope
if ! in_plugin_scope; then
    exit 0  # Not in scope - allow
fi

# Only enforce for Write/Edit tools
[[ "$tool" != "Write" && "$tool" != "Edit" ]] && exit 0

# Validate file extension
if validate_file_extension "$file_path"; then
    exit 0  # Allowed
else
    echo "$MSG_BLOCKED_FILE" >&2
    echo "Attempted: $file_path" >&2
    exit 2
fi

#!/bin/bash
# PreToolUse: Enforce Go-only file restrictions for Write/Edit operations
# This hook runs ONLY when the Go plugin is active (plugin hooks are scoped)
# Uses exit 1 (fatal) to stop immediately - no circumvention attempts
input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')

# Only check Write/Edit operations
if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Allow Go-related files only
case "$file_path" in
    *.go|*/go.mod|*/go.sum)
        exit 0  # Allow
        ;;
    *)
        echo "FATAL: Go plugin can only modify .go, go.mod, and go.sum files" >&2
        echo "Attempted: $file_path" >&2
        echo "" >&2
        echo "Complete the Go task first, then use another agent for other file types." >&2
        exit 1  # Fatal - stop immediately
        ;;
esac

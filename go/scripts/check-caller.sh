#!/bin/bash
# check-caller.sh - Check if tool call was initiated by Go plugin command
#
# This script demonstrates how to trace a tool call back to its originating
# user message using the transcript. It can be used to implement context-aware
# hook scoping where restrictions only apply within a specific plugin context.
#
# Usage: Receive hook input JSON on stdin
# Returns: exit 0 if from Go plugin (/go:*), exit 1 if not
#
# The logic is integrated into enforce-go-files.sh and block-bash.sh
# This script is kept as a reference/utility.

set -euo pipefail

input=$(cat)
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# If no transcript, can't determine - allow
if [[ -z "$transcript_path" ]] || [[ ! -f "$transcript_path" ]]; then
    echo "NO_TRANSCRIPT" >&2
    exit 1  # Unknown, allow
fi

# Find the assistant message containing this tool_use_id (grep for speed on JSONL)
# Use || true to avoid SIGPIPE exit code 141 when head closes pipe early
assistant_line=$(grep "$tool_use_id" "$transcript_path" 2>/dev/null | head -1 || true)

if [[ -z "$assistant_line" ]]; then
    echo "NO_ASSISTANT_MSG" >&2
    exit 1  # Can't find, allow
fi

# Get parentUuid from the assistant message
parent_uuid=$(echo "$assistant_line" | jq -r '.parentUuid // empty')

if [[ -z "$parent_uuid" ]] || [[ "$parent_uuid" == "null" ]]; then
    echo "NO_PARENT" >&2
    exit 1  # Can't find, allow
fi

# Find the user message by its uuid
user_line=$(grep "\"uuid\":\"$parent_uuid\"" "$transcript_path" 2>/dev/null | head -1 || true)

if [[ -z "$user_line" ]]; then
    echo "NO_USER_MSG" >&2
    exit 1  # Can't find, allow
fi

# Get the user message content
user_content=$(echo "$user_line" | jq -r '.message.content // empty')

# Check if it's a Go plugin command (/go:*)
# Trim leading whitespace for comparison
trimmed_content=$(echo "$user_content" | sed 's/^[[:space:]]*//')

if [[ "$trimmed_content" == /go:* ]]; then
    echo "GO_PLUGIN_COMMAND" >&2
    exit 0  # From Go plugin - apply restrictions
fi

echo "NOT_GO_PLUGIN" >&2
exit 1  # Not from Go plugin, allow operation

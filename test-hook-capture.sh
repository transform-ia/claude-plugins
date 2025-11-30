#!/bin/bash
# Test hook to capture all available context for caller detection analysis
# Run this as a PreToolUse hook and compare outputs from different callers:
# - Direct user request (no plugin)
# - /go:* commands
# - /helm:* commands
# - etc.
#
# Output goes to /tmp/hook-captures.log

set -euo pipefail

input=$(cat)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Create separator for easy reading
echo "" >> /tmp/hook-captures.log
echo "========================================" >> /tmp/hook-captures.log
echo "CAPTURE: $timestamp" >> /tmp/hook-captures.log
echo "========================================" >> /tmp/hook-captures.log

# 1. Environment variables that might indicate caller
echo "" >> /tmp/hook-captures.log
echo "--- ENVIRONMENT VARIABLES ---" >> /tmp/hook-captures.log
echo "CLAUDE_PLUGIN_ROOT=${CLAUDE_PLUGIN_ROOT:-<unset>}" >> /tmp/hook-captures.log
echo "CLAUDE_PROJECT_DIR=${CLAUDE_PROJECT_DIR:-<unset>}" >> /tmp/hook-captures.log
# Capture any other CLAUDE_* vars
env | grep -i claude >> /tmp/hook-captures.log 2>/dev/null || echo "(no other CLAUDE_* vars)" >> /tmp/hook-captures.log

# 2. Full hook input JSON
echo "" >> /tmp/hook-captures.log
echo "--- HOOK INPUT JSON ---" >> /tmp/hook-captures.log
echo "$input" | jq . >> /tmp/hook-captures.log 2>&1

# 3. Extract key fields
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

echo "" >> /tmp/hook-captures.log
echo "--- KEY FIELDS ---" >> /tmp/hook-captures.log
echo "tool_name: $tool_name" >> /tmp/hook-captures.log
echo "tool_use_id: $tool_use_id" >> /tmp/hook-captures.log
echo "transcript_path: $transcript_path" >> /tmp/hook-captures.log
echo "session_id: $session_id" >> /tmp/hook-captures.log

# 4. Transcript analysis - find the originating user message
echo "" >> /tmp/hook-captures.log
echo "--- TRANSCRIPT ANALYSIS ---" >> /tmp/hook-captures.log

if [[ -n "$transcript_path" ]] && [[ -f "$transcript_path" ]]; then
    echo "Transcript exists: YES" >> /tmp/hook-captures.log
    echo "Transcript lines: $(wc -l < "$transcript_path")" >> /tmp/hook-captures.log

    # Find assistant message with this tool_use_id
    assistant_line=$(grep "$tool_use_id" "$transcript_path" 2>/dev/null | head -1 || true)

    if [[ -n "$assistant_line" ]]; then
        echo "" >> /tmp/hook-captures.log
        echo "Assistant message found: YES" >> /tmp/hook-captures.log

        # Get parentUuid
        parent_uuid=$(echo "$assistant_line" | jq -r '.parentUuid // empty')
        echo "parentUuid: $parent_uuid" >> /tmp/hook-captures.log

        if [[ -n "$parent_uuid" ]] && [[ "$parent_uuid" != "null" ]]; then
            # Find user message
            user_line=$(grep "\"uuid\":\"$parent_uuid\"" "$transcript_path" 2>/dev/null | head -1 || true)

            if [[ -n "$user_line" ]]; then
                echo "" >> /tmp/hook-captures.log
                echo "User message found: YES" >> /tmp/hook-captures.log

                # Extract user message type and content
                user_type=$(echo "$user_line" | jq -r '.type // empty')
                user_role=$(echo "$user_line" | jq -r '.message.role // empty')
                user_content=$(echo "$user_line" | jq -r '.message.content // empty' | head -c 500)

                echo "user_type: $user_type" >> /tmp/hook-captures.log
                echo "user_role: $user_role" >> /tmp/hook-captures.log
                echo "user_content (first 500 chars):" >> /tmp/hook-captures.log
                echo "$user_content" >> /tmp/hook-captures.log

                # Check for plugin command pattern
                trimmed=$(echo "$user_content" | sed 's/^[[:space:]]*//')
                if [[ "$trimmed" == /* ]]; then
                    echo "" >> /tmp/hook-captures.log
                    echo "DETECTED SLASH COMMAND: $(echo "$trimmed" | head -c 50)" >> /tmp/hook-captures.log
                fi
            else
                echo "User message found: NO (uuid not found)" >> /tmp/hook-captures.log
            fi
        else
            echo "parentUuid: MISSING" >> /tmp/hook-captures.log
        fi
    else
        echo "Assistant message found: NO (tool_use_id not in transcript)" >> /tmp/hook-captures.log
        echo "Note: This may be a subagent - checking last few user messages..." >> /tmp/hook-captures.log

        # Show last 3 user messages for context
        echo "" >> /tmp/hook-captures.log
        echo "Last 3 user-type messages:" >> /tmp/hook-captures.log
        grep '"type":"user"' "$transcript_path" 2>/dev/null | tail -3 | while read line; do
            content=$(echo "$line" | jq -r '.message.content // empty' | head -c 200)
            echo "  - $content" >> /tmp/hook-captures.log
        done
    fi
else
    echo "Transcript exists: NO (path: $transcript_path)" >> /tmp/hook-captures.log
fi

echo "" >> /tmp/hook-captures.log
echo "========== END CAPTURE ==========" >> /tmp/hook-captures.log

# Always allow - this is just for debugging
exit 0

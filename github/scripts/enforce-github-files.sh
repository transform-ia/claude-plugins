#!/bin/bash
# PreToolUse: Enforce .github-only file restrictions for Write/Edit
#
# Exit codes:
#   0 = Allow
#   2 = Block

set -euo pipefail
trap 'echo "HOOK ERROR: enforce-github-files.sh failed" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /github:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /github:* ]]; then
    exit 0  # Not from github plugin command, allow
fi

tool=$(echo "$input" | jq -r '.tool_name // empty')

if [[ "$tool" != "Write" && "$tool" != "Edit" ]]; then
    exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only allow specific files (exact match or pattern)
allowed_files=(
    ".github/dependabot.yml"
    ".github/workflows/ci.yaml"
    ".github/workflows/build.yaml"
)
# Pattern: .github/PULL_REQUEST_TEMPLATE/*.md
allowed_pattern=".github/PULL_REQUEST_TEMPLATE/*.md"

# Extract relative path (last components matching .github/...)
relative_path=""
if [[ "$file_path" == */.github/* ]]; then
    relative_path=".github/${file_path##*/.github/}"
fi

# Check exact matches
for allowed in "${allowed_files[@]}"; do
    if [[ "$relative_path" == "$allowed" ]]; then
        exit 0
    fi
done

# Check pattern match for PULL_REQUEST_TEMPLATE/*.md
# shellcheck disable=SC2053
if [[ "$relative_path" == $allowed_pattern ]]; then
    exit 0
fi

echo "BLOCKED: GitHub plugin can only modify: ${allowed_files[*]} and $allowed_pattern" >&2
exit 2

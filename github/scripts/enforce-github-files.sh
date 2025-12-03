#!/bin/bash
# PreToolUse: Enforce .github-only file restrictions for Write/Edit operations
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in enforce-github-files.sh" >&2; exit 2' ERR

# Source shared hook library
source "/workspace/sandbox/transform-ia/claude-plugins/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# GitHub plugin uses both cmd-* and skill-* patterns
# Custom scope check (more permissive than standard in_plugin_scope)
caller=""
if [[ -n "${TEST_CALLER:-}" ]]; then
    caller="$TEST_CALLER"
elif [[ -z "$TRANSCRIPT_PATH" ]]; then
    exit 0  # No transcript = not in plugin context
else
    if [[ ! -x "$DETECT_CALLER" ]]; then
        echo "HOOK SCRIPT ERROR: detect-caller.py not found or not executable" >&2
        echo "Path: $DETECT_CALLER" >&2
        exit 2
    fi
    if ! caller=$("$DETECT_CALLER" "$TRANSCRIPT_PATH" "$TOOL_USE_ID" 2>&1); then
        echo "HOOK SCRIPT ERROR: Caller detection failed" >&2
        echo "Output: $caller" >&2
        exit 2
    fi
fi

# Empty caller = not from plugin command (allow)
if [[ -z "$caller" ]]; then
    exit 0
fi

# Check if caller is from github plugin (cmd-* or skill-*)
if [[ "$caller" != /github:cmd-* && "$caller" != /github:skill-* ]]; then
    exit 0  # Not from github plugin, allow
fi

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0  # Allow - not a file write operation
fi

# Normalize path to prevent traversal attacks
normalized_path=$(normalize_path "$FILE_PATH")

# Only allow specific files (exact match or pattern)
allowed_files=(
    ".github/dependabot.yaml"
    ".github/workflows/ci.yaml"
)
# Pattern: .github/PULL_REQUEST_TEMPLATE/*.md
allowed_pattern=".github/PULL_REQUEST_TEMPLATE/*.md"

# Extract relative path (last components matching .github/...)
relative_path=""
if [[ "$normalized_path" == */.github/* ]]; then
    relative_path=".github/${normalized_path##*/.github/}"
fi

# Check exact matches
for allowed in "${allowed_files[@]}"; do
    if [[ "$relative_path" == "$allowed" ]]; then
        exit 0  # Allow
    fi
done

# Check pattern match for PULL_REQUEST_TEMPLATE/*.md
# shellcheck disable=SC2053
if [[ "$relative_path" == $allowed_pattern ]]; then
    exit 0  # Allow
fi

echo "BLOCKED: GitHub plugin can only modify:" >&2
echo "  - ${allowed_files[*]}" >&2
echo "  - $allowed_pattern" >&2
echo "" >&2
echo "Attempted to modify: $FILE_PATH" >&2
echo "" >&2
echo "For other file types:" >&2
echo "  - Go files (*.go) → use go:skill-dev" >&2
echo "  - Dockerfile → use docker:skill-dev" >&2
echo "  - Helm charts (*.yaml) → use helm:skill-dev" >&2
echo "  - Other files → exit GitHub plugin scope first" >&2
exit 2  # Block

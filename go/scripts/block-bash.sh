#!/bin/bash
# PreToolUse: Block ALL Bash commands in Go plugin
# Go agent should only use /go:* commands, not shell
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)
#
# CRITICAL: Any script failure MUST exit 2 to block Claude

set -euo pipefail

# Trap any error and convert to exit 2 (blocking)
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Provide helpful redirect for go/golangci-lint
if [[ "$command" =~ ^go[[:space:]] ]]; then
    echo "BLOCKED: Use /go:* commands instead:" >&2
    echo "  /go:init <pkg>  - go mod init" >&2
    echo "  /go:tidy        - go mod tidy" >&2
    echo "  /go:build       - go build" >&2
    echo "  /go:test        - go test" >&2
    echo "  /go:run         - run binary" >&2
    exit 2  # Block
fi

if [[ "$command" =~ ^golangci-lint ]]; then
    echo "BLOCKED: Use /go:lint instead of direct golangci-lint." >&2
    exit 2  # Block
fi

# Block ALL other Bash commands
echo "BLOCKED: Go plugin does not allow Bash commands." >&2
echo "Use /go:* commands for Go operations." >&2
exit 2  # Block

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

# Allow plugin's own scripts (invoked by /go:* commands)
if [[ "$command" == *"/claude-plugins/go/scripts/"* ]]; then
    exit 0  # Allow plugin scripts
fi

# Provide helpful redirect for go/golangci-lint
if [[ "$command" =~ ^go[[:space:]] ]]; then
    echo "BLOCKED: Use /go:* commands instead:" >&2
    echo "  /go:init <dir> <pkg>  - go mod init" >&2
    echo "  /go:tidy <dir>        - go mod tidy" >&2
    echo "  /go:build <dir>       - go build" >&2
    echo "  /go:test <dir>        - go test" >&2
    echo "  /go:lint <dir>        - golangci-lint" >&2
    echo "  /go:run <dir>         - go run ." >&2
    exit 2  # Block
fi

if [[ "$command" =~ ^golangci-lint ]]; then
    echo "BLOCKED: Use /go:lint <dir> instead of direct golangci-lint." >&2
    exit 2  # Block
fi

# Block ALL other Bash commands
echo "BLOCKED: Go plugin does not allow Bash commands." >&2
echo "Use /go:* commands for Go operations." >&2
exit 2  # Block

#!/bin/bash
# PreToolUse: Block ALL Bash commands in Go plugin
# Go agent should only use /go:* commands, not shell
# Uses exit 1 (fatal) to stop immediately - no circumvention attempts
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Provide helpful redirect for go/golangci-lint
if [[ "$command" =~ ^go[[:space:]] ]]; then
    echo "FATAL: Use /go:* commands instead:" >&2
    echo "  /go:init <pkg>  - go mod init" >&2
    echo "  /go:tidy        - go mod tidy" >&2
    echo "  /go:build       - go build" >&2
    echo "  /go:test        - go test" >&2
    echo "  /go:run         - run binary" >&2
    exit 1  # Fatal - stop immediately
fi

if [[ "$command" =~ ^golangci-lint ]]; then
    echo "FATAL: Use /go:lint instead of direct golangci-lint." >&2
    exit 1  # Fatal - stop immediately
fi

# Block ALL other Bash commands
echo "FATAL: Go plugin does not allow Bash commands." >&2
echo "Use /go:* commands for Go operations." >&2
exit 1  # Fatal - stop immediately

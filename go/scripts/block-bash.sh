#!/bin/bash
# PreToolUse: Block Bash commands when in Go plugin context
# Go agent should only use /go:* commands, not shell
# ONLY enforces when running in Go plugin context (CLAUDE_PLUGIN_ROOT set)
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

# Check if we're in Go plugin context via environment variable
# This works for both direct /go:* commands AND subagents spawned by the plugin
GO_PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/go"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$GO_PLUGIN_PATH" ]]; then
    exit 0  # Not in Go plugin context, allow all Bash operations
fi

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$command" == */claude-plugins/go/scripts/* ]]; then
    exit 0
fi

# Allow rm for Go files only
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        case "$filename" in
            *.go|go.mod|go.sum|.golangci.yml|.golangci.yaml)
                # Allowed Go file type
                ;;
            *)
                echo "BLOCKED: Can only delete *.go, go.mod, go.sum, .golangci.* files in go plugin." >&2
                echo "Attempted to delete: $file" >&2
                exit 2
                ;;
        esac
    done
    exit 0
fi

# We're in Go plugin context - block Bash operations

# Provide helpful redirect for go/golangci-lint
if [[ "$command" =~ ^go[[:space:]] ]]; then
    echo "BLOCKED: Use /go:* commands instead:" >&2
    echo "  /go:init <dir> <pkg>  - go mod init" >&2
    echo "  /go:tidy <dir>        - go mod tidy" >&2
    echo "  /go:build <dir>       - go build" >&2
    echo "  /go:test <dir>        - go test" >&2
    echo "  /go:lint <dir>        - golangci-lint" >&2
    echo "  /go:run <dir>         - go run ." >&2
    exit 2
fi

if [[ "$command" =~ ^golangci-lint ]]; then
    echo "BLOCKED: Use /go:lint <dir> instead of direct golangci-lint." >&2
    exit 2
fi

# Block ALL other Bash commands when in Go plugin context
echo "BLOCKED: Bash not allowed in Go plugin context." >&2
echo "For shell commands, use a different agent or ask outside the Go plugin." >&2
exit 2

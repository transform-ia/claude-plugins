#!/bin/bash
# PreToolUse: Block Bash commands when in Go plugin context
# Go agent should only use /go:* commands, not shell
#
# Exit codes (per Claude Code docs):
#   0 = Allow (success)
#   2 = BLOCKING error - stops Claude, shows error
#   other = Non-blocking - Claude continues (BAD for enforcement!)

set -euo pipefail
trap 'echo "HOOK SCRIPT ERROR: Unexpected failure in block-bash.sh" >&2; exit 2' ERR

input=$(cat)

# Detect caller from transcript - only enforce for /go:* commands
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
DETECT_CALLER="/workspace/sandbox/transform-ia/claude-plugins/scripts/detect-caller.py"
caller=$("$DETECT_CALLER" "$transcript_path" "$tool_use_id" 2>/dev/null || echo "")

if [[ "$caller" != /go:* ]]; then
    exit 0  # Not from Go plugin command, allow
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$command" == */claude-plugins/go/scripts/* ]]; then
    exit 0
fi

# Allow rm for Go files only (NO .golangci.* - agent cannot delete linter config)
if [[ "$command" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$command" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        case "$filename" in
            *.go|go.mod|go.sum)
                # Allowed Go file type
                ;;
            .golangci.yaml|.golangci.yml)
                echo "BLOCKED: Go plugin cannot delete linter configuration." >&2
                echo "Discuss lint issues with the user first." >&2
                exit 2
                ;;
            *)
                echo "BLOCKED: Can only delete *.go, go.mod, go.sum files in go plugin." >&2
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
    echo "  /go:mcp-sync          - sync MCP servers to .mcp.json" >&2
    exit 2
fi

if [[ "$command" =~ ^golangci-lint ]]; then
    echo "BLOCKED: Use /go:lint <dir> instead of direct golangci-lint." >&2
    exit 2
fi

# Block ALL other Bash commands when in Go plugin context
echo "BLOCKED: Bash not allowed in Go plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /go:init <dir> <pkg>  - go mod init" >&2
echo "  /go:tidy <dir>        - go mod tidy" >&2
echo "  /go:build <dir>       - go build" >&2
echo "  /go:test <dir>        - go test" >&2
echo "  /go:lint <dir>        - golangci-lint" >&2
echo "  /go:run <dir>         - go run ." >&2
echo "  /go:mcp-sync          - sync MCP servers to .mcp.json" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2

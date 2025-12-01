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

# Source shared hook library
source "/workspace/sandbox/transform-ia/claude-plugins/scripts/lib/hook-common.sh"

# Parse hook input
parse_hook_input

# Check if in Go plugin scope
if ! in_plugin_scope "$TRANSCRIPT_PATH" "$TOOL_USE_ID" "go"; then
    exit 0  # Not in scope - allow
fi

# Allow plugin's own scripts (absolute path, no cd)
if [[ "$COMMAND" == */claude-plugins/go/scripts/* ]]; then
    exit 0
fi

# Allow rm for Go files only (NO .golangci.* - agent cannot delete linter config)
if [[ "$COMMAND" =~ ^rm[[:space:]] ]]; then
    files=$(echo "$COMMAND" | sed 's/^rm[[:space:]]*//; s/-[rfiv]*[[:space:]]*//g')
    for file in $files; do
        filename=$(basename "$file")
        case "$filename" in
            *.go|go.mod|go.sum)
                # Allowed Go file type
                ;;
            .golangci.yaml|.golangci.yml)
                echo "BLOCKED: Go plugin cannot delete linter configuration." >&2
                echo "" >&2
                echo "File: $file" >&2
                echo "" >&2
                echo "Linter config is read-only. Discuss lint issues with the user first." >&2
                exit 2
                ;;
            *)
                echo "BLOCKED: Can only delete *.go, go.mod, go.sum files in Go plugin." >&2
                echo "" >&2
                echo "Attempted to delete: $file" >&2
                echo "" >&2
                echo "To delete other files, exit the Go plugin scope first." >&2
                exit 2
                ;;
        esac
    done
    exit 0
fi

# We're in Go plugin context - block Bash operations

# Provide helpful redirect for go/golangci-lint
if [[ "$COMMAND" =~ ^go[[:space:]] ]]; then
    echo "BLOCKED: Use /go:* commands instead:" >&2
    echo "  /go:cmd-init <dir> <pkg>  - go mod init" >&2
    echo "  /go:cmd-tidy <dir>        - go mod tidy" >&2
    echo "  /go:cmd-build <dir>       - go build" >&2
    echo "  /go:cmd-test <dir>        - go test" >&2
    echo "  /go:cmd-lint <dir>        - golangci-lint" >&2
    echo "  /go:cmd-run <dir>         - go run ." >&2
    echo "  /go:cmd-mcp-sync          - sync MCP servers to .mcp.json" >&2
    exit 2
fi

if [[ "$COMMAND" =~ ^golangci-lint ]]; then
    echo "BLOCKED: Use /go:cmd-lint <dir> instead of direct golangci-lint." >&2
    exit 2
fi

# Block ALL other Bash commands when in Go plugin context
echo "BLOCKED: Bash not allowed in Go plugin context." >&2
echo "" >&2
echo "Available commands:" >&2
echo "  /go:cmd-init <dir> <pkg>  - go mod init" >&2
echo "  /go:cmd-tidy <dir>        - go mod tidy" >&2
echo "  /go:cmd-build <dir>       - go build" >&2
echo "  /go:cmd-test <dir>        - go test" >&2
echo "  /go:cmd-lint <dir>        - golangci-lint" >&2
echo "  /go:cmd-run <dir>         - go run ." >&2
echo "  /go:cmd-mcp-sync          - sync MCP servers to .mcp.json" >&2
echo "" >&2
echo "For other operations, exit the plugin context first." >&2
exit 2

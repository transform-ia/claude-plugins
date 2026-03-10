# Go Development Environment

Go development uses the local toolchain. Required tools:

- `go` - Go compiler and toolchain (https://go.dev/dl/)
- `golangci-lint` - Linter and formatter (https://golangci-lint.run/welcome/install/)
- `gopls` - Language server for MCP integration (installed with `go install golang.org/x/tools/gopls@latest`)

All Go commands run directly on the local machine. See the plugin commands
(`/go:compile`, `/go:gotest`, `/go:golint`, etc.) for available operations.

# MCP Server Directive

**Triggers when:** Application exposes MCP tools for AI agents

## Library

`github.com/mark3labs/mcp-go` (v0.43.0+)

## Server Setup

```go
import (
    "github.com/mark3labs/mcp-go/mcp"
    "github.com/mark3labs/mcp-go/server"
)

type MCPServer struct {
    mcpServer *server.MCPServer
}

func NewMCPServer() *MCPServer {
    s := &MCPServer{}
    s.mcpServer = server.NewMCPServer(
        "Service Name", "0.1.0",
        server.WithToolCapabilities(true),
    )
    s.registerTools()
    return s
}

func (s *MCPServer) Handler() http.Handler {
    return server.NewStreamableHTTPServer(
        s.mcpServer,
        server.WithSessionIdManager(&server.StatelessSessionIdManager{}),
    )
}
```

## Tool Registration

```go
func (s *MCPServer) registerTools() {
    tool := mcp.NewTool("tool_name",
        mcp.WithDescription("What this tool does"),
        mcp.WithString("param1", mcp.Required(), mcp.Description("...")),
    )
    s.mcpServer.AddTool(tool, s.handleTool)
}

func (s *MCPServer) handleTool(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
    param1, err := req.RequireString("param1")
    if err != nil {
        return nil, fmt.Errorf("missing param1: %w", err)
    }
    // business logic...
    return mcp.NewToolResultText(result), nil
}
```

## Integration

```go
mux.Handle("/mcp", mcpServer.Handler())
```

---
name: dev
description: |
  MCP server configuration management for .mcp.json files.

  ONLY activate when user explicitly requests /mcp:add, /mcp:remove, /mcp:list, /mcp:test commands.

  DO NOT activate when:
  - Working on any non-.mcp.json files
  - Managing Go, Docker, Helm, or GitHub configurations
  - User mentions "MCP" in general conversation about protocols
  - Deploying or managing MCP servers (only config management)
  - Working with any programming language code
allowed-tools: Read(*.mcp.json), Edit(*.mcp.json), Bash(claude mcp *), Bash(kubectl *), Bash(curl *)
---

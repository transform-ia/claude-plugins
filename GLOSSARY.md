# Claude Code Plugin System Glossary

## Core Concepts

### Plugin

A self-contained module providing specialized functionality for a specific
domain (Go, Docker, GitHub, etc.). Each plugin contains:

- Agents (AI assistants)
- Skills (agent configurations)
- Commands (slash commands)
- Hooks (validation scripts)
- Scripts (utilities)

**Location**: `<plugin-name>/` within the plugins repository

### Agent

An AI assistant configured to perform specific tasks within a plugin's domain.
Agents have:

- Tool permissions (Read, Write, Edit, Bash, etc.)
- File restrictions (which files they can modify)
- Activation conditions (when they become active)

**Examples**:

- `go:agent-dev` - Go development agent
- `docker:agent-dev` - Docker development agent
**Location**: `<plugin>/agents/agent-*.md`

### Skill

A configuration file that defines:

- What tools an agent can use
- Which files an agent can modify
- Instructions for the agent's behavior

Skills are loaded into Claude Code and make agents available in conversations.

**Location**: `<plugin>/skills/skill-*/SKILL.md` (config) and `instructions.md`
(behavior)

### Hook

A bash script that validates operations BEFORE they execute. Hooks enforce:

- File restrictions (which files can be edited)
- Tool restrictions (which commands can run)
- Plugin scoping (operations only allowed in correct plugin context)

**Types**:

- **Pre hooks**: Run BEFORE tool execution (e.g., `file-write.sh` blocks
  unauthorized file edits)
- **Post hooks**: Run AFTER tool execution (e.g., `stop-lint-check.sh` runs
  linters)
- **Stop hooks**: Run when conversation pauses (e.g., format and lint code)

**Exit codes**:

- `0` - Success (allow operation)
- `1` - Warning (log but allow operation)
- `2` - Blocking error (stop operation, show error)

**Location**: `<plugin>/hooks/hooks.json` (config) and
`<plugin>/scripts/*.sh` (scripts)

### Command (Slash Command)

A user-invocable shortcut that runs a plugin script. Format:
`/plugin:cmd-name [args]`

**Examples**:

- `/go:cmd-build <dir>` - Build Go binary
- `/github:cmd-release <version>` - Create release tag and monitor build
- `/docker:cmd-lint [file]` - Lint Dockerfile

**Location**: `<plugin>/commands/cmd-*/COMMAND.md`

#### Command Permission Levels

Commands are classified by their modification scope:

#### Level 0: Read-Only

- **Definition**: No files modified, no artifacts created
- **Examples**: `/go:cmd-test` (runs tests), `/docker:cmd-image-tag` (queries
  registry)
- **Standard Wording**: "This command is read-only. It does not modify any files
  or create artifacts."

#### Level 1: Artifact Creation

- **Definition**: Creates artifacts (binaries, reports) but does NOT modify
  source files
- **Examples**: `/go:cmd-build` (creates binary)
- **Standard Wording**: "This command creates artifacts but does not modify
  source files (\*.go, go.mod, go.sum)."

#### Level 2: Auto-Formatting

- **Definition**: Modifies files with automated formatting only (reversible, no
  logic changes)
- **Examples**: Stop hooks (gofmt, prettier)
- **Standard Wording**: "This command auto-formats files ({file list}) using
  {tool}. {Other files} are not modified."

#### Level 3: Source Modification

- **Definition**: Modifies source code logic or content
- **Examples**: Edit tool, Write tool
- **Standard Wording**: "This command modifies source files."

### Transcript

A JSONL (JSON Lines) file containing the conversation history. Each line is a
JSON object representing a message or tool call. Hooks use the transcript to
determine plugin context.

**Format**: One JSON object per line **Location**: Provided via stdin to hooks
**Usage**: `detect-caller.py` parses transcript to find active agent

## Plugin Architecture

### Plugins

Each plugin is focused on a single domain:

- **go** - Go development (\*.go, go.mod, go.sum)
- **typescript** - TypeScript/React development (\*.ts, \*.tsx)
- **docker** - Dockerfiles and images
- **github** - CI/CD workflows (.github/workflows/\*)
- **markdown** - Documentation (\*.md)
- **mcp** - MCP server configuration (.mcp.json)
- **graphql** - GraphQL API development (\*.graphql, \*.gql, hasura/\*)
- **postgresql** - PostgreSQL schema and migrations (\*.sql, \*.pgsql)

## Hook Scoping

### Plugin Context

The currently active agent determines which plugin's hooks are enforced.
Example:

```text
User → go:agent-dev (can edit *.go)
```

In this context:

- Go hooks allow editing `*.go`, `go.mod`, `go.sum`
- Go hooks block editing `Dockerfile`, `*.yaml`, `*.md`

### detect-caller.py

Script that parses the transcript to determine which plugin agent is currently
active.

**Logic**:

1. Read transcript from stdin (JSONL format)
2. Find most recent `Task` tool call with `subagent_type` field
3. Extract plugin name from `subagent_type` (e.g., "docker:agent-dev" →
   "docker")
4. Return plugin name or "unknown"

**Usage in hooks**:

```bash
PLUGIN=$(detect-caller.py < "$TRANSCRIPT")
if [ "$PLUGIN" != "docker" ]; then
  echo "BLOCKED: Cannot edit Dockerfile from $PLUGIN plugin context"
  exit 2
fi
```

## Tool Permissions

### Read-only Tools

Available to ALL agents (no restrictions):

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents

### Restricted Tools

Enforced by hooks based on plugin context:

- **Write** - Create new files (restricted to specific patterns)
- **Edit** - Modify existing files (restricted to specific patterns)
- **Bash** - Execute shell commands (restricted to specific commands)

### Tool Declaration Format

In agent SKILL.md files, tools use comma-separated format with file
restrictions:

```yaml
tools:
  - Read
  - Write(*.go, go.mod, go.sum)
  - Edit(*.go, go.mod, go.sum)
  - Bash(rm *.go, rm go.mod, rm go.sum)
```

## File Patterns

### File Pattern Matching Scope

**Scope Boundaries**: All file patterns are evaluated against the FULL ABSOLUTE
PATH of the target file after normalization (via `readlink -m` in
`normalize_path()`).

**Security**: Patterns match against NORMALIZED paths only. Path traversal
attempts (e.g., `../../etc/passwd`) are normalized before matching, so a pattern
like `*.go` will NOT match `/etc/passwd` even if attempted via traversal.

**Depth Semantics**: "At any depth" means the pattern matches anywhere in the
filesystem after path normalization. Patterns do NOT automatically restrict to
git root or working directory - hook scripts verify plugin scope BEFORE pattern
matching.

### Glob Patterns Used in Hooks

| Pattern       | Matches                                        | Does NOT Match               | Notes                           |
| ------------- | ---------------------------------------------- | ---------------------------- | ------------------------------- |
| `*.go`        | `/any/path/file.go`, `./file.go`, `file.go`    | `file.go.txt`, `go.txt`      | Matches any path ending in `.go`|
| `*/go.mod`    | `/dir/go.mod`, `./dir/go.mod`                  | `go.mod`, `/go.mod`          | Requires at least one dir       |
| `Dockerfile*` | `Dockerfile`, `Dockerfile.dev`, `/path/...`    | `MyDockerfile`, `dockerfile` | Prefix match, case-sensitive    |
| `.mcp.json`   | Only literal `.mcp.json` (basename match)      | `/path/.mcp.json`            | Matched via basename only       |

### Pattern Matching in Hooks

Hooks use bash case statements to match normalized file paths:

```bash
# Normalize path to prevent traversal attacks
normalized_path=$(normalize_path "$FILE_PATH")

case "$normalized_path" in
  *.go|*/go.mod|*/go.sum)
    # Allow Go files
    exit 0
    ;;
  *)
    # Block everything else
    echo "BLOCKED: Go plugin can only modify *.go, go.mod, go.sum"
    exit 2
    ;;
esac
```

## Workflow Patterns

### Activation Pattern

Agents activate directly for plugin-specific requests:

```text
1. User: "Fix the Dockerfile linting errors"
2. docker:agent-dev: Activates (user message explicitly mentions Dockerfile, Docker, or container images)
3. docker:agent-dev: /docker:cmd-lint
4. docker:agent-dev: Edit Dockerfile
5. docker:agent-dev: Report completion
```

## Dependency Management

### Dependency Files

Language-specific files that track dependencies (Dependabot can track updates):

- **Go**: `go.mod` + `go.sum`
- **npm**: `package.json` + `package-lock.json`
- **Python**: `requirements.txt` or `pyproject.toml`

### Inline Versions

NOT recommended - Dependabot cannot track inline versions. Exception: Alpine apk
has no dependency file format, so packages are unpinned to avoid build failures.

## Version Management

### Image Tags

Docker image versions:

- **NEVER** use `latest` tag
- **ALWAYS** pin to specific versions (e.g., `golang:1.23.4`, `alpine:3.21.0`)
- **DO NOT** use ARG for base image versions (Dependabot cannot track)
- **USE** `<<QUERY_LATEST_TAG>>` placeholder in templates (Claude queries actual
  latest tag)

## MCP (Model Context Protocol)

### MCP Server

A service that provides tools and resources to Claude Code. Examples:

- `context7-mcp` - Library documentation
- `golang-*` - gopls language server (Go semantic navigation)
- Custom services - Application-specific tools

### MCP Configuration

`.mcp.json` file mapping server names to connection details.

**MCP Server Types**:

1. **stdio servers** (local process):
   - Runs as a child process on the local machine
   - Example: gopls language server, context7
   - Configured with command and args

2. **HTTP servers** (localhost or remote):
   - Port: configurable per service
   - Endpoint: configurable per service
   - Example: `http://localhost:8080/mcp`

**Example `.mcp.json`**:

```json
{
  "golang-dev": {
    "type": "stdio",
    "command": "gopls",
    "args": ["serve"]
  },
  "custom-service": {
    "type": "http",
    "url": "http://localhost:3000/mcp"
  }
}
```

**Connection Types**:

- `stdio` - Command-line tool (local process)
- `http` - Standard HTTP server
- `sse` - Server-Sent Events

## Exit Codes

Standard exit codes used by hooks and scripts:

| Code | Meaning        | Effect                                  |
| ---- | -------------- | --------------------------------------- |
| `0`  | Success        | Allow operation to proceed              |
| `1`  | Warning        | Log warning, allow operation to proceed |
| `2`  | Blocking error | Stop operation, show error to user      |

## Hook Timeouts

### Pre-Hook Timeouts

All PreToolUse hooks use **5-second timeout**:

- File path validation: < 100ms typical
- Caller detection: < 200ms typical
- Bash command parsing: < 50ms typical

**On timeout**: Exit code 2 (blocking) - operation is denied for safety.

### Stop Hook Timeouts

| Plugin   | Timeout | Linter(s)               | Typical Runtime | Typical Project Size |
| -------- | ------- | ----------------------- | --------------- | -------------------- |
| go       | 120s    | golangci-lint           | 30-90s          | < 50k LOC            |
| docker   | 60s     | hadolint                | 5-15s           | < 10 Dockerfiles     |
| github   | 60s     | yamllint + prettier     | 5-20s           | < 20 workflows       |
| markdown | 60s     | markdownlint + prettier | 10-30s          | < 100 files          |

**Timeout Behavior**:

1. Hook process is killed (SIGTERM, then SIGKILL)
2. Exit code 2 is returned (blocking error)
3. User sees: "HOOK TIMEOUT: Linting exceeded {timeout}s"
4. Claude is blocked from proceeding
5. User must fix manually or adjust timeout

**When to Increase Timeout**:

- Monorepo with >100k LOC: increase go timeout to 300s
- Multiple chained linters: sum individual timeouts + 20s buffer

**How to Adjust Timeout** - Edit `<plugin>/hooks/hooks.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/stop-lint-check.sh",
            "timeout": 180
          }
        ]
      }
    ]
  }
}
```

## Test Mode (TEST_CALLER)

Hook scripts support a `TEST_CALLER` environment variable for unit testing:

```bash
# Example: Test that Go hook blocks non-Go files
TEST_CALLER="/go:skill-dev" echo '{"tool_input":{"file_path":"test.py"}}' | ./enforce-go-files.sh
```

**Security**: TEST_CALLER is only checked when `transcript_path` is empty. In
production, transcript_path is always provided by Claude Code, so TEST_CALLER
cannot be used to bypass restrictions.

## Known Limitations

**rm command parsing**: Hook scripts use sed-based parsing for rm commands which
may not handle all edge cases (e.g., `rm -- -rf file`). This is acceptable
because:

1. Hooks are defense-in-depth, not the only security layer
2. Complex rm patterns are rare in legitimate use
3. False positives from strict parsing would harm usability

## Common Patterns

### Template Variable Substitution

Use `<<QUERY_LATEST_TAG>>` as a placeholder in documentation/templates for
dynamic version lookup:

```yaml
container:
  image: ghcr.io/transform-ia/golang-image:<<QUERY_LATEST_TAG>>
```

Claude will replace this by querying the actual latest tag before creating
workflows.

### Out of Scope Protocol

When an agent receives a request outside its allowed files/tools:

1. **Immediately respond** with scope violation message
2. **Stop execution** - do not attempt workarounds
3. **Do not make any tool calls** for the out-of-scope operation
4. **Wait for user** to rephrase or switch plugins

Example message:

```text
Go plugin cannot handle this request - it is outside the allowed scope.

Allowed: *.go, go.mod, go.sum files and /go:* commands
Requested: Edit Dockerfile

Use the appropriate plugin instead:
- Dockerfile → docker:agent-dev
```

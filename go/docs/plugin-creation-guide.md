# Claude Code Plugin Creation Guide

This guide documents how to create Claude Code plugins with properly scoped
hooks that only apply within the plugin's context.

## Plugin Structure

```text
my-plugin/
├── commands/           # Slash commands (/plugin:command)
│   ├── command1.md
│   └── command2.md
├── hooks/
│   └── hooks.json      # Hook definitions
├── scripts/            # Hook implementation scripts
│   ├── enforce-rules.sh
│   └── block-tools.sh
├── skills/             # Auto-activating skills
│   └── my-skill/
│       ├── SKILL.md        # Skill metadata
│       └── instructions.md # Skill instructions (required filename)
├── agents/             # Agent definitions
│   └── my-agent.md
├── assets/             # Static resources
│   └── directives/
└── docs/               # Documentation
    └── plugin-creation-guide.md
```

## Naming Conventions (Avoid Stutter)

**Critical**: The plugin folder name becomes the prefix for all commands,
agents, and skills. Avoid repeating the prefix in filenames.

### How Naming Works

| Plugin Folder | File                | Invocation     |
| ------------- | ------------------- | -------------- |
| `go/`         | `commands/cmd-build.md` | `/go:cmd-build`    |
| `go/`         | `agents/agent-dev.md`     | `go:agent-dev`       |
| `go/`         | `skills/skill-dev/`       | skill `go:skill-dev` |

### Avoid Stutter

```text
❌ BAD: go/agents/go-dev.md     → go:go-dev (stutters!)
✅ GOOD: go/agents/agent-dev.md       → go:agent-dev

❌ BAD: go/skills/go-quality/   → skill go:go-quality
✅ GOOD: go/skills/skill-quality/     → skill go:skill-quality

❌ BAD: go/commands/go-build.md → /go:go-build
✅ GOOD: go/commands/cmd-build.md   → /go:cmd-build
```

### Rule

If your plugin folder is named `foo/`, then:

- Commands: `foo/commands/cmd-bar.md` → `/foo:cmd-bar`
- Agents: `foo/agents/agent-bar.md` → `foo:agent-bar`
- Skills: `foo/skills/skill-bar/` → skill `foo:skill-bar`

Never include the plugin name in the filename—it's already the prefix.

## Hook System

Hooks intercept Claude Code tool calls and can allow, modify, or block
operations.

### Hook Events

| Event         | When                  | Use Case                                    |
| ------------- | --------------------- | ------------------------------------------- |
| `PreToolUse`  | Before tool execution | Validate, block, or modify tool calls       |
| `PostToolUse` | After tool execution  | Validate results, trigger follow-up actions |
| `Stop`        | When Claude stops     | Run linting, validation, cleanup            |

### Exit Codes

| Code  | Meaning            | Effect                               |
| ----- | ------------------ | ------------------------------------ |
| `0`   | Success            | Allow operation to proceed           |
| `1`   | Warning            | Log warning, allow operation         |
| `2`   | Blocking error     | Stop operation, show error to Claude |

### hooks.json Format

```json
{
  "description": "Plugin description",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/enforce-rules.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Environment Variables

Hooks receive these environment variables:

| Variable             | Description                           |
| -------------------- | ------------------------------------- |
| `CLAUDE_PLUGIN_ROOT` | Absolute path to the plugin directory |
| `CLAUDE_PROJECT_DIR` | Path to the current project           |

### Hook Input (stdin JSON)

```json
{
  "session_id": "uuid-of-session",
  "transcript_path": "/path/to/session.jsonl",
  "cwd": "/current/working/directory",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file",
    "content": "file content"
  },
  "tool_use_id": "toolu_xxx"
}
```

## Hook Scoping (Critical)

**Problem**: Plugin hooks are registered globally and run for ALL tool calls,
not just those initiated by plugin commands.

**Solution**: Check the `CLAUDE_PLUGIN_ROOT` environment variable to determine
if we're in plugin context.

### How It Works

When a plugin command (e.g., `/go:cmd-build`) runs, Claude Code sets
`CLAUDE_PLUGIN_ROOT` to the plugin's directory path. This environment variable
is available to all hooks and persists through subagent invocations.

### Implementation Pattern (Recommended)

```bash
#!/bin/bash
set -euo pipefail

# Check if we're in our plugin's context
MY_PLUGIN_PATH="/workspace/sandbox/transform-ia/claude-plugins/myplugin"
if [[ "${CLAUDE_PLUGIN_ROOT:-}" != "$MY_PLUGIN_PATH" ]]; then
    exit 0  # Not in our plugin context, allow all operations
fi

# Read hook input
input=$(cat)

# FROM PLUGIN CONTEXT - Apply restrictions here
# ... your enforcement logic ...
```

### Key Points

1. **Environment check first**: Check `CLAUDE_PLUGIN_ROOT` before reading stdin
2. **Exact path match**: Compare against your plugin's full path
3. **Default empty**: Use `${CLAUDE_PLUGIN_ROOT:-}` to handle unset variable
4. **Works with subagents**: The env var persists when plugin spawns Task agents

### Alternative: Transcript Parsing

For more granular control (e.g., different behavior for different commands), you
can parse the transcript to find the originating user message:

```bash
tool_use_id=$(echo "$input" | jq -r '.tool_use_id // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# Find assistant message, then trace parentUuid to user message
assistant_line=$(grep "$tool_use_id" "$transcript_path" 2>/dev/null | head -1 || true)
parent_uuid=$(echo "$assistant_line" | jq -r '.parentUuid // empty')
user_line=$(grep "\"uuid\":\"$parent_uuid\"" "$transcript_path" 2>/dev/null | head -1 || true)
user_content=$(echo "$user_line" | jq -r '.message.content // empty')
```

**Limitation**: Transcript parsing only finds the immediate parent. Subagents
have their own message chains, so `/go:cmd-build` won't be found as the parent when
a subagent runs Bash. Use `CLAUDE_PLUGIN_ROOT` for reliable scoping.

## Command Files

Commands are markdown files that expand to prompts when invoked.

### Naming Convention

- File: `commands/build.md`
- Invocation: `/go:cmd-build` (plugin prefix + filename without .md)

### Command Structure

```markdown
Build the Go project at $ARGUMENTS using the dev pod.

1. Find the dev pod for this project
2. Run: kubectl exec <pod> -- go build ./...
3. Report any errors
```

Use `$ARGUMENTS` placeholder for user-provided arguments.

## Skills

Skills auto-activate based on file patterns or context.

### SKILL.md

```markdown
---
name: my-skill
description: Brief description
triggers:
  - "*.myext"
  - "myconfig.json"
---
```

### instructions.md

Detailed instructions loaded when skill activates.

## Best Practices

1. **Always scope hooks** - Check `CLAUDE_PLUGIN_ROOT` to avoid affecting
   operations outside plugin context
2. **Avoid naming stutter** - Don't repeat plugin name in agent/skill/command
   filenames
3. **Fail closed** - When validation fails or context is uncertain, block the operation (security-first approach)
4. **Clear error messages** - Tell users why something was blocked and what to
   do instead
5. **Timeout safety** - Set reasonable timeouts (5s for quick checks, 120s for
   linting)
6. **Error trapping** - Use `trap 'exit 2' ERR` to convert script failures to
   blocking errors
7. **Idempotent hooks** - Hooks may run multiple times; ensure they're safe to
   repeat

## Example: Go Plugin

The Go plugin demonstrates these patterns:

- **Commands**: `/go:cmd-build`, `/go:cmd-test`, `/go:cmd-lint`, etc.
- **Hook scoping**: Only enforces Go-only file restrictions when initiated by
  `/go:*` commands
- **Bash blocking**: Prevents shell commands in favor of plugin commands (within
  plugin context only)
- **Stop hook**: Runs linting when Claude completes a task

See the `scripts/` directory for implementation examples.

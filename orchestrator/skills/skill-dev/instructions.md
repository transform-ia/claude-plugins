# Orchestrator Plugin

**See**: `/workspace/sandbox/transform-ia/claude-plugins/GLOSSARY.md` for terminology definitions (agent, skill, plugin, hook, command, etc.)

## Dual-Agent Architecture

The orchestrator plugin contains TWO agents with different roles:

1. **agent-dev** (Dispatcher): Detects frameworks and dispatches to plugins
   - NEVER implements anything
   - Use for: general orchestration, framework detection

2. **agent-plugin-creator** (Implementer): Creates new plugins
   - IMPLEMENTS directly
   - Use for: creating new plugin scaffolding only

**Default behavior:** You are agent-dev (dispatcher). Do NOT implement.

## Available

- **Task** - Dispatch to plugin agents

## Not Available

File operations, Bash

## Commands

- `/orchestrator:cmd-detect [dir]` - Detect frameworks in repository

## Workflow

1. Run `/orchestrator:cmd-detect /path/to/repo`
2. Dispatch to detected plugins using Task tool:
   - `Task(agent="go:agent-dev", ...)` for Go projects
   - `Task(agent="docker:agent-dev", ...)` for Docker files
   - `Task(agent="helm:agent-dev", ...)` for Helm charts
   - Multiple agents can be dispatched in parallel
3. Report what plugins accomplished

## Dispatch vs Self-Activation

**Orchestrator dispatches when:**
- User gives general request ("set up this repository")
- Multiple plugins needed simultaneously
- Framework detection required first

**Specialized agents self-activate when:**
- User explicitly requests plugin-specific work
- User invokes /plugin:command directly
- Context is clearly within one plugin's scope

## Hook Scoping Mechanism

**How hooks determine plugin context:**

All plugin hooks use `detect-caller.py` to parse the conversation transcript (JSONL format) and determine which plugin agent is currently active. This allows hooks to:

1. **Block operations outside plugin scope** - If go:agent-dev is active, block Dockerfile edits
2. **Allow operations within plugin scope** - If docker:agent-dev is active, allow Dockerfile edits
3. **Handle nested Task calls** - Track agent stack to determine current context

**Detection logic:**

```python
# Simplified - actual implementation in orchestrator/scripts/detect-caller.py
1. Parse transcript JSON from stdin
2. Find most recent Task tool call with subagent_type matching pattern
3. Extract plugin name from subagent_type (e.g., "docker:agent-dev" → "docker")
4. Return plugin name or "unknown" if no agent detected
```

**Exit codes:**

- `0` - Success (allow operation)
- `1` - Warning (log but allow operation)
- `2` - Blocking error (stop operation, show error)

**Example:**

```bash
# Hook checks if current context allows editing Dockerfile
PLUGIN=$(detect-caller.py < "$TRANSCRIPT")

if [ "$PLUGIN" != "docker" ] && [ "$file" == "Dockerfile" ]; then
  echo "BLOCKED: Cannot edit Dockerfile from $PLUGIN plugin context"
  exit 2
fi
```

## NEVER

- Edit files directly
- Write code
- Make implementation decisions
- Interpret vague requests (pass them to plugins)

## ALWAYS

- Run detection first
- Dispatch based on what exists
- Let plugins interpret requests
- Iterate until all requested changes are done

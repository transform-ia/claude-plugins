# Orchestrator Plugin

**See**: `/workspace/sandbox/transform-ia/claude-plugins/GLOSSARY.md` for terminology definitions (agent, skill, plugin, hook, command, etc.)

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

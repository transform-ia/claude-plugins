# Claude Code Working Notes

## Repository Purpose

Claude Code plugin framework and collection of official plugins. Provides plugin
infrastructure, development tools, and standard plugins (go, docker, helm,
github, markdown, mcp, orchestrator).

## Plugin Usage

### When to use plugins

- `/orchestrator:detect` - Auto-detect appropriate plugin for current task
- `/markdown:cmd-lint` - Lint markdown files in plugin documentation
- `/github:cmd-status` - Check GitHub workflow status
- Refer to individual plugin README files for specific capabilities

### Available plugins

This repository contains: orchestrator, go, docker, helm, github, markdown, mcp

## Plugin Development Workflow

**Creating new plugin:**

1. Create plugin directory: `plugins/<plugin-name>/`
2. Add plugin manifest: `plugins/<plugin-name>/plugin.yaml`
3. Create agents: `plugins/<plugin-name>/agents/`
4. Create skills: `plugins/<plugin-name>/skills/`
5. Create commands: `plugins/<plugin-name>/commands/`
6. Add scripts: `plugins/<plugin-name>/scripts/`
7. Document in `plugins/<plugin-name>/README.md`
8. Test plugin activation and tools

**Modifying existing plugin:**

1. Navigate to `plugins/<plugin-name>/`
2. Edit agent definitions, skills, or scripts
3. Update documentation
4. Test changes
5. Commit to git

## Filesystem Conventions

- `/plugins/<name>/` - Individual plugin directories
- `/plugins/<name>/plugin.yaml` - Plugin manifest
- `/plugins/<name>/agents/` - Agent definitions (\*.md files)
- `/plugins/<name>/skills/` - Skill definitions (directories)
- `/plugins/<name>/commands/` - Slash commands (\*.md files)
- `/plugins/<name>/scripts/` - Executable scripts
- `/plugins/<name>/README.md` - Plugin documentation
- `/GLOSSARY.md` - Plugin terminology reference
- `/scripts/` - Shared utility scripts

## Plugin Architecture

**Components:**

- **Agents**: Autonomous entities with specific capabilities
- **Skills**: User-invocable capabilities with instructions
- **Commands**: Slash commands that expand to prompts
- **Scripts**: Executable bash/python scripts for operations
- **Hooks**: Pre/post execution event handlers

**Plugin Manifest (plugin.yaml):**

```yaml
name: plugin-name
description: Plugin description
version: 1.0.0
agents:
  - agent-dev
skills:
  - skill-dev
commands:
  - cmd-lint
```

## Testing Plugins

- Invoke skill: Use Skill tool with `<plugin>:skill-<name>`
- Run command: Use SlashCommand tool with `/<plugin>:cmd-<name>`
- Test scripts: Execute directly or via Bash tool
- Verify agent activation: Check transcript for agent loading

## Integration

Plugins integrate with:

- Claude Code core
- Hook system in `/workspace/sandbox/transform-ia/hooks`
- Agent runtime in `/workspace/sandbox/transform-ia/agents`

## Documentation Standards

- Each plugin must have README.md
- Document all agents, skills, commands, and scripts
- Include usage examples
- Specify tool permissions and allowed operations
- Reference GLOSSARY.md for terminology

## Deployment

Plugins are loaded by Claude Code from plugin directories. No separate
deployment needed - changes take effect when Claude Code reloads plugins.

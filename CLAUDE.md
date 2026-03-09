# Claude Code Plugin Framework

## Repository Purpose

Claude Code plugin framework and collection of official plugins. Provides plugin
infrastructure, development tools, and standard plugins (go, typescript, docker,
helm, github, markdown, mcp, orchestrator).

## Local Development Environment

Claude Code runs on the **local host** with development tools installed directly
on the machine.

### Environment Model

**Local Toolchain:**

- Development tools installed locally (go, node, npm, golangci-lint, helm, etc.)
- Git, gh CLI, and standard Unix tools available
- Projects stored in local filesystem directories
- MCP servers run as local processes (stdio or localhost HTTP)

### Available Development Tools

- **Go** - Go toolchain, gopls language server, golangci-lint
- **TypeScript/Node.js** - Node.js runtime, npm, TypeScript compiler, ESLint
- **Helm** - Helm CLI for chart development and linting
- **Docker** - Docker CLI for building and managing images

All tools operate directly on the local filesystem.

## Plugin Usage

### When to use plugins

- `/orchestrator:detect` - Auto-detect appropriate plugin for current task
- `/go:cmd-build` - Build Go binaries locally
- `/typescript:cmd-dev` - Start TypeScript dev server
- `/helm:cmd-lint` - Lint Helm charts
- `/markdown:cmd-lint` - Lint markdown files
- `/github:cmd-status` - Check GitHub workflow status

### Available plugins

This repository contains: orchestrator, go, typescript, javascript, docker,
helm, github, markdown, mcp

## Plugin Development Workflow

**Creating new plugin:**

1. Create plugin directory: `<plugin-name>/`
2. Add plugin manifest: `<plugin-name>/.claude-plugin/plugin.json`
3. Create agents: `<plugin-name>/agents/`
4. Create skills: `<plugin-name>/skills/`
5. Create commands: `<plugin-name>/commands/`
6. Add scripts: `<plugin-name>/scripts/`
7. Document in `<plugin-name>/README.md`
8. Test plugin activation and tools

**Modifying existing plugin:**

1. Navigate to `<plugin-name>/`
2. Edit agent definitions, skills, or scripts
3. Update documentation
4. Test changes
5. Commit to git

## Filesystem Conventions

- `/<plugin-name>/` - Individual plugin directories
- `/<plugin-name>/.claude-plugin/plugin.json` - Plugin manifest
- `/<plugin-name>/agents/` - Agent definitions (\*.md files)
- `/<plugin-name>/skills/` - Skill definitions (directories)
- `/<plugin-name>/commands/` - Slash commands (\*.md files)
- `/<plugin-name>/scripts/` - Executable scripts
- `/<plugin-name>/README.md` - Plugin documentation
- `/GLOSSARY.md` - Plugin terminology reference
- `/scripts/` - Shared utility scripts

## Plugin Architecture

**Components:**

- **Agents**: Autonomous entities with specific capabilities
- **Skills**: User-invokable capabilities with instructions
- **Commands**: Slash commands that expand to prompts
- **Scripts**: Executable bash/python scripts for operations
- **Hooks**: Pre/post execution event handlers

**Plugin Manifest (plugin.json):**

```json
{
  "name": "plugin-name",
  "version": "0.1.0",
  "description": "Plugin description"
}
```

## Testing Plugins

- Invoke skill: Use Skill tool with `<plugin>:skill-<name>`
- Run command: Use SlashCommand tool with `/<plugin>:cmd-<name>`
- Test scripts: Execute directly or via Bash tool
- Verify agent activation: Check transcript for agent loading

## Documentation Standards

- Each plugin must have README.md
- Document all agents, skills, commands, and scripts
- Include usage examples
- Specify tool permissions and allowed operations
- Reference GLOSSARY.md for terminology

## Task-Driven Workflow

Plugins follow a task-driven model:

1. **Analyze Task** - Determine requirements and dependencies
2. **Local Setup** - Verify required tools are installed locally
3. **Execute Work** - Use local tools and MCP servers for code intelligence
4. **GitOps Compliance** - All changes via Pull Requests

## Deployment

Plugins are loaded by Claude Code from plugin directories. No separate
deployment needed - changes take effect when Claude Code reloads plugins.

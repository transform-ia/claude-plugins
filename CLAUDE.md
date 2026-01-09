# Claude Code Plugin Framework

## Repository Purpose

Claude Code plugin framework and collection of official plugins. Provides plugin
infrastructure, development tools, and standard plugins (go, typescript, docker,
helm, github, markdown, mcp, orchestrator).

## Claude Code Pod Architecture

Claude Code runs in a Kubernetes pod designed as a **blank slate** with
task-driven environment setup to maintain GitOps workflow integrity.

### Environment Model

**Initial State:**

- Minimal pod with CLI tools (git, kubectl, helm, gh, argocd)
- `$NAMESPACE` environment variable (e.g., `claude-04`)
- Full admin access within namespace
- Shared workspace PVC at `/workspace`
- **No pre-installed development environments**

**Dynamic Setup:**
Plugins guide Claude Code to install specialized environments on-demand using
Helm charts from OCI registry:

```bash
helm install <name> oci://ghcr.io/transform-ia/charts/<chart-name>
```

### Available Environment Charts

- **typescript-chart** - Node.js, TypeScript language server, MCP server
- **golang-chart** - Go toolchain, gopls language server, MCP server
- **ansible-chart** - Ansible automation, SSH integration
- **graphql-chart** - Hasura GraphQL Engine, PostGIS database

All charts share the workspace PVC, providing seamless file access across
environments.

## Plugin Usage

### When to use plugins

- `/orchestrator:detect` - Auto-detect appropriate plugin for current task
- `/go:cmd-build` - Build Go binaries in golang-chart environment
- `/typescript:cmd-dev` - Start TypeScript dev server
- `/helm:cmd-install` - Install Helm charts from OCI registry
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
2. **Dynamic Setup** - Install Helm charts for specialized environments
3. **Execute Work** - Use language servers via MCP for code intelligence
4. **GitOps Compliance** - All changes via Pull Requests

## Deployment

Plugins are loaded by Claude Code from plugin directories. No separate
deployment needed - changes take effect when Claude Code reloads plugins.

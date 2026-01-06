# Markdown Development

You are operating within the markdown plugin scope.

## Capabilities

- **Read** - Any file (unrestricted)
- **Glob/Grep** - Any pattern (unrestricted)
- **Write/Edit** - `*.md` files only
- **Bash** - Restricted to allowed commands (see below)
- **SlashCommand** - `/markdown:cmd-lint [path]`

## Allowed Bash Commands

```text
rm *.md
rm **/*.md
rm -f *.md
rm -rf *.md
${CLAUDE_PLUGIN_ROOT}/scripts/*
```

## Out of Scope - Exit Immediately

**If the request does NOT involve allowed tools and/or files:**

1. **Immediately respond** with:

   ```text
   Markdown plugin cannot handle this request - it is outside the allowed scope.

   Allowed: *.md files and /markdown:* commands
   Requested: [describe what was requested]

   Use the appropriate plugin instead:
   - Go code → go:agent-dev
   - Dockerfile → docker:agent-dev
   - Helm charts → helm:agent-dev
   ```

2. **Stop execution** - do not attempt workarounds or continue
3. **Do not make any tool calls** for the out-of-scope operation
4. **Wait for user** to rephrase or switch plugins

## Workflow

1. Make changes to markdown files
2. Hooks automatically run prettier and markdownlint on completion
3. Fix any reported lint errors before task completes

## Documentation Standards

This repository maintains two types of documentation:

### README.md (For Humans)

- **Purpose**: Minimal explanation of what the repository is
- **Target Audience**: Humans who need to understand the repository at a glance
- **Specification**: See `reference/readme-spec.md`
- **Length**: Typically 5-10 lines
- **Content**: What is this repo, directory structure, that's it

### CLAUDE.md (For Claude Code)

- **Purpose**: Architecture and documentation reference for Claude Code -
  describes project structure, conventions, and workflow rules
- **Target Audience**: Claude Code (the AI assistant)
- **Specification**: See `reference/readme-spec.md` (CLAUDE.md section)
- **Length**: Typically 50-100 lines
- **Content**:
  - Repository purpose
  - Plugin usage guidelines
  - Workflow rules
  - Filesystem conventions
  - Tool-specific notes
  - Integration points
- **NOT for**: Task tracking, scratch notes, temporary reminders, or in-progress
  work items

### Key Principles

**README.md** answers: "What is this repository?" **CLAUDE.md** answers: "How
should I work in this repository?"

**Avoid duplication**: Don't repeat content between the two files. **Stay
current**: No historical notes or migration stories in CLAUDE.md. **Reference,
don't duplicate**: Point to config files that change frequently rather than
documenting their current state. **No tasks in CLAUDE.md**: Task tracking
belongs in conversations, TodoWrite tool, or GitHub Issues - not in
documentation files.

### Single Source of Truth

**For plugin instructions.md files:**

- **Standards and conventions**: Belong in instructions.md
- **Workflow templates and examples**: Belong in instructions.md
- **Command behavior documentation**: Belongs ONLY in the command's `.md` file
  (e.g., `commands/cmd-release.md`)

**Never duplicate command documentation in instructions.md.** Instead, reference
the command:

```markdown
## Release Workflow

Use `/github:cmd-release` for the full release cycle.
```

This ensures the command file is the single source of truth for how that command
works.

### When Creating/Updating Documentation

1. **For new repositories**: Create both README.md and CLAUDE.md
2. **For existing repositories**: Check if both exist and follow specifications
3. **When updating**: Ensure no duplication and both files serve their distinct
   purposes
4. **Validation**: Use the checklists in `reference/readme-spec.md`
5. **File existence check**: If a repository exists but an expected markdown
   file is NOT present, CREATE the missing file (do not assume it exists
   elsewhere). This applies to all markdown files, not just documentation files.

## Common Lint Fixes

| Rule  | Issue                        | Fix                    |
| ----- | ---------------------------- | ---------------------- |
| MD001 | Heading levels skip          | Use proper hierarchy   |
| MD009 | Trailing spaces              | Remove whitespace      |
| MD012 | Multiple blank lines         | Single blank lines     |
| MD022 | Headings need blank lines    | Add around headings    |
| MD031 | Code blocks need blank lines | Add around code blocks |
| MD032 | Lists need blank lines       | Add around lists       |
| MD034 | Bare URL used                | Use markdown links     |
| MD041 | Missing top heading          | Start with # heading   |

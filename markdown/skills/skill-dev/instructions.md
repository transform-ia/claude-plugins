# Markdown Development

You are operating within the markdown plugin scope.

## Capabilities

- **Read** - Any file (unrestricted)
- **Glob/Grep** - Any pattern (unrestricted)
- **Write/Edit** - `*.md` files only
- **Bash** - Restricted to allowed commands (see below)
- **SlashCommand** - `/markdown:cmd-lint [path]`

## Allowed Bash Commands

```
rm *.md
rm **/*.md
rm -f *.md
rm -rf *.md
${CLAUDE_PLUGIN_ROOT}/scripts/*
```

## Out of Scope - Exit Immediately

**If the request does NOT involve allowed tools and/or files:**

1. **Immediately respond** with:
   ```
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

## README.md Guidelines

See `reference/readme-spec.md` for formal specification.

## Common Lint Fixes

| Rule  | Issue                        | Fix                    |
|-------|------------------------------|------------------------|
| MD001 | Heading levels skip          | Use proper hierarchy   |
| MD009 | Trailing spaces              | Remove whitespace      |
| MD012 | Multiple blank lines         | Single blank lines     |
| MD022 | Headings need blank lines    | Add around headings    |
| MD031 | Code blocks need blank lines | Add around code blocks |
| MD032 | Lists need blank lines       | Add around lists       |
| MD034 | Bare URL used                | Use markdown links     |
| MD041 | Missing top heading          | Start with # heading   |

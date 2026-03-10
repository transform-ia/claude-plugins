# Markdown Development

## Workflow

1. Make changes to markdown files
2. Hooks automatically run prettier and markdownlint on completion
3. Fix any reported lint errors before task completes

## Documentation Standards

This repository maintains two types of documentation:

### README.md (For Humans)

- **Purpose**: Minimal explanation of what the repository is
- **Specification**: See `reference/readme-spec.md`
- **Length**: Typically 5-10 lines
- **Content**: What is this repo, directory structure, that's it

### CLAUDE.md (For Claude Code)

- **Purpose**: Architecture reference - project structure, conventions, workflow
  rules
- **Specification**: See `reference/readme-spec.md` (CLAUDE.md section)
- **Length**: Typically 50-100 lines
- **Content**: Repository purpose, plugin usage, workflow rules, filesystem
  conventions, tool-specific notes, integration points
- **NOT for**: Task tracking, scratch notes, temporary reminders

### Key Principles

**README.md** answers: "What is this repository?"

**CLAUDE.md** answers: "How should I work in this repository?"

- **Avoid duplication** between the two files
- **Stay current**: No historical notes or migration stories
- **Reference, don't duplicate**: Point to config files rather than documenting
  their current state
- **No tasks in CLAUDE.md**: Use conversations, TodoWrite, or GitHub Issues

### Single Source of Truth

- Standards and conventions belong in instructions.md
- Command behavior belongs ONLY in the command's `.md` file
- Never duplicate command documentation in instructions.md - reference it instead

### When Creating/Updating Documentation

1. For new repositories: Create both README.md and CLAUDE.md
2. For existing repositories: Check if both exist and follow specifications
3. When updating: Ensure no duplication between files
4. Validation: Use checklists in `reference/readme-spec.md`
5. If an expected markdown file is missing, CREATE it

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

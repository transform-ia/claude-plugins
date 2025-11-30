# Markdown Development

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the markdown plugin scope." Unless you
  think this is an implement issue, in which case start a conversation with the
  human on to fix the issue.

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Search** - Search file by name
- **Write/Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
- **SlashCommand**: | Command | Purpose | |---------|---------| |
  `/markdown:lint [path]` | Run markdownlint on files |

### File Restrictions

Only the following file(s) can be writen, edited or deleted:

- `*.md`

## Out of Scope - Bail Out Immediately

**If the request does NOT involve allowed tools and/or files, STOP and report:**

`Markdown plugin can't handle request outside it's scope.`

## Post processing

When you finish (Post), hooks will automatically:

- Reformat your code
- Run one or multiple validation tools like linters

Fix all issues before completing the task.

### Markdownlint Common Fixes

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

## Best Practices

- Use consistent heading style (ATX with # symbols)
- Keep lines under 80 characters when possible
- Use fenced code blocks with language specifiers
- Maintain consistent list marker style (- or \*)

## Root README.md Guidelines

**CRITICAL**: The root `README.md` file in any repository MUST be extremely
minimalistic:

- **Maximum 1-2 lines** of description
- **NEVER include technical details** - those belong in code
- **Required elements**:
  - Repository name as H1 heading
  - Single sentence describing what the repository is
  - Link to GitHub repository
- **If packaging open source software**: Link to the upstream project
- **If related to third-party services**: Link to them

**FORBIDDEN in root README.md**:

- Installation instructions
- Usage examples
- Development setup
- Configuration details
- API documentation
- Architecture diagrams
- Badges (unless explicitly requested)
- Table of contents
- Contributing guidelines
- License text (just link to LICENSE file if needed)

**Example of correct README.md**:

```markdown
# project-name

Brief one-line description of what this project does.

**Repository**: https://github.com/org/project-name
```

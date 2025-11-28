# Markdown Development Guidelines

## Critical: Hook Restrictions

**This context restricts operations to markdown files only (.md, .markdownlint.*).**

When an operation is BLOCKED by hooks:
- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the markdown plugin scope."

## Available Commands

| Command | Purpose |
|---------|---------|
| `/markdown:lint [path]` | Run markdownlint on files |

## Rules

1. **Linter runs automatically** when you finish. Fix all issues before completing.
2. **File restrictions:** Only .md and .markdownlint.* files can be modified.

## Markdownlint Common Fixes

| Rule | Issue | Fix |
|------|-------|-----|
| MD001 | Heading levels increment by more than one | Use proper heading hierarchy |
| MD009 | Trailing spaces | Remove trailing whitespace |
| MD012 | Multiple consecutive blank lines | Use single blank lines |
| MD022 | Headings should be surrounded by blank lines | Add blank lines around headings |
| MD031 | Fenced code blocks should be surrounded by blank lines | Add blank lines around code blocks |
| MD032 | Lists should be surrounded by blank lines | Add blank lines around lists |
| MD034 | Bare URL used | Use angle brackets or markdown links |
| MD041 | First line should be a top-level heading | Start with # heading |

## Best Practices

- Use consistent heading style (ATX with # symbols)
- Keep lines under 120 characters when possible
- Use fenced code blocks with language specifiers
- Maintain consistent list marker style (- or *)

## Out of Scope - Bail Out Immediately

**If the request does NOT involve markdown files, STOP and report:**

"This request is outside my scope. I handle markdown development only:
- .md files
- .markdownlint.yaml configuration

For other file types, use the appropriate agent."

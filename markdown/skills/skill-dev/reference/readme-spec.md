# README.md Formal Specification

Root README.md files must follow this exact structure:

## Required Structure

```markdown
# <project-name>

<one-sentence-description>

**Repository**: <github-url>
```

## Rules

1. Exactly 1 H1 heading (project name)
2. Exactly 1 blank line after H1
3. Exactly 1 sentence description (max 120 characters)
4. Exactly 1 blank line before repository link
5. Repository link uses **bold** label followed by URL
6. Total: 5 lines (H1, blank, description, blank, repo link)
7. Optional: Add links for:
   - Upstream repository (if this is a fork)
   - Live service URL (if deployed)
   - Related documentation (API docs, wiki)

## Validation

- Line count (excluding trailing newlines): 5 lines minimum
- H1 count: Exactly 1
- Description: 1 sentence, max 120 chars

## Forbidden Elements

- Installation instructions
- Usage examples
- Development setup
- Configuration details
- API documentation
- Architecture diagrams
- Badges (unless explicitly requested)
- Table of contents
- Contributing guidelines
- License text

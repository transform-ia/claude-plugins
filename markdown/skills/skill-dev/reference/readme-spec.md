# README.md Formal Specification

## Purpose

README.md is for **humans** - minimal explanation of what the repository is.

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

---

# CLAUDE.md Specification

## Purpose

CLAUDE.md is Claude Code's **architecture reference** - describes project
structure, conventions, and how to work in this repository.

## Required Sections

### 1. Repository Purpose

Brief statement of what this repository does.

### 2. Plugin Usage (if applicable)

- When to use which plugins
- Available plugins for this repository
- Plugin-specific conventions

### 3. Workflow Rules

Repository-specific workflow rules and conventions:

- Git workflow (e.g., "Never push directly to main")
- Deployment workflow (e.g., "Always use ArgoCD")
- Testing requirements
- Code review process

### 4. Filesystem Conventions

- Directory structure and purposes
- Where different types of files belong
- Naming conventions

### 5. Tool-Specific Notes

- Language-specific conventions (e.g., Go, Python, TypeScript)
- Framework-specific patterns
- Build system notes

### 6. Integration Points (if applicable)

- External services (brief note, not full documentation)
- Configuration files that change frequently
- How to manage integrations

## Format Guidelines

- **Concise**: ~50-100 lines typical
- **Actionable**: Focus on "what should I do" not "what is this"
- **Current**: No historical notes or migration stories
- **Dynamic**: References to files that change (e.g., .mcp.json) rather than
  duplicating content

## Example Structure

```markdown
# Claude Code Working Notes

## Repository Purpose

[One paragraph explaining what this repository does]

## Plugin Usage

### When to use plugins

- List of when to use which plugins

### Available plugins

- List of plugins relevant to this repository

## [Language/Framework] Conventions

- Language-specific rules
- Framework patterns
- Testing requirements

## Workflow Rules

**Rule:** [Critical rule here]

**Workflow:**

1. Step one
2. Step two
3. Step three

## Filesystem Conventions

- `/src/` - Purpose
- `/tests/` - Purpose

## [Integration/Tool] Notes

Brief notes on integrations, configs, external dependencies
```

## What NOT to Include

- Historical context ("we used to use X but now Y")
- Detailed technical documentation (link to external docs instead)
- Full configuration examples (reference the config file location)
- Duplicate information from README.md
- Information for humans (use README.md for that)
- Explanations of why decisions were made (just state what to do)
- Task lists or work items (use issue trackers or todo tools instead)
- Scratch notes or temporary reminders
- In-progress implementation details

## Validation

- [ ] Focused on "how to work here" not "what is this"
- [ ] References dynamic content instead of duplicating it
- [ ] Concise and actionable
- [ ] No historical baggage

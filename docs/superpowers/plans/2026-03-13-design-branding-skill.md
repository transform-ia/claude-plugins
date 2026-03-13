# Design Plugin — Branding Skill Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a new `design` plugin with a `branding` skill that conducts an
18-question brand discovery session and generates a full brand kit
(`brand.md`, `brand-prompts.md`, `brand-tokens.json`).

**Architecture:** Five markdown files total — `plugin.json`, `README.md`, a shared
`learnings-protocol.md`, and `SKILL.md` + `instructions.md` for the branding skill.
No code, no tests, no state file — verification is markdownlint + plugin-validator
agent. Plugin follows the same structure as `markdown/`, `go/`, and
`quebec-legal-entity/` in this repo.

**Tech Stack:** Markdown only. Validation: `npx markdownlint-cli2`. Plugin validator: `plugin-dev:plugin-validator` agent.

---

## File Map

| File | Responsibility |
| --- | --- |
| `design/.claude-plugin/plugin.json` | Plugin manifest (name, version, description) |
| `design/README.md` | Plugin docs with skill entry for `branding` |
| `design/skills/_shared/learnings-protocol.md` | Shared self-improvement protocol (adapted from `quebec-legal-entity/skills/_shared/`) |
| `design/skills/branding/SKILL.md` | Skill activation — bare YAML with `---` delimiters, NO code fence wrapper |
| `design/skills/branding/instructions.md` | Full skill behavior: On Start, 18-question discovery, confirmation, generation, NEVER/ALWAYS |

---

## Chunk 1: Scaffolding + SKILL.md

### Task 1: Plugin manifest and README

**Files:**

- Create: `design/.claude-plugin/plugin.json`
- Create: `design/README.md`

- [ ] **Step 1: Create `design/.claude-plugin/plugin.json`**

```json
{
  "name": "design",
  "version": "0.1.0",
  "description": "Brand identity tools. 18-question discovery → brand.md, brand-prompts.md (Nano Banana 2), brand-tokens.json"
}
```

- [ ] **Step 2: Create `design/README.md`**

```markdown
# Design Plugin

Brand identity and visual design tools for any company or project.

## Skills

### `branding`

Thorough brand identity session. Asks 18 questions across foundation, audience,
personality, visual direction, and context, then generates a complete brand kit:
`brand.md` (strategy + guidelines), `brand-prompts.md` (Nano Banana 2 logo and
photography prompts), and `brand-tokens.json` (design tokens + CSS variables).

**Invoke:** `/design:branding`
**Output files:** `brand.md`, `brand-prompts.md`, `brand-tokens.json`
```

- [ ] **Step 3: Validate with markdownlint**

```bash
npx markdownlint-cli2 "design/**/*.md" 2>&1
```

Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add design/.claude-plugin/plugin.json design/README.md
git commit -m "feat(design): scaffold design plugin with branding skill README"
```

---

### Task 2: Shared learnings protocol

**Files:**

- Create: `design/skills/_shared/learnings-protocol.md`

- [ ] **Step 1: Create `design/skills/_shared/learnings-protocol.md`**

Content — adapted from `quebec-legal-entity/skills/_shared/learnings-protocol.md`
with wording generic to design (not Quebec-regulatory).

> **Nested code fence note:** The file content below contains a 3-backtick inner block
> (the `learnings.md` entry template). The outer fence here uses 4 backticks to avoid
> conflict. Write the actual file exactly as shown inside the fence.
>
> **Ordered list numbering note:** The "How to record a learning" section has steps 1, 2,
> then a code block, then the final step numbered `1.` — not `3.`. A code block between
> list items creates a new list context in Markdown, so the step after the code block
> restarts at `1.`. This is correct and will pass markdownlint.

````markdown
# Self-Improvement Protocol

This file is read by every skill in the `design` plugin at session
start. Follow it throughout the session.

---

## Reading your learnings file

At the start of the session, you were instructed to read your skill-specific
`learnings.md` (e.g., `skills/branding/learnings.md`). If that file
existed and contained entries, treat each entry as an amendment to your
`instructions.md` — it takes precedence over the original text where they
conflict.

If the file did not exist, that is normal. It will be created the first time
you discover something worth recording.

---

## When to record a learning

Record a learning when you discover **any** of the following during a session:

- An AI model name, model ID, or API parameter has changed
- A recommended tool, service, or platform no longer exists or has been renamed
- A prompt technique or format that worked better than what the instructions describe
- A NEVER or ALWAYS rule that would have prevented a mistake you nearly made
- A cost, pricing tier, or free/paid status has changed for a referenced tool
- A user correction that would apply to all future users of this skill

**Do not record:**

- One-off user-specific decisions (those belong in the output files)
- Preferences unique to this user's brand
- Anything the user asked you to do just for their session

---

## How to record a learning

1. Tell the user:
   > "I found something that should update my instructions: [brief description].
   > Adding it to my learnings file — this will improve the skill for all
   > future sessions."

2. Write or append to `skills/<this-skill-name>/learnings.md`:

```markdown
## YYYY-MM-DD — [short title]

**Original:** [what the instructions said]
**Correct:** [what is actually true]
**Source:** [where you learned this — user correction, official docs, etc.]
```

1. Continue the session normally. You do not need to edit `instructions.md`
   directly — the learnings file is read at every session start and overrides
   the original instructions where they conflict.

---

## Keeping learnings clean

- One entry per discovery. Do not duplicate entries.
- If a learning supersedes an earlier entry, note it:
  `Supersedes entry from YYYY-MM-DD`.
- Learnings are periodically reviewed and folded back into `instructions.md`
  by the plugin maintainer. After that, the learnings file is cleared.
````

> **Note:** The nested fence and list numbering notes above the content block
> explain the non-obvious formatting decisions. No further action needed here.

- [ ] **Step 2: Validate with markdownlint**

```bash
npx markdownlint-cli2 "design/skills/_shared/learnings-protocol.md" 2>&1
```

Expected: 0 errors. Common issue: MD032 (blank line before list), MD029 (ordered list prefix must use `1.` style).

- [ ] **Step 3: Commit**

```bash
git add design/skills/_shared/learnings-protocol.md
git commit -m "feat(design): add shared learnings-protocol.md"
```

---

### Task 3: SKILL.md

**Files:**

- Create: `design/skills/branding/SKILL.md`

- [ ] **Step 1: Create `design/skills/branding/SKILL.md`**

**CRITICAL:** The file must be bare YAML. It starts with `---` on line 1 and ends
with `---`. There is NO surrounding code fence. Do not wrap it in ` ```yaml ` or
` ```markdown `. The file is literally just the YAML content below:

```text
---
name: branding
description: |
  Thorough brand identity session for any company or project. Conducts an
  18-question discovery process across five phases (foundation, audience,
  personality, visual direction, context), then generates a complete brand
  kit in one session.

  Outputs three files:
  - brand.md — brand strategy, voice guidelines, visual identity rules
  - brand-prompts.md — Nano Banana 2 logo and photography prompts
  - brand-tokens.json — design tokens and CSS custom properties

  ONLY activate when:
  - User invokes /design:branding
  - User asks to create a brand, logo, or visual identity for a company
  - User asks "how should my company look" or "we need a brand"

  DO NOT activate when:
  - User already has a brand and is asking to apply it to code (use
    the token file they already have)
  - User is asking about UI component design (not a brand question)
allowed-tools:
  AskUserQuestion,
  Write(brand.md), Write(brand-prompts.md), Write(brand-tokens.json),
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/branding/learnings.md),
  Write(skills/branding/learnings.md),
  Edit(skills/branding/learnings.md)
---
```

- [ ] **Step 2: Verify the file starts with `---` on line 1**

```bash
head -1 design/skills/branding/SKILL.md
```

Expected output: `---`
If output is ` ```yaml ` or ` ```markdown `, the file has been wrapped incorrectly — rewrite it.

- [ ] **Step 3: Commit**

```bash
git add design/skills/branding/SKILL.md
git commit -m "feat(design): add branding SKILL.md"
```

---

## Chunk 2: instructions.md + Validation

### Task 4: instructions.md

**Files:**

- Create: `design/skills/branding/instructions.md`

Write this file using the spec as the authoritative content reference:
`docs/superpowers/specs/2026-03-13-design-branding-skill-design.md`

The spec contains the complete behavior under `## Behavior` through `## NEVER / ALWAYS`.
Translate it faithfully into the file. Key structural notes:

- Start with a title and one-line intro paragraph
- `## On Start` — read learnings protocol and learnings.md, then greet the user
- `## Discovery Phase` — 18 questions as bold `**Q-ID:**` lines with a blank line between each, not a table
- `## Confirmation Step` — summary blockquote, then conditional logic
- `## Generation Phase` — three sub-sections (one per output file) with structure templates
  - `brand.md` structure: 3-backtick markdown fence (no nesting issues)
  - `brand-prompts.md` structure: **4-backtick** outer fence (contains a 3-backtick Python block)
  - `brand-tokens.json` structure: 3-backtick json fence
- `## Completion` — the completion message blockquote
- `## NEVER / ALWAYS` — two lists with all rules
- `## Key Notes` — two blockquotes

- [ ] **Step 1: Create `design/skills/branding/instructions.md`**

Create the file at `design/skills/branding/instructions.md` following the structure
above and the spec content. The spec contains the full `brand-tokens.json` token
group details (all color keys, typography keys, spacing values, and the `"css"` key
format) — consult it for the generation phase content.

- [ ] **Step 2: Validate with markdownlint**

```bash
npx markdownlint-cli2 "design/skills/branding/instructions.md" 2>&1
```

Expected: 0 errors. Common issues to watch for:

- MD032: blank line required before bullet lists after prose paragraphs
- MD024: duplicate headings — if any section headings repeat, disambiguate them
- MD013: line length — table cells and code blocks are exempt, but prose lines
  must stay under 140 characters

- [ ] **Step 3: Commit**

```bash
git add design/skills/branding/instructions.md
git commit -m "feat(design): add branding skill instructions.md"
```

---

### Task 5: Full validation and push

- [ ] **Step 1: Run markdownlint on all design files**

```bash
npx markdownlint-cli2 "design/**/*.md" 2>&1
```

Expected: 0 errors

- [ ] **Step 2: Run plugin validator**

Use the `plugin-dev:plugin-validator` agent to validate the `design/` plugin.
Pass this context to the agent:

> "Validate the `design` plugin at `design/` in the working directory
> `/home/patate/sandbox/transformia/claude-plugins`. Check: plugin.json
> structure, SKILL.md format (bare YAML, `---` delimiters, no code fence),
> instructions.md presence, allowed-tools consistency, and markdownlint
> for all markdown files."

Expected: PASS — no structural issues

- [ ] **Step 3: Commit any fixes, then push**

```bash
git push origin master
```

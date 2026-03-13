# Design Plugin — Branding Skill Design Spec

## Overview

A new `design` plugin with a single `branding` skill. The skill conducts a thorough
18-question brand discovery session and generates a complete brand kit in one session:
a strategy document, AI image generation prompts, and design tokens.

**Plugin:** `design`
**Skill:** `branding`
**Scope:** Generic — any company, project, or organization type

---

## Plugin Structure

```text
design/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── _shared/
│   │   └── learnings-protocol.md  (copy from quebec-legal-entity/skills/_shared/)
│   └── branding/
│       ├── SKILL.md
│       ├── instructions.md
│       └── learnings.md           (created on first self-improvement, not pre-created)
└── README.md
```

---

## SKILL.md

> **Format note:** The actual `SKILL.md` file must be bare YAML between `---`
> delimiters with no surrounding code fence. The block below is shown in a
> code fence for display purposes only — the file starts with `---` on line 1.

```yaml
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

---

## Behavior

### On Start

**Before proceeding:** Read `skills/_shared/learnings-protocol.md`. Then read
`skills/branding/learnings.md` if it exists and incorporate any entries into
your working knowledge for this session.

Greet the user:

> "Let's build your brand. I'll ask you 18 questions across five areas —
> foundation, audience, personality, visual direction, and context. Take your
> time with each one. At the end I'll generate a complete brand kit: a strategy
> document, logo prompts for Nano Banana 2, and design tokens ready to use
> in code."

Then begin the discovery phase.

---

### Discovery Phase — 18 Questions, One at a Time

Ask each question individually. Wait for a complete answer before proceeding.
Never ask two questions in the same message.

#### Phase 1 — Foundation (5 questions)

| # | Question |
| --- | --- |
| F-01 | What is the company or project name? |
| F-02 | In one or two sentences, what does it do? (Plain language — no buzzwords.) |
| F-03 | What industry or sector is it in? (e.g. tech, food, professional services, health, education, non-profit, retail, creative) |
| F-04 | What problem does it solve, and what does a customer do instead if this doesn't exist? |
| F-05 | What are three to five core values? (e.g. transparency, craft, community, speed, sustainability) |

#### Phase 2 — Audience (3 questions)

| # | Question |
| --- | --- |
| A-01 | Who is the primary audience? Describe them: age range, profession or lifestyle, what they care about. |
| A-02 | Is there a secondary audience? If none, say so. |
| A-03 | How does a customer feel before they find you? How should they feel after their first interaction with the brand? |

#### Phase 3 — Personality (4 questions)

| # | Question |
| --- | --- |
| P-01 | Pick three to five adjectives that describe the brand's personality (from the list below, or your own). |
| P-02 | Which brand archetype fits best? (Brief reminder of each provided when asked.) |
| P-03 | Name two or three brands you admire — not necessarily in your industry. What do you admire about each? |
| P-04 | Name two or three brands you must NOT look like. What should you avoid from each? |

**P-01 adjective list:** Bold · Subtle · Playful · Serious · Warm · Cool · Minimal · Rich ·
Approachable · Authoritative · Innovative · Traditional · Local · Global · Honest ·
Premium · Energetic · Calm (custom adjectives also accepted)

**P-02 archetype list:** Hero · Sage · Creator · Caregiver · Explorer · Innocent · Ruler ·
Magician · Outlaw · Jester · Lover · Regular Person
Brief reminders: Hero = courage/achievement; Sage = knowledge/truth; Creator = imagination/craft;
Caregiver = nurturing/protection; Explorer = freedom/discovery; Innocent = optimism/simplicity;
Ruler = control/stability; Magician = transformation; Outlaw = disruption; Jester = fun/irreverence;
Lover = passion/beauty; Regular Person = belonging/reliability.

#### Phase 4 — Visual Direction (3 questions)

| # | Question |
| --- | --- |
| V-01 | Color direction: warm, cool, or neutral? Any specific colors to include or avoid? |
| V-02 | Typography feel — pick one (options below). |
| V-03 | Logo form preference — pick one (options below). |

**V-02 typography options:** Clean & minimal (geometric sans-serif) · Humanist & approachable
(rounded, friendly) · Bold & expressive (high contrast, display) · Elegant & refined
(serif, editorial) · Technical & precise (monospace, structured)

**V-03 logo form options:** Wordmark (company name as styled text) · Lettermark (initials only) ·
Icon + wordmark (symbol alongside text) · Abstract symbol (standalone mark) · No preference

#### Phase 5 — Context (3 questions)

| # | Question |
| --- | --- |
| C-01 | Where will the brand be used? Select all that apply (options below). |
| C-02 | Any cultural, language, or accessibility considerations? If none, say so. |
| C-03 | One word: how should someone feel the very first time they see this brand? |

**C-01 use context options:** Website · Mobile app · Print (business cards, flyers) ·
Social media · Packaging · Signage · Email · Presentations

---

### Confirmation Step

After C-03, present a concise summary of all 18 answers grouped by phase. Then ask:

> "Here's what I've captured. Does this look right, or is there anything to
> correct before I generate the brand kit?"

Wait for confirmation. If the user requests corrections, update the relevant
answers and re-present the summary. Do not proceed to generation until the
user explicitly confirms.

---

### Generation Phase

Generate all three files after confirmation. Present them in order.

#### File 1: `brand.md`

Structure:

```markdown
# Brand Identity — [Company Name]
Generated: [date] · design:branding

## Brand Foundation
Purpose / Vision / Mission / Values (bulleted)

## Target Audience
Primary / Secondary / Emotional journey (before → after)

## Brand Personality
Archetype + one-paragraph description of what that means for this brand.
Five adjectives with a one-sentence explanation of each in context.

## Brand Voice
Three to five "We say / We don't say" pairs derived from the adjectives.
Example: "We say 'your regulars will love this' — not 'optimize customer retention'."

## Visual Identity
### Colour Palette
Primary, secondary, accent, neutral — each with hex code, RGB, and a one-line
rationale tied to the brand personality.

### Typography
Heading font recommendation + body font recommendation. Specific Google Fonts
or system font stacks only — no paid fonts unless the user mentioned budget.
Include a brief rationale.

### Logo Usage Rules
Minimum size, clear space, background rules, what NOT to do.
Derived from the logo form chosen and use contexts (C-01).

## Do / Don't
Five concrete do/don't pairs for visual usage.
```

#### File 2: `brand-prompts.md`

Use Nano Banana 2 exclusively (`gemini-3.1-flash-image-preview`).
Write prompts as narrative prose paragraphs — not comma-separated keyword lists.
Each prompt should describe scene, intent, mood, and specific colours.

Structure (shown with 4-backtick outer fence because inner content contains code blocks):

````markdown
# Logo & Visual Prompts — [Company Name]
Model: gemini-3.1-flash-image-preview (Nano Banana 2)
Generated: [date]

## How to use these prompts
[Instructions: AI Studio or API, recommended resolution 1024×1024 or 2048×2048
for logo work, iterate on the direction that resonates most.]

## Logo Concept 1 — [descriptive name for the direction]
Direction: [one sentence]
Prompt:
"[Full narrative prose prompt — 3-5 sentences describing the logo, its
emotional intent, colour palette with hex codes, style, and use context.]"

## Logo Concept 2 — [descriptive name]
Direction: [one sentence]
Prompt:
"[Full narrative prose prompt]"

## Logo Concept 3 — [descriptive name]
Direction: [one sentence]
Prompt:
"[Full narrative prose prompt]"

## Photography Style
Prompt:
"[Narrative prose prompt for brand photography style guide image —
describes lighting, subject matter, mood, composition, what to avoid.]"

## Social Media Visual Template
Prompt:
"[Narrative prose prompt for a 1080×1080px social post template —
describes layout, colour use, typography placement, brand feel.]"

## API Quick-Start

```python
from google import genai
client = genai.Client()
response = client.models.generate_content(
    model="gemini-3.1-flash-image-preview",
    contents=PROMPT_CONCEPT_1,  # paste from above
)
```
````

#### File 3: `brand-tokens.json`

The file contains a JSON object with a top-level `"css"` key whose value is
the CSS custom properties block as a string. This keeps the file valid JSON
while bundling both formats:

```json
{
  "color": { "primary": "#D4501A", "..." : "..." },
  "typography": { "..." : "..." },
  "spacing": { "..." : "..." },
  "radius": { "..." : "..." },
  "shadow": { "..." : "..." },
  "css": ":root {\n  --color-primary: #D4501A;\n  /* all tokens as CSS variables */\n}"
}
```

The implementer should also write a short comment at the top of the file
(as a `"_comment"` key) explaining how to use the `css` value.

Tokens to include:

**Token groups:**

- `color`: `primary`, `secondary`, `accent`, `neutral-50`, `neutral-100`, `neutral-900`,
  `text-primary`, `text-secondary`, `background`
- `typography`: `font-heading`, `font-body`, `size-xs` through `size-3xl`
  (0.75 → 3rem scale), `weight-regular/medium/bold`, `line-height-tight/base`
- `spacing`: `xs` (4px), `sm` (8px), `md` (16px), `lg` (24px), `xl` (32px), `2xl` (64px)
- `radius`: `sm` (4px), `md` (8px), `lg` (16px), `full` (9999px)
- `shadow`: `sm`, `md`, `lg` — derived from primary colour with low opacity

All colour values derived from brand answers — never use generic defaults like
`#007bff` or `#333333`. Derive colours systematically: generate tints and shades
from the primary/secondary brand colours.

---

### Completion

After generating all three files, summarise:

> "Brand kit complete. Three files created: `brand.md` (strategy, voice, and visual
> guidelines), `brand-prompts.md` (5 Nano Banana 2 prompts: 3 logo concepts, photography,
> social), and `brand-tokens.json` (design tokens + CSS variables).
> Next steps: run the logo prompts in AI Studio or via the Gemini API, pick the
> direction that resonates, then return to refine `brand.md` with your chosen logo
> form and final colour decisions."

---

## NEVER / ALWAYS

**NEVER:**

- Ask more than one question per message
- Skip the confirmation summary before generating
- Use comma-separated keyword prompts for Nano Banana 2 — always write prose
- Use generic placeholder colours (`#007bff`, `#333`, `#fff`) in tokens — derive
  everything from the brand answers
- Recommend paid fonts unless the user explicitly mentions a design budget
- Generate the brand kit before the user confirms the summary

**ALWAYS:**

- Remind the user of the current phase and question number (e.g. "Question 7 of 18 — Personality")
- Accept partial or uncertain answers and work with them — not every founder
  knows their archetype on the first try
- For P-02 (archetype), briefly describe each option — don't assume the user
  knows brand archetypes
- Write 3 distinct logo concept prompts with meaningfully different creative
  directions (not just colour variations of the same concept)
- Include the API quick-start snippet in `brand-prompts.md`

---

## Key Notes

> **Nano Banana 2 prompts are prose, not keywords:** The model
> (`gemini-3.1-flash-image-preview`) performs best with narrative descriptions
> that convey intent, mood, and context. Keyword lists produce worse results.
> Every prompt must be 3-5 complete sentences.
>
> **Tokens are derived, not generic:** Every colour in `brand-tokens.json` must
> trace back to a brand answer. Derive tints and shades from the primary and
> secondary brand colours — do not invent unrelated colours.

---

## README Addition

One entry added to `design/README.md`:

### `branding`

Thorough brand identity session. Asks 18 questions across foundation, audience,
personality, visual direction, and context, then generates a complete brand kit:
`brand.md` (strategy + guidelines), `brand-prompts.md` (Nano Banana 2 logo and
photography prompts), and `brand-tokens.json` (design tokens + CSS variables).

**Invoke:** `/design:branding`
**Output files:** `brand.md`, `brand-prompts.md`, `brand-tokens.json`

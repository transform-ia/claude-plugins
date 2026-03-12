# Batch D — Annual Compliance Calendar Design Spec

## Overview

One new skill that reads all available `qc-*.md` state files and produces a
consolidated, chronologically sorted list of upcoming compliance deadlines.

**Skills:**

1. `quebec-compliance-calendar` — On-demand compliance deadline aggregator

**Dependencies:** Reads all existing state files but requires none specifically.
The more skills that have been completed, the more complete the output.

---

## Skill: `quebec-compliance-calendar`

### SKILL.md

```markdown
---
name: quebec-compliance-calendar
description: |
  On-demand compliance calendar that reads all qc-*.md state files and
  generates a consolidated, chronologically sorted list of upcoming deadlines
  and recurring obligations.

  Run at any time to see what is due in the coming weeks and months across
  all registered compliance skills. Especially useful at the start of each
  fiscal year and before the June PACM window.

  This is an advisory/reporting skill — it reads state files but does not
  modify them. Output is displayed in the conversation.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-compliance-calendar
  - User asks "what is due soon?" or "what are my upcoming deadlines?"
  - User wants a summary of all their compliance obligations

  DO NOT activate when:
  - User wants to work through a specific compliance area (use the
    dedicated skill for that area)
allowed-tools:
  Read, AskUserQuestion
---
```

### Behavior

This skill is a reader/reporter. It does **not** write state files.

**On Start:**

1. Read `qc-status.md` to get entity type and organization name.
2. Read all present `qc-*.md` files from the working directory.
3. Extract all deadline fields: `next due`, `renewal date`, recurring annual
   dates, known fixed windows (PACM June–August, T4/RL-1 February 28, etc.).
4. Add hard-coded annual obligations where the date is known regardless of
   state files:
   - February 28: T4/RL-1 slips (CRA/RQ, if employees)
   - March 15: CNESST employer cotisation declaration (if CNESST registered)
   - March 31: GST/QST annual return (if annual filer with Dec 31 year-end)
   - June 1: PACM window opens (if FCMQ member)
   - August 31: PACM window closes
5. Calculate days until each deadline from the current date.
6. Sort chronologically; group into: **Overdue**, **Due in 30 days**,
   **Due in 31–90 days**, **Due in 91+ days**.
7. Display the calendar. Flag any overdue items prominently.

### Output Format

```markdown
# Compliance Calendar — [Organization name]
Generated: [current date]

## ⚠️ Overdue
- [deadline] — [skill/obligation] — [N days overdue]

## Due in 30 days
- [date] — [deadline description] — [skill reference]

## Due in 31–90 days
- [date] — [deadline description] — [skill reference]

## Due in 91+ days
- [date] — [deadline description] — [skill reference]

## Fixed annual windows
- June 1 – August 31: MTQ/PACM application window (SNOW-03)
```

### NEVER / ALWAYS

**NEVER:**

- Modify any state file — this skill is read-only
- Claim a deadline exists if the relevant state file has not been started
  (show "not yet tracked — run [skill name] to set up" instead)

**ALWAYS:**

- Show overdue items first and prominently
- Include the PACM June–August window regardless of whether qc-snowmobile-club.md
  exists — it is the most time-sensitive annual obligation for clubs
- At the end: list any skills in qc-status.md that are not started, as they
  may have obligations the calendar cannot yet show

### Key Note

> **Calendar accuracy depends on state files:** Deadlines are only as accurate
> as the `next due` dates recorded in each skill's state file. After completing
> any filing or renewal, update the relevant state file's next due date. The
> calendar reads whatever is recorded — it does not independently calculate dates.

---

## File Structure

```text
quebec-legal-entity/
└── skills/
    └── quebec-compliance-calendar/
        ├── SKILL.md
        └── instructions.md
```

---

## README addition

One new skill entry appended to `quebec-legal-entity/README.md`.

Note: `qc-status.md` does NOT get a new line for this skill — it is a utility
that produces output, not a compliance workflow with a completion state.

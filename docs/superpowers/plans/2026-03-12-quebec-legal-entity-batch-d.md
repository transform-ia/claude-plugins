# Batch D — Compliance Calendar Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add one read-only compliance deadline aggregator skill (`quebec-compliance-calendar`) to the `quebec-legal-entity` plugin.

**Architecture:** One directory under `quebec-legal-entity/skills/quebec-compliance-calendar/` containing `SKILL.md` (bare YAML front-matter) and `instructions.md` (reader/reporter logic). This skill never writes state files — it reads all `qc-*.md` files and outputs a chronologically sorted deadline calendar in the conversation. No Completion block, no `qc-status.md` line — it is a utility, not a compliance workflow. README.md gets one new entry.

**Tech Stack:** Markdown, YAML front-matter. Plugin framework expects bare `---`-delimited YAML in SKILL.md (no code fence wrappers).

**Spec:** `docs/superpowers/specs/2026-03-12-quebec-legal-entity-batch-d-calendar-design.md`

---

## Chunk 1: Skill Files

### Task 1: `quebec-compliance-calendar` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-compliance-calendar/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-compliance-calendar/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-compliance-calendar/SKILL.md` with exact content:

```
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

**Critical notes for this SKILL.md:**
- `allowed-tools` is `Read, AskUserQuestion` only — this skill must NOT have Write or Edit permissions
- No `Write(qc-status.md)` or any other write permissions
- Bare `---` delimiters (no code fence wrapper when creating the actual file)

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-compliance-calendar/instructions.md` with exact content:

````markdown
# Quebec Compliance Calendar — Deadline Aggregator

This skill reads all available compliance state files and produces a consolidated,
chronologically sorted list of upcoming deadlines and recurring obligations.
It is read-only — it does not modify any state file.

---

## On Start

1. Read `qc-status.md` to get the entity type and Organization name.
2. Read all present `qc-*.md` files from the working directory. Read each file
   that exists; skip silently if a file is absent (it means that skill has not
   yet been run).
   Files to attempt: `qc-incorporation.md`, `qc-obnl.md`, `qc-snowmobile-club.md`,
   `qc-gst-qst.md`, `qc-payroll.md`, `qc-income-tax.md`, `qc-insurance.md`,
   `qc-accounting.md`, `qc-cnesst.md`, `qc-sst.md`, `qc-labour-standards.md`,
   `qc-forprofit-governance.md`, `qc-banking.md`, `qc-document-management.md`,
   `qc-expenses.md`.
3. Extract all deadline fields from each file: any field named `next due`,
   `renewal date`, `Next_due`, `Renewal_date`, or similar date-bearing fields.
   Also extract recurring annual dates stated in step text (e.g., "due Feb 28",
   "due March 31").
4. Add hard-coded annual obligations where the date is known regardless of
   state files:
   - **February 28**: T4/RL-1 slips (CRA/RQ) — include if `qc-payroll.md`
     exists and PAY-08 is not `[n/a]`
   - **February 28**: CNESST DPA (annual salary declaration) — include if
     `qc-cnesst.md` exists
   - **March 31**: GST/QST annual return — include if `qc-gst-qst.md` exists
     and filer is annual with a December 31 year-end; check the state file to
     confirm filing frequency before including
   - **June 1**: PACM window opens — include always (see ALWAYS below)
   - **August 31**: PACM window closes — include always
5. Calculate the number of days from today to each deadline.
6. Sort all items chronologically. Group into four buckets:
   - **Overdue** (past due)
   - **Due in 30 days** (1–30 days from today)
   - **Due in 31–90 days**
   - **Due in 91+ days**
7. Display the calendar using the output format below.
8. After the calendar, list any skills present in `qc-status.md` that are
   `not started` — these may have obligations the calendar cannot yet show.

---

## Output Format

Display the calendar in the following format:

```markdown
# Compliance Calendar — [Organization name]
Generated: [current date]

## ⚠️ Overdue
- [YYYY-MM-DD] — [obligation description] — [skill reference, e.g., PAY-08 / quebec-payroll]
  → [N] days overdue

## Due in 30 days
- [YYYY-MM-DD] — [obligation description] — [skill reference]

## Due in 31–90 days
- [YYYY-MM-DD] — [obligation description] — [skill reference]

## Due in 91+ days
- [YYYY-MM-DD] — [obligation description] — [skill reference]

## Fixed annual windows
- June 1 – August 31: MTQ/PACM application window (SNOW-03 / quebec-snowmobile-club)

## Skills not yet tracked
The following skills have not been started — their deadlines cannot be shown:
- [skill name from qc-status.md]
```

If a bucket is empty, omit it from the output (do not show an empty section).

---

## NEVER / ALWAYS

### NEVER

- Modify any state file — this skill is strictly read-only; it has no Write
  permission and must not attempt to write any file
- Claim a deadline exists if the relevant state file has not been started or
  the relevant step has not been run yet; instead show:
  "not yet tracked — run `/quebec-legal-entity:[skill-name]` to set up"
- Silently omit overdue items — they must appear prominently at the top

### ALWAYS

- Show overdue items first and flag them prominently (use ⚠️ or bold)
- Include the PACM June 1 – August 31 window in the "Fixed annual windows"
  section regardless of whether `qc-snowmobile-club.md` exists — this is
  the most time-sensitive annual obligation for snowmobile clubs and must
  always be visible
- At the end of the calendar output, list any skills in `qc-status.md` that
  are `not started`, so the user knows which compliance areas may have
  untracked obligations
- After displaying the calendar, note: "Calendar accuracy depends on state
  files. After each filing or renewal, update the relevant skill's state file
  next due date."

---

## Calendar accuracy note

> **Calendar accuracy depends on state files:** Deadlines are only as accurate
> as the `next due` dates recorded in each skill's state file. After completing
> any filing or renewal, open the relevant skill (e.g.,
> `/quebec-legal-entity:quebec-payroll`) and update the next due date there.
> The calendar reads whatever is recorded — it does not independently calculate
> dates.
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-compliance-calendar/
git commit -m "feat(quebec-legal-entity): add quebec-compliance-calendar skill (read-only deadline aggregator)"
```

---

## Chunk 2: README Update and Validation

### Task 2: Update README.md

**Files:**
- Modify: `quebec-legal-entity/README.md`

- [ ] **Step 1: Append one skill entry to README.md**

Append the following content to `quebec-legal-entity/README.md` immediately
before the `## Progress Tracking` section:

```markdown
### `/quebec-legal-entity:quebec-compliance-calendar`

**Purpose:** Read-only compliance deadline aggregator. Reads all `qc-*.md`
state files and produces a consolidated, chronologically sorted list of
upcoming deadlines and recurring obligations grouped as: Overdue, Due in
30 days, Due in 31–90 days, and Due in 91+ days. Always shows the PACM
June–August window. Run at any time — especially useful at fiscal year start
and before the June PACM window opens.

**Tags used:** `[GENERIC]`

**Creates:** Nothing — read-only utility skill

**Depends on:** Nothing required. The more skills have been run, the more
complete the output.

**Note:** Does not add a line to `qc-status.md` — this is a utility reporter,
not a compliance workflow with completion state.

---
```

- [ ] **Step 2: Validate file format**

Run markdownlint on the updated README:

```bash
npx markdownlint-cli2 "quebec-legal-entity/README.md"
```

Expected: no errors. If errors appear, fix indentation or heading levels before proceeding.

- [ ] **Step 3: Run plugin validator**

Invoke the `plugin-dev:plugin-validator` agent to verify the plugin structure
is correct after adding the new skill.

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/README.md
git commit -m "docs(quebec-legal-entity): add batch D skill to README (compliance-calendar)"
```

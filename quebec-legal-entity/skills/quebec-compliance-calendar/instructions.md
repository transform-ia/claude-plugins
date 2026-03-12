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
   - **March 15**: CNESST employer cotisation declaration — include if
     `qc-cnesst.md` exists and entity is CNESST registered
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

````markdown
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
````

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

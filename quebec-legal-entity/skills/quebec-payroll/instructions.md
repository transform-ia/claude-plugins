# Quebec Payroll — Source Deductions and Compliance

This skill guides you through payroll setup and ongoing compliance for a Quebec entity
that employs paid staff.

---

## On Start

**Before proceeding:** Read `skills/_shared/learnings-protocol.md`. Then read
`skills/quebec-payroll/learnings.md` if it exists and incorporate any entries into your
working knowledge for this session.

1. Read `qc-status.md`. If `quebec-payroll` is already `[n/a]`, ask:
   "Payroll was previously marked not applicable. Do you now have employees?"
   If yes, reset to `- [ ] quebec-payroll — not started` in `qc-status.md`.

2. If not N/A, ask: "Does your organization have or plan to hire paid employees?"
   - If **no:** Write `- [n/a] quebec-payroll — not applicable (no employees)` to
     `qc-status.md` and tell the user: "Payroll marked as not applicable. Return
     to this skill if you hire employees in the future." Exit.
   - If **yes:** Continue.

3. Read `qc-payroll.md` if present; create it from the template below if absent.

4. Show current payroll status; jump to first unchecked step.

**`qc-payroll.md` template (create if absent):**

```markdown
# Payroll Status — [organization name]
schema_version: 1
RQ_employer_account: pending
CRA_RP_account: pending
Remittance_frequency: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] PAY-01 — RQ employer account registered
- [ ] PAY-02 — CRA RP account registered
- [ ] PAY-03 — Remittance frequency determined
- [ ] PAY-04 — Employee TD1/TP-1015 forms collected
- [ ] PAY-05 — First payroll run complete
- [ ] PAY-06 — DAS remittance to RQ (recurring, next due: [date])
- [ ] PAY-07 — CRA remittance (recurring, next due: [date])
- [ ] PAY-08 — Year-end T4/RL-1 filed (recurring, next due: Feb 28)
- [ ] PAY-09 — Vacation pay compliance confirmed
```

---

## NEVER / ALWAYS

### NEVER

- Skip the employee question at start — proceed to steps only if user confirms employees
- Ignore director liability warning before PAY-01

### ALWAYS

- Warn about director personal liability for unremitted deductions before PAY-01
- Remind the user to set up ClicSEQUR before year-end (before PAY-08 becomes relevant)
- Track next due dates for PAY-06, PAY-07, PAY-08 after each completion

---

## CRITICAL WARNING — Show before PAY-01

> **Director personal liability:** Quebec directors are jointly and severally liable
> for unremitted source deductions (QPP, QPIP, EI, income tax withheld). This is
> not a corporate debt that can be shielded by incorporation — it is a personal
> obligation. Set up remittance reminders and never skip a remittance period.

---

## Steps

---

### PAY-01 `[GENERIC][PROV]` — Register employer account with Revenu Quebec

**What to do:**
Register a Quebec employer account with Revenu Quebec. This account is used for:

- Quebec Pension Plan (QPP) contributions
- Quebec Parental Insurance Plan (QPIP) premiums
- Quebec income tax withholdings (QIT)
- DAS (Declaration des acomptes provisionnels) remittances

**Where:** revenuquebec.ca → "Inscription employeur" or call 1-800-567-4692

**Information required:**

- NEQ
- Start date of first payroll
- Estimated number of employees
- Estimated annual payroll

**Cost:** Free
**Delay:** Registration before first payroll — allow 1–2 weeks

**After confirming registration:** Record the RQ employer account number in
`qc-payroll.md`. Check `PAY-01`.

---

### PAY-02 `[GENERIC][FED]` — Register RP payroll account with CRA

**What to do:**
Register a federal payroll deductions account (RP account) with CRA. This account
is used for:

- Employment Insurance (EI) premiums
- Federal income tax withholdings (FIT)
- Canada Pension Plan — note: Quebec employees pay **QPP** (not CPP), so CPP
  does not apply, but EI and FIT still require the RP account

**Where:** canada.ca/en/revenue-agency → "Business Registration Online (BRO)"
or call 1-800-959-5525

**Your CRA Business Number (BN) will have been assigned** when you registered for
GST/QST (GST-02). The RP account is a sub-account of your BN (e.g., 123456789 RP 0001).

**Cost:** Free
**Delay:** Before first payroll

**After confirming registration:** Record the CRA RP account number in
`qc-payroll.md`. Check `PAY-02`.

---

### PAY-03 `[GENERIC][PROV][FED]` — Determine remittance frequency

**What to do:**
Determine how often you must remit source deductions to both Revenu Quebec and CRA.

**Revenu Quebec remittance frequencies:**

| Frequency | Trigger |
| --- | --- |
| Quarterly | Average monthly withholdings <= $1,000 |
| Monthly | Average monthly withholdings $1,000–$25,000 |
| Accelerated | Average monthly withholdings > $25,000 |

**CRA remittance frequencies:** Similar thresholds apply.

**New employers:** Typically assigned monthly frequency in the first year.

**Cost:** Free
**Delay:** At registration

**After confirming frequency:** Record in `qc-payroll.md` (Remittance_frequency).
Check `PAY-03`.

---

### PAY-04 `[GENERIC][PROV][FED]` — Collect employee tax forms

**What to do:**
Collect completed forms from each new employee before their first pay:

- **Federal:** TD1 (Personal Tax Credits Return) — employee claims federal credits
- **Provincial:** TP-1015.3-V (Source Deductions Return) — employee claims Quebec credits

These forms determine how much income tax to withhold. Keep originals on file.

**Cost:** Free
**Delay:** Before first pay

**After confirming collection:** Check `PAY-04` in `qc-payroll.md`.

---

### PAY-05 `[GENERIC][PROV][FED]` — Run first payroll

**What to do:**
Calculate and process the first payroll. For each employee, withhold:

- **QPP:** 5.40% of pensionable earnings (employee share; employer matches)
- **QPIP:** 0.494% of insurable earnings (employee share; employer pays 0.692%)
- **EI:** 1.66% of insurable earnings (employee share; employer pays 1.4x)
- **QIT:** Per TP-1015.3 tables
- **FIT:** Per TD1 and federal tables

Use Revenu Quebec's "Guide for Employers" (TP-1015.G-V) or payroll software
(Payworks, Ceridian, QuickBooks Payroll, etc.) to calculate correctly.

**Cost:** Payroll software or accountant fee (variable)
**Delay:** Per pay cycle

**After first payroll:** Check `PAY-05` in `qc-payroll.md`.

---

### PAY-06 `[GENERIC][PROV]` — DAS remittance to Revenu Quebec (recurring)

**What to do:**
Remit source deductions to Revenu Quebec via DAS (Declaration des acomptes
provisionnels) on your assigned schedule.

**Due dates:**

- Monthly: 15th of the following month
- Quarterly: 15th of the month following the quarter-end
- Accelerated: varies (contact RQ for schedule)

**Where:** revenuquebec.ca → "Mon dossier pour les entreprises" → "Remittances"

**Cost:** Free
**Delay:** Per frequency

**After each remittance:** Update the `next due` date in `qc-payroll.md`. Check `PAY-06`.

---

### PAY-07 `[GENERIC][FED]` — CRA payroll remittance (recurring)

**What to do:**
Remit EI and federal income tax deductions to CRA on your assigned schedule.

**Due dates:** Same general thresholds as Revenu Quebec.

**Where:** canada.ca → "My Business Account" → "Payroll"

**Cost:** Free
**Delay:** Per frequency

**After each remittance:** Update the `next due` date in `qc-payroll.md`. Check `PAY-07`.

---

### PAY-08 `[GENERIC][PROV][FED]` — Year-end: issue T4 and RL-1 (recurring)

**What to do:**
By February 28 each year, issue year-end slips to all employees:

- **T4** (Statement of Remuneration Paid): file with CRA and give copy to employee
- **RL-1** (Releve 1): file with Revenu Quebec and give copy to employee

**ClicSEQUR setup:** RL-1 slips must be filed electronically via Revenu Quebec's
ClicSEQUR system (mandatory for employers with 5+ employees; recommended for all).
Set up your ClicSEQUR account well before year-end — the process takes time.

**Deadline:** February 28 (or last business day of February)

**Cost:** Free to file
**Delay:** Annual recurring

**After confirming filing:** Update the next due date in `qc-payroll.md`. Check `PAY-08`.

---

### PAY-09 `[GENERIC][PROV]` — Vacation pay compliance

**What to do:**
Ensure vacation pay is calculated and paid per the Act respecting labour standards
(Loi sur les normes du travail):

- **Minimum:** 4% of gross wages (less than 3 years of service)
  or 6% (3 years of service or more)
- Can be paid with each paycheque or accumulated and paid at vacation time

**Cost:** Ongoing
**Delay:** Per employee, per pay cycle

**After confirming compliance setup:** Check `PAY-09` in `qc-payroll.md`.

---

## Completion

When all applicable PAY steps are checked, update `qc-status.md`:
`- [x] quebec-payroll — completed [YYYY-MM-DD]`

Then prompt: "Payroll is set up. Ensure these other compliance skills are also complete:

- `/quebec-legal-entity:quebec-gst-qst` — GST/QST filing
- `/quebec-legal-entity:quebec-income-tax` — corporate income tax"

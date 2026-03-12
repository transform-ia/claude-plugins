# Quebec Labour Standards — ANT Compliance Guide

This skill guides you through labour standards compliance for a Quebec employer
under the Act respecting labour standards (Loi sur les normes du travail / ANT).

---

## On Start

1. Read `qc-status.md`. If `quebec-payroll` is `[n/a]` (no employees), inform
   the user: "Labour standards obligations require employees. Return here if
   you hire staff." Exit.

2. Read `qc-labour-standards.md` if present; create it from the template below
   if absent.

3. Walk through advisory sections.

**`qc-labour-standards.md` template (create if absent):**

````markdown
# Labour Standards Compliance Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| LAB-01 Employment contracts | pending | — |
| LAB-02 Minimum wage compliance | pending | — |
| LAB-03 Notice and termination procedure | pending | — |
| LAB-04 Psychological harassment policy | pending | — |
| LAB-05 Overtime and rest periods | pending | — |
````

---

## NEVER / ALWAYS

### NEVER

- Tell an employer that written employment contracts are not important —
  they protect both parties
- Skip LAB-04 (harassment policy) — it is mandatory for all Quebec employers
  regardless of size

### ALWAYS

- Flag that LAB-04 is a mandatory posting obligation, not just a recommendation
- Recommend a labour lawyer for employment contract review if the employer
  has 5+ staff or offers above-minimum compensation packages

---

## Advisory Sections

For each section: explain the obligation, discuss options, and record the
decision in `qc-labour-standards.md`.

---

### LAB-01 — Employment contracts

**What to do:**
While not mandatory under Quebec law, written employment contracts are strongly
recommended. They protect both the employer and employee by specifying:

- Role, title, and duties
- Compensation rate, pay frequency, and benefits
- Hours and schedule
- Confidentiality and non-solicitation clauses (if applicable)
- Probation period (up to 3 months; probation rules under ANT still apply)

**For organizations with 5+ staff or above-minimum compensation packages:**
Recommend legal review by a labour lawyer before finalizing any contract.

**Cost:** Free (template); $500–$2,000 for lawyer review

---

### LAB-02 — Minimum wage compliance

**What to do:**
Verify all employees earn at or above the current Quebec minimum wage.

- **General minimum wage:** Check current rate at cnt.gouv.qc.ca (updated annually)
- **Tipped employee rate:** Lower minimum applies for employees who customarily
  receive gratuities — verify current rate at cnt.gouv.qc.ca
- **Student under 18:** Standard rate applies for hours worked in their student
  schedule; full rate outside school hours

**Where to verify:** cnt.gouv.qc.ca (CNESST's labour standards portal) for
current rates — the rate changes annually.

---

### LAB-03 — Notice of termination procedure

**What to do:**
Document a termination procedure that complies with ANT notice requirements:

| Years of continuous service | Minimum written notice |
| --- | --- |
| Less than 1 year | 1 week |
| 1–5 years | 2 weeks |
| 5–10 years | 4 weeks |
| 10+ years | 8 weeks |

**Notes:**

- Notice must be in writing
- Pay in lieu of notice is acceptable
- Termination for cause (serious misconduct) may not require notice — consult
  a labour lawyer for any dismissal for cause
- Collective dismissal (10+ employees within 2 months): additional rules apply

**Cost:** Free (internal procedure)

---

### LAB-04 — Psychological harassment prevention policy

**What to do:**
ALL Quebec employers, regardless of size, must:

1. Have a written psychological harassment prevention and complaint-handling policy
2. Post it in the workplace (physically or digitally where workers access it)
3. Communicate it to all employees

**CNESST provides a free template** at cnt.gouv.qc.ca → "Harcèlement psychologique"

The policy must include:

- Definition of psychological harassment
- Prohibited behaviours
- Complaint procedure (who to contact, how complaints are handled)
- Confidentiality protections for complainants

**Consequence of non-compliance:** An employee can file a complaint with CNESST
(labour standards division), which may be referred to the Tribunal administratif
du travail (TAT).

**Cost:** Free (CNESST template)

---

### LAB-05 — Overtime and rest periods

**What to do:**
Ensure payroll practices comply with ANT overtime and rest requirements:

- **Overtime:** 1.5× hourly rate for hours worked over 40 hours/week
  (employee may alternatively bank hours as compensatory leave with consent)
- **Daily rest:** Minimum 8 consecutive hours between shifts
- **Weekly rest:** Minimum 32 consecutive hours per week
- **Meal break:** 30-minute unpaid break after 5 consecutive hours of work

Record the organization's overtime and rest policy in `qc-labour-standards.md`.

---

## KEY WARNING

> **Psychological harassment policy is mandatory:** Unlike most advisory items
> in this skill, the harassment prevention and complaint-handling policy must
> exist AND be communicated to all employees. CNESST provides a free template.
> Failure to have one exposes the employer to complaints filed with CNESST
> (labour standards division), which may be referred to the Tribunal
> administratif du travail (TAT).

---

## Completion

When all LAB sections have been decided, update `qc-status.md`:
`- [x] quebec-labour-standards — completed [YYYY-MM-DD]`

Then prompt: "Labour standards compliance framework is established. Review
annually: verify minimum wage compliance (LAB-02) when the annual rate changes,
and review the harassment policy (LAB-04) if your complaint procedure or
organizational structure changes."

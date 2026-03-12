# Quebec CNESST — Workers' Compensation Registration

This skill guides you through CNESST workers' compensation registration and
ongoing compliance for a Quebec employer.

---

## On Start

1. Read `qc-status.md`. Check the `quebec-payroll` line:
   - `[n/a]` (no employees) → tell user: "CNESST only applies to employers
     with workers. Return here if you hire employees." Exit.
   - `not started` or unchecked → warn: "Complete
     `/quebec-legal-entity:quebec-payroll` first to confirm you have employees.
     If you have already confirmed employees exist, you may proceed."
     Ask to confirm before continuing.
   - `[x] completed` → proceed without warning.

2. Read `qc-cnesst.md` if present; create it from the template below if absent.

3. Present current status; jump to first unchecked step.

**`qc-cnesst.md` template (create if absent):**

```markdown
# CNESST Status — [organization name]
schema_version: 1
Employer_account: pending
Activity_unit: pending
Premium_rate: pending
APM: pending
DPA_filed: pending
Next_DPA_due: Feb 28
Last updated: YYYY-MM-DD

## Steps
- [ ] CNS-01 — Employer account registered with CNESST
- [ ] CNS-02 — Activity unit (unité de classification) identified
- [ ] CNS-03 — First annual salary declaration (DPA) filed (due: Feb 28)
- [ ] CNS-04 — Accident reporting procedure established
- [ ] CNS-05 — Prevention association (APM) membership confirmed
- [ ] CNS-06 — Annual DPA (recurring, next due: Feb 28)
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user CNESST is optional if they have employees — it is mandatory
- Confuse CNESST premiums with payroll source deductions — they are
  employer-only costs, not withheld from employees

### ALWAYS

- At CNS-02: explain that activity unit codes determine the premium rate,
  and misclassification leads to retroactive adjustments; recommend confirming
  with CNESST
- At CNS-04: emphasize the 24-hour reporting window for fatalities and
  hospitalizations; 14 days for lost-time accidents
- At CNS-03: remind that DPA is due February 28, same deadline as T4/RL-1
- At CNS-05: inform the user that not all sectors have an active APM
  (Association paritaire de prévention); if none exists for their sector,
  there is no membership to confirm — note this in the state file

---

## CRITICAL WARNINGS

> **Mandatory for all employers:** CNESST coverage is automatic and mandatory for
> virtually all Quebec workers. Unlike CRA/RQ registration which you apply for,
> CNESST coverage begins the moment you hire a worker — registration regularizes
> your account and determines your premium rate.
>
> **Premium rate varies by risk:** Activity unit codes range from very low rates
> (office work) to high rates (construction, forestry, heavy machinery).
> If your organization operates snowgroomers or heavy equipment, confirm your
> classification — such operations may attract elevated rates.
>
> **Late DPA:** Filing the annual salary declaration (DPA) late results in CNESST
> estimating your payroll based on prior years plus a surcharge.

---

## Steps

---

### CNS-01 `[GENERIC][PROV]` — Register employer account with CNESST

**What to do:**
Register an employer account at cnesst.gouv.qc.ca or by calling 1-844-838-0808.

CNESST coverage begins automatically when you hire a worker. Registration
regularizes your account, assigns your activity unit, and determines your
premium rate.

**Cost:** Free
**Delay:** 1–2 weeks

**After confirming registration:** Record the CNESST employer account number
in `qc-cnesst.md` (Employer_account). Check `CNS-01`.

---

### CNS-02 `[GENERIC][PROV]` — Identify activity unit (unité de classification)

**What to do:**
Your activity unit code determines your CNESST premium rate. CNESST assigns
this based on the primary economic activity of your organization.

- Verify the assigned code with CNESST at registration
- If your organization operates multiple activities (e.g., office work and
  grooming equipment operation), confirm whether a blended rate or separate
  units apply
- Misclassification leads to retroactive adjustments — confirm with CNESST
  rather than assuming

**Cost:** Free
**Delay:** At registration

**After confirming unit:** Record in `qc-cnesst.md` (Activity_unit and
Premium_rate). Check `CNS-02`.

---

### CNS-03 `[GENERIC][PROV]` — File first annual salary declaration (DPA)

**What to do:**
File the Déclaration des salaires (DPA) — your annual payroll declaration to
CNESST. This determines your workers' compensation premium for the year.

**Deadline:** February 28 annually (same as T4/RL-1 slips)

**Where:** cnesst.gouv.qc.ca → "Mon dossier employeur"

**Cost:** Free to file; premium calculated based on declared payroll

**After filing:** Record filing date in `qc-cnesst.md`. Update next due date
(next Feb 28). Check `CNS-03`.

---

### CNS-04 `[GENERIC][PROV]` — Establish accident reporting procedure

**What to do:**
Document an internal procedure for workplace accident reporting:

- **Fatalities and hospitalizations:** Report to CNESST within **24 hours**
- **Lost-time accidents (AT avec perte de temps):** Report within **14 days**
- **First-aid-only accidents:** Record internally; no CNESST reporting required

**Required action:** Designate who is responsible for accident reporting,
document the procedure, and communicate it to all workers.

**Cost:** Free
**Delay:** Before first worker starts

**After procedure is documented:** Check `CNS-04` in `qc-cnesst.md`.

---

### CNS-05 `[GENERIC][PROV]` — Confirm APM membership

**What to do:**
CNESST assigns each employer to a prevention association (Association paritaire
de prévention / APM) based on their activity unit. APMs provide free prevention
services (training, tools, on-site visits) to employers in their sector.

**Important:** Not all sectors have an active APM. If your activity unit has
no APM assigned, there is no action to take — document this in `qc-cnesst.md`
and proceed.

**Where:** Check via CNESST at time of registration.

**Cost:** Free (APM services funded by CNESST)

**After confirming:** Record APM name (or "no APM for this sector") in
`qc-cnesst.md`. Check `CNS-05`.

---

### CNS-06 `[GENERIC][PROV]` — Annual DPA renewal (recurring)

**What to do:**
File the annual DPA each February 28. Premium is calculated on actual payroll
for the prior year.

**Deadline:** February 28 annually

**After each filing:** Update the next due date in `qc-cnesst.md`. Check `CNS-06`.

---

## Completion

When CNS-01 through CNS-05 are checked (CNS-06 is recurring), update
`qc-status.md`:
`- [x] quebec-cnesst — completed [YYYY-MM-DD]`

Then prompt: "CNESST workers' compensation is set up. Annual obligation:
file the DPA by February 28 each year (CNS-06). Consider also completing:

- `/quebec-legal-entity:quebec-sst` — workplace safety prevention program
- `/quebec-legal-entity:quebec-labour-standards` — labour standards compliance"

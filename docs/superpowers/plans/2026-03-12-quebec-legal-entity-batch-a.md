# Batch A — Employer Obligations Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three employer-obligation skills to the `quebec-legal-entity` plugin: `quebec-cnesst` (workers' compensation), `quebec-sst` (workplace safety advisory), and `quebec-labour-standards` (labour standards advisory).

**Architecture:** Each skill is a directory under `quebec-legal-entity/skills/<name>/` containing `SKILL.md` (bare YAML front-matter with `---` delimiters) and `instructions.md` (full procedural markdown). Pattern mirrors existing skills in the plugin (e.g., `quebec-payroll`, `quebec-insurance`). README.md gets three new entries. No code, no tests — content files only.

**Tech Stack:** Markdown, YAML front-matter. Plugin framework expects bare `---`-delimited YAML in SKILL.md (no code fence wrappers).

**Spec:** `docs/superpowers/specs/2026-03-12-quebec-legal-entity-batch-a-employer-design.md`

---

## Chunk 1: Three Skill Files

### Task 1: `quebec-cnesst` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-cnesst/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-cnesst/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-cnesst/SKILL.md` with exact content:

```
---
name: quebec-cnesst
description: |
  Interactive guide for CNESST workers' compensation registration and ongoing
  compliance in Quebec. Covers employer account registration, activity unit
  classification, annual salary declaration (DPA), and workplace accident
  reporting procedures.

  Mandatory for any Quebec employer with at least one worker. Separate from
  payroll source deductions — CNESST is employer-funded workers' compensation.

  Reads and writes qc-cnesst.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-cnesst
  - User asks about CNESST registration, workers' compensation, or workplace
    accident reporting in Quebec
  - User has employees and is setting up their Quebec employer obligations

  DO NOT activate when:
  - User is asking about payroll source deductions (use quebec-payroll)
  - User is asking about workplace safety programs (use quebec-sst)
  - User has no employees
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-cnesst.md), Edit(qc-cnesst.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-cnesst/instructions.md` with exact content:

````markdown
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
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-cnesst/
git commit -m "feat(quebec-legal-entity): add quebec-cnesst skill (workers compensation)"
```

---

### Task 2: `quebec-sst` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-sst/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-sst/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-sst/SKILL.md` with exact content:

```
---
name: quebec-sst
description: |
  Advisory guide for workplace health and safety (SST — santé et sécurité au
  travail) compliance in Quebec under the Act respecting occupational health
  and safety (LSST).

  Covers prevention program requirements (mandatory thresholds vary by risk
  group under the 2021 LSST modernization), safety committee obligations,
  hazard identification, and sector-specific obligations for organizations
  operating heavy equipment (snowgroomers, vehicles).

  This is an advisory skill — it guides decisions and documents choices.
  Run once at setup; revisit when activities or workforce change.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-sst
  - User asks about workplace safety obligations, prevention programs, or
    SST compliance in Quebec
  - User operates heavy equipment or has workers in hazardous conditions

  DO NOT activate when:
  - User is asking about CNESST premium registration (use quebec-cnesst)
  - User has no employees or workers
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-sst.md), Edit(qc-sst.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-sst/instructions.md` with exact content:

````markdown
# Quebec SST — Workplace Health and Safety

This skill guides you through workplace health and safety (SST) compliance
obligations under Quebec's Act respecting occupational health and safety (LSST).

---

## On Start

1. Read `qc-status.md`. If `quebec-payroll` is `[n/a]` (no employees), inform
   the user: "SST obligations are not triggered without employees or workers.
   Return here if you hire staff or engage contractors." Exit.

2. Read `qc-sst.md` if present; create it from the template below if absent.

3. Ask: "Does your organization operate heavy equipment such as snowgroomers,
   tractors, or other vehicles?" Record the answer — it determines whether
   SST-05 applies.

4. Walk through advisory sections.

**`qc-sst.md` template (create if absent):**

```markdown
# SST (Workplace Safety) Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| SST-01 Prevention program | pending | — |
| SST-02 Safety committee | pending | — |
| SST-03 Hazard register | pending | — |
| SST-04 Emergency procedures | pending | — |
| SST-05 Sector-specific obligations | pending | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell an employer that a prevention program is optional if they have 20+
  workers or operate in a high-risk sector (Groups I–II under LSST) — it is
  mandatory
- Apply a flat "20 workers" rule without qualifying by risk group — the LSST
  modernization (Bill 59) sets different thresholds by group
- Conflate LSST (physical safety) with ANT (psychological harassment); direct
  user to `/quebec-legal-entity:quebec-labour-standards` for LAB-04

### ALWAYS

- At SST-02: clarify that the safety committee threshold varies by risk group;
  do not state a flat "20 workers" rule without qualifying by sector
- At SST-05: only present heavy-equipment obligations if user confirmed they
  operate heavy equipment

---

## Advisory Sections

For each section: explain the obligation, determine whether it applies, and
record the decision in `qc-sst.md`.

---

### SST-01 — Prevention program

**Who must have one:**

Under the LSST modernization (Bill 59, phased 2023–2024):
- **Groups I and II (high-risk sectors):** Written prevention program mandatory
  for ALL employers regardless of worker count
- **Groups III and IV (lower-risk sectors):** Written prevention program
  mandatory at 20+ workers

Determine your risk group from your CNESST activity unit (CNS-02). High-risk
sectors include construction, forestry, agriculture, and heavy equipment operation.

**What the program must cover:** Hazard identification, control measures,
worker training, roles and responsibilities.

**Cost:** Free (internal effort)

---

### SST-02 — Safety committee (CSS)

**Who must have one:**

A joint health and safety committee (Comité de santé et sécurité / CSS) is
required at thresholds that vary by risk group under LSST. The threshold is
**not** a flat "20 workers" rule across all sectors.

- Groups I–II: Thresholds are lower (check your activity unit with CNESST)
- Groups III–IV: Generally 20+ workers triggers the requirement

If a CSS is required, it must include worker and employer representatives.

**Cost:** Free (internal effort)

---

### SST-03 — Hazard register

**Who must have one:** All employers with workers, regardless of size.

A hazard register (registre des risques) identifies:
- Physical hazards (equipment, environment)
- Chemical hazards (products, fumes)
- Ergonomic hazards (lifting, repetitive motion)
- Psychosocial hazards (harassment, stress — cross-reference LAB-04)

Update whenever activities, equipment, or worksite conditions change.

**Cost:** Free (internal effort)

---

### SST-04 — Emergency procedures and first aid

**Who must have one:** All employers with workers, regardless of size.

Document:
- Emergency evacuation procedures
- First aid kit location and first-aid-trained personnel
- Emergency contact numbers (ambulance, CNESST accident reporting line)
- Procedures for specific risks (chemical spill, machinery accident)

**Cost:** First aid kit $50–$200; training variable

---

### SST-05 — Sector-specific obligations (heavy equipment)

**Applies only if:** User confirmed operating heavy equipment (snowgroomers,
tractors, vehicles used in field operations).

Key obligations for heavy equipment operators:
- Operators must have appropriate training and competency documentation
- Equipment must be inspected before each use and maintained per manufacturer
  requirements
- Safe operating procedures must be documented and communicated to operators
- Proximity to public (trails, roads): follow applicable VHR Act and municipal
  signage requirements

Record the specific equipment types and training requirements in `qc-sst.md`.

---

## KEY WARNING

> **Psychological harassment prevention is ANT, not LSST:** Under the Act
> respecting labour standards (ANT), ALL Quebec employers regardless of size
> must have a psychological harassment prevention and complaint-handling policy.
> This is a labour standards obligation, not a workplace safety obligation.
> See `/quebec-legal-entity:quebec-labour-standards` (LAB-04).

---

## Completion

When all SST sections have been decided (or marked N/A where applicable),
update `qc-status.md`:
`- [x] quebec-sst — completed [YYYY-MM-DD]`

Then prompt: "SST compliance framework is established. Revisit when activities
change (new equipment, new worksites, workforce growth). Annual reminder:
update the hazard register (SST-03) and review emergency procedures (SST-04)."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-sst/
git commit -m "feat(quebec-legal-entity): add quebec-sst skill (workplace safety advisory)"
```

---

### Task 3: `quebec-labour-standards` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-labour-standards/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-labour-standards/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-labour-standards/SKILL.md` with exact content:

```
---
name: quebec-labour-standards
description: |
  Advisory guide for Quebec labour standards compliance under the Act
  respecting labour standards (ANT — Loi sur les normes du travail).

  Covers employment contracts, minimum wage, notice of termination, severance,
  psychological harassment prevention policy (mandatory for all employers),
  and overtime rules.

  This is an advisory skill — it guides compliance decisions and documents
  choices. No government filings required for most items (except harassment
  policy which must be posted in the workplace).

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-labour-standards
  - User is hiring employees and needs to understand their legal obligations
    under Quebec labour law
  - User wants to set up employment contracts or a harassment prevention policy

  DO NOT activate when:
  - User is asking about source deductions (use quebec-payroll)
  - User is asking about CNESST workers' compensation (use quebec-cnesst)
  - User has no employees
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-labour-standards.md), Edit(qc-labour-standards.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-labour-standards/instructions.md` with exact content:

````markdown
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

```markdown
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
```

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
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-labour-standards/
git commit -m "feat(quebec-legal-entity): add quebec-labour-standards skill (ANT advisory)"
```

---

## Chunk 2: README Update and Validation

### Task 4: Update README.md

**Files:**
- Modify: `quebec-legal-entity/README.md`

- [ ] **Step 1: Append three skill entries to README.md**

Append the following content to `quebec-legal-entity/README.md` immediately
before the `## Progress Tracking` section:

```markdown
### `/quebec-legal-entity:quebec-cnesst`

**Purpose:** CNESST workers' compensation registration and ongoing compliance.
Covers employer account registration, activity unit classification, annual salary
declaration (DPA), and accident reporting procedures. Mandatory for any Quebec
employer with at least one worker.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-cnesst.md`

**Depends on:** `quebec-payroll` (presence of employees)

---

### `/quebec-legal-entity:quebec-sst`

**Purpose:** Advisory workplace health and safety (SST) compliance guide under
the LSST. Covers prevention program requirements (LSST Bill 59 risk groups),
safety committee obligations, hazard identification, and heavy-equipment
obligations for groomer/vehicle operators.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-sst.md`

**Depends on:** `quebec-payroll` (presence of employees)

---

### `/quebec-legal-entity:quebec-labour-standards`

**Purpose:** Advisory Quebec labour standards compliance guide under ANT.
Covers employment contracts, minimum wage, notice of termination, psychological
harassment prevention policy (mandatory for all employers), and overtime rules.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-labour-standards.md`

**Depends on:** `quebec-payroll` (presence of employees)

---
```

- [ ] **Step 2: Validate file format**

Run markdownlint on the updated README:

```bash
npx markdownlint-cli2 "quebec-legal-entity/README.md"
```

Expected: no errors. If errors appear, fix indentation or heading levels.

- [ ] **Step 3: Run plugin validator**

Invoke the `plugin-dev:plugin-validator` agent to verify the plugin structure
is correct after adding the three new skills.

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/README.md
git commit -m "docs(quebec-legal-entity): add batch A skills to README (cnesst, sst, labour-standards)"
```

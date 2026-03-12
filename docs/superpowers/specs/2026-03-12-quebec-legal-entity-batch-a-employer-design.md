# Batch A — Employer Obligations Design Spec

## Overview

Three new skills added to the `quebec-legal-entity` plugin covering mandatory
employer obligations that arise as soon as a Quebec entity hires paid staff.
These complement the existing `quebec-payroll` skill, which handles source
deduction mechanics but does not cover workers' compensation, workplace safety,
or full labour standards compliance.

**Skills:**

1. `quebec-cnesst` — Workers' compensation registration, premium declarations,
   accident reporting
2. `quebec-sst` — Workplace health & safety prevention program (advisory)
3. `quebec-labour-standards` — ANT labour standards compliance advisory
   (contracts, notice, harassment policy)

**Dependency:** All three skills are unlocked by the presence of employees.
They naturally follow `quebec-payroll` (skill marked `[x] completed` or
entity confirmed to have employees in `qc-status.md`). None depend on each other.

---

## File structure per skill

Each skill is a directory under `quebec-legal-entity/skills/<name>/` containing:

- **SKILL.md** — YAML front-matter activation header (name, description with
  ONLY/DO NOT, allowed-tools). Short — Claude reads this to decide whether to
  activate the skill.
- **instructions.md** — Procedural content: On Start logic, state file template,
  NEVER/ALWAYS, step detail, key warnings, completion block.

The SKILL.md blocks below show the full YAML including `---` delimiters.
The instructions.md sections describe what that file must contain.

---

## State Files

| Skill | State file | Type |
| --- | --- | --- |
| `quebec-cnesst` | `qc-cnesst.md` | Sequential steps |
| `quebec-sst` | `qc-sst.md` | Advisory decisions log |
| `quebec-labour-standards` | `qc-labour-standards.md` | Advisory decisions log |

All skills read `qc-status.md` for entity context and update it on completion.

---

## Skill 1: `quebec-cnesst`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md`. Check `quebec-payroll` line:
   - `[n/a]` (no employees) → tell user "CNESST only applies to employers
     with workers. Return here if you hire employees." Exit.
   - `not started` or unchecked → warn "Complete `/quebec-legal-entity:quebec-payroll`
     first to confirm you have employees. If you have already confirmed employees
     exist, you may proceed." Ask to confirm before continuing.
   - `[x] completed` → proceed without warning.
2. Read `qc-cnesst.md`; create from template if absent.
3. Present status; jump to first unchecked step.

**State file template (`qc-cnesst.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell the user CNESST is optional if they have employees — it is mandatory
- Confuse CNESST premiums with payroll source deductions — they are
  employer-only costs

ALWAYS:
- At CNS-02: explain that activity unit codes determine the premium rate,
  and misclassification leads to retroactive adjustments; recommend confirming
  with CNESST
- At CNS-04: emphasize the 24-hour reporting window for fatalities and
  hospitalizations; 14 days for lost-time accidents
- At CNS-03: remind that DPA is due February 28, same deadline as T4/RL-1
- At CNS-05: inform the user that not all sectors have an active APM
  (Association paritaire de prévention); if none exists for their sector,
  there is no membership to confirm — note this in the state file

**Steps:**

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| CNS-01 | Register employer account at cnesst.gouv.qc.ca | Free | 1–2 weeks |
| CNS-02 | Identify activity unit code (determines premium rate) | Free | At registration |
| CNS-03 | File first DPA (Déclaration des salaires) | Free | Feb 28 annually |
| CNS-04 | Establish accident reporting procedure (fatality/hospitalization: within 24h; lost-time accident: within 14 days) | Free | Before first worker |
| CNS-05 | Confirm APM membership — assigned by sector; if no APM exists for your sector, document this and proceed | Free | At registration |
| CNS-06 | Annual DPA renewal (recurring, due February 28) | Premium varies by payroll | Annual |

**Key Warnings:**

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

## Skill 2: `quebec-sst`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md`. If `quebec-payroll` is `[n/a]`, inform user SST
   obligations are not triggered and exit.
2. Read `qc-sst.md`; create from template if absent.
3. Ask whether the entity operates heavy equipment (snowgroomers, tractors,
   vehicles) — this determines whether SST-05 applies.
4. Walk through advisory sections.

**State file template (`qc-sst.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell an employer that a prevention program is optional if they have 20+
  workers or operate in a high-risk sector (Groups I–II under LSST) — it is
  mandatory
- Conflate LSST (physical safety) with ANT (psychological harassment); direct
  user to `/quebec-legal-entity:quebec-labour-standards` for LAB-04

ALWAYS:
- At SST-02: clarify that the safety committee threshold varies by risk group;
  do not state a flat "20 workers" rule without qualifying by sector
- At SST-05: only present heavy-equipment obligations if user confirmed they
  operate heavy equipment

**Advisory Sections:**

| Section | Trigger | Content |
| --- | --- | --- |
| SST-01 | Groups I–II (any size) or Groups III–IV with 20+ workers | Written prevention program. **Under LSST modernization (Bill 59, phased 2023–2024): mandatory for ALL Group I and II employers regardless of worker count; mandatory for Groups III and IV at 20+ workers.** |
| SST-02 | Thresholds vary by risk group | Joint health & safety committee (CSS). **Not a flat 20-worker rule — verify applicable threshold based on activity unit (CNS-02).** |
| SST-03 | All employers | Hazard identification and risk register |
| SST-04 | All employers | Emergency procedures and first aid |
| SST-05 | Heavy equipment operators | Specific LSST obligations for grooming, forestry, heavy machinery operation |

**Key Warning:**

> **Psychological harassment prevention is ANT, not LSST:** Under the Act
> respecting labour standards (ANT), ALL Quebec employers regardless of size
> must have a psychological harassment prevention and complaint-handling policy.
> This is a labour standards obligation, not a workplace safety obligation.
> See `/quebec-legal-entity:quebec-labour-standards` (LAB-04).

---

## Skill 3: `quebec-labour-standards`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md`. If `quebec-payroll` is `[n/a]`, inform and exit.
2. Read `qc-labour-standards.md`; create from template if absent.
3. Walk through advisory sections.

**State file template (`qc-labour-standards.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell an employer that written employment contracts are not important —
  they protect both parties
- Skip LAB-04 (harassment policy) — it is mandatory for all employers
  regardless of size

ALWAYS:
- Flag that LAB-04 is a mandatory posting obligation, not just a recommendation
- Recommend a labour lawyer for employment contract review if the employer
  has 5+ staff or offers above-minimum compensation packages

**Advisory Sections:**

| Section | Content |
| --- | --- |
| LAB-01 | Written employment contracts (not mandatory but strongly recommended; specify role, rate, hours, benefits, confidentiality) |
| LAB-02 | Minimum wage compliance — verify current rate at the CNESST normes du travail portal (cnt.gouv.qc.ca); tipped vs non-tipped rates; student rates |
| LAB-03 | Notice of termination: 1 week (< 1 year service) up to 8 weeks (10+ years); written notice required |
| LAB-04 | Psychological harassment prevention policy: **mandatory for all Quebec employers**; must be posted in the workplace; must include complaint procedure; CNESST provides a free template |
| LAB-05 | Overtime at 1.5× after 40 hours/week; compensatory leave alternative with employee consent |

**Key Warning:**

> **Psychological harassment policy is mandatory:** Unlike most advisory items
> in this skill, the harassment prevention and complaint-handling policy must
> exist AND be communicated to all employees. CNESST provides a free template.
> Failure to have one exposes the employer to complaints filed with CNESST
> (labour standards division), which may be referred to the Tribunal
> administratif du travail (TAT).

---

## `qc-status.md` entries

These three lines are added to the Skills section. Each supports three states:

```markdown
- [ ] quebec-cnesst — not started
- [n/a] quebec-cnesst — not applicable (no employees)
- [x] quebec-cnesst — completed [YYYY-MM-DD]

- [ ] quebec-sst — not started
- [n/a] quebec-sst — not applicable (no employees)
- [x] quebec-sst — completed [YYYY-MM-DD]

- [ ] quebec-labour-standards — not started
- [n/a] quebec-labour-standards — not applicable (no employees)
- [x] quebec-labour-standards — completed [YYYY-MM-DD]
```

Initial state written to `qc-status.md` on first run: `not started`.

---

## File Structure

```text
quebec-legal-entity/
└── skills/
    ├── quebec-cnesst/
    │   ├── SKILL.md
    │   └── instructions.md
    ├── quebec-sst/
    │   ├── SKILL.md
    │   └── instructions.md
    └── quebec-labour-standards/
        ├── SKILL.md
        └── instructions.md
```

---

## README additions

Three new skill entries appended to `quebec-legal-entity/README.md`.

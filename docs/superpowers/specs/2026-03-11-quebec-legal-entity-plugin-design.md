# Quebec Legal Entity Plugin — Design Spec

**Status:** Draft
**Date:** 2026-03-11

## Overview

Rename and expand `legal-entity-incorporation` into `quebec-legal-entity`: a comprehensive
Claude skill plugin covering the full lifecycle of a Quebec legal entity — from name search
through ongoing compliance obligations.

The plugin grows from 3 skills (incorporation, OBNL, snowmobile) to 8 skills covering
incorporation, non-profit specifics, sector operations, tax, payroll, GST/QST, insurance,
and accounting.

No existing users. Breaking changes (renamed plugin, new skill invocation paths, new state
files) are acceptable.

---

## Plugin Rename

| | Before | After |
| --- | --- | --- |
| Directory | `legal-entity-incorporation/` | `quebec-legal-entity/` |
| Invocation prefix | `/legal-entity-incorporation:*` | `/quebec-legal-entity:*` |
| `plugin.json` name | `legal-entity-incorporation` | `quebec-legal-entity` |

---

## State File Architecture

Two levels of state tracking:

### Master file: `qc-status.md`

Created by `quebec-incorporation` on first run. One line per skill. Provides a single
overview of the entire entity's Quebec compliance status.

```markdown
# Quebec Legal Entity Status
schema_version: 2
Organization: [name]
Entity type: for-profit | obnl
Last updated: YYYY-MM-DD

## Skills
- [ ] quebec-incorporation — not started
- [ ] quebec-obnl — not started (obnl only)
- [ ] quebec-gst-qst — not started
- [ ] quebec-payroll — not started
- [ ] quebec-income-tax — not started
- [ ] quebec-insurance — not started
- [ ] quebec-accounting — not started
- [ ] quebec-snowmobile-club — not started (sector-specific)
```

- `Entity type` field is set on first run (asked once by `quebec-incorporation`).
- Each skill marks itself complete in this file when all its steps are done.
- Skills read this file to check prerequisites and show overall context.

### Per-skill detail files

Each skill reads/writes its own file for step-level tracking.

| Skill | Detail file |
| --- | --- |
| `quebec-incorporation` | `qc-incorporation.md` |
| `quebec-obnl` | `qc-obnl.md` |
| `quebec-gst-qst` | `qc-gst-qst.md` |
| `quebec-payroll` | `qc-payroll.md` |
| `quebec-income-tax` | `qc-income-tax.md` |
| `quebec-insurance` | `qc-insurance.md` |
| `quebec-accounting` | `qc-accounting.md` |
| `quebec-snowmobile-club` | `qc-snowmobile-club.md` |

Each detail file uses the same checkbox format as the current `obnl-status.md` but scoped
to that skill only.

---

## Step ID Scheme

Skill-prefixed IDs replace the numeric S1-xx / S2-xx / S3-xx scheme (cleaner, no
renumbering risk when skills are added):

| Skill | Prefix | Example |
| --- | --- | --- |
| `quebec-incorporation` | `INC` | `INC-01` |
| `quebec-obnl` | `OBNL` | `OBNL-01` |
| `quebec-snowmobile-club` | `SNOW` | `SNOW-01` |
| `quebec-gst-qst` | `GST` | `GST-01` |
| `quebec-payroll` | `PAY` | `PAY-01` |
| `quebec-income-tax` | `TAX` | `TAX-01` |
| `quebec-insurance` | `INS` | `INS-01` |
| `quebec-accounting` | `ACC` | `ACC-01` |

---

## Skills

### Skill 1: `quebec-incorporation` [MIGRATED]

**Type:** Step-by-step
**Creates:** `qc-status.md`, `qc-incorporation.md`
**Tags:** `[GENERIC]` `[PROV]`

**Changes from current version:**

- State file renamed from `obnl-status.md` to `qc-incorporation.md`; master `qc-status.md` created alongside it
- Step IDs changed from S1-xx to INC-xx
- GST/QST registration step removed — replaced with prompt to use `quebec-gst-qst`
- Source deduction registration step removed — replaced with prompt to use `quebec-payroll`
- Entity type asked on first run; stored in `qc-status.md`
- Post-incorporation gate now references `qc-obnl.md` / OBNL-05 (was S2-05)

**Steps:**

| ID | Action | Cost (2025) | Delay | Tag |
| --- | --- | --- | --- | --- |
| INC-01 | Name search at REQ | Free | Immediate | `[GENERIC][PROV]` |
| INC-02 | Name reservation (optional) | $27–$40.50 | 2–5 bus. days | `[GENERIC][PROV]` |
| *(gate: requires OBNL-05 for OBNL entities; or incorporation docs for for-profit)* | | | | |
| INC-03 | Initial REQ declaration (within 60 days) | Free | Immediate | `[GENERIC][PROV]` |
| INC-04 | Bank account opened | $0–$25/mo | 1–2 weeks | `[GENERIC]` |
| INC-05 | REQ annual update declaration (recurring) | $41/year | Immediate | `[GENERIC][PROV]` |

**Completion prompts:**

- After INC-02: continue with `quebec-obnl` (if OBNL) or file articles (if for-profit)
- After full completion: prompt for `quebec-gst-qst`, `quebec-payroll`, `quebec-income-tax`, `quebec-insurance`, `quebec-accounting`

---

### Skill 2: `quebec-obnl` [MIGRATED]

**Type:** Step-by-step
**Creates:** `qc-obnl.md`
**Prerequisite:** INC-01 checked
**Tags:** `[OBNL]` `[PROV]` `[FED]`

**Changes from current version:**

- State file renamed to `qc-obnl.md`
- Step IDs changed from S2-xx to OBNL-xx
- S2-08 (CO-17.SP) and S2-09 (T2+T1044) removed — moved to `quebec-income-tax`
- S2-12 (annual tax returns confirmation) removed — redundant with income-tax skill
- OBNL-05 milestone still surfaces NEQ, B2_date, D1_deadline explicitly

**Steps:**

| ID | Action | Cost (2025) | Delay | Tag |
| --- | --- | --- | --- | --- |
| OBNL-01 | Confirm 3+ founding members and mission | Free | 1–4 weeks | `[OBNL][PROV]` |
| OBNL-02 | Draft RE-303 + sworn declaration | $0–$100 | 1–3 weeks | `[OBNL][PROV]` |
| OBNL-03 | Draft by-laws (dissolution clause required) | $0–$2,000 | 1–4 weeks | `[OBNL][PROV]` |
| OBNL-04 | File RE-303 with REQ (mail/in-person only) | $199–$298.50 | 5–10 bus. days | `[OBNL][PROV]` |
| OBNL-05 | Receive letters patent + NEQ *(milestone)* | Included | Same as OBNL-04 | `[OBNL][PROV]` |
| OBNL-06 | Hold constitutive general assembly | Free | Within weeks | `[OBNL][PROV]` |
| OBNL-07 | Set up minute book | $0–$200 | Concurrent | `[OBNL][PROV]` |
| OBNL-08 | Annual general assembly (recurring) | Free | Annual | `[OBNL][PROV]` |
| OBNL-09 | Annual financial statements (recurring) | $500–$3,000 | Annual | `[OBNL]` |

**Completion prompt:** continue with INC-03 (post-inc gate), then `quebec-income-tax`, `quebec-snowmobile-club`

---

### Skill 3: `quebec-snowmobile-club` [MIGRATED]

**Type:** Step-by-step
**Creates:** `qc-snowmobile-club.md`
**Prerequisite:** OBNL-05 + OBNL-06 checked
**Tags:** `[SECTOR-SPECIFIC]`

**Changes from current version:**

- State file renamed to `qc-snowmobile-club.md`
- Step IDs changed from S3-xx to SNOW-xx
- No content changes

**Steps:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| SNOW-01 | FCMQ membership application submitted | Annual fee (TBD) | Immediate |
| SNOW-02 | FCMQ membership approved (board decision) | Included | Weeks–months |
| SNOW-03 | MTQ/PACM application (June–August window) | Free | Annual |
| SNOW-04 | Insurance obtained (FCMQ base + supplemental) | $1,500–$4,000/year | Concurrent |
| SNOW-05 | VHR trail designation from MTQ | Variable | Variable |
| SNOW-06 | FCMQ annual renewal (recurring) | Annual fee | Annual |

---

### Skill 4: `quebec-gst-qst` [NEW]

**Type:** Step-by-step
**Creates:** `qc-gst-qst.md`
**Prerequisite:** INC-01 checked (NEQ recommended but registration can precede it for for-profit)
**Tags:** `[GENERIC]` `[PROV]` `[FED]`

**Scope:** Covers registration (mandatory if taxable supplies exceed $30,000 threshold),
filing frequency selection, ongoing return filing, input tax credits (ITCs / RTIs),
and instalment obligations.

**Steps:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| GST-01 | Assess registration obligation (threshold or voluntary) | Free | Immediate |
| GST-02 | Register for GST/QST with Revenu Québec (LM-1 / online) | Free | 2–4 weeks |
| GST-03 | Select filing frequency (monthly / quarterly / annual) | Free | At registration |
| GST-04 | Set up ITC/RTI tracking in bookkeeping system | Free | Before first return |
| GST-05 | File first GST/QST return | Free to file | Per selected frequency |
| GST-06 | Ongoing return filing (recurring) | Free to file | Monthly/quarterly/annual |

**Key warnings to embed:**

- Voluntary registration is often beneficial even below threshold (ITC recovery)
- Late filing penalty: 1% of net tax + 25% of that per month, up to 12 months
- Instalment obligations trigger when annual net tax > $3,000

---

### Skill 5: `quebec-payroll` [NEW]

**Type:** Step-by-step
**Creates:** `qc-payroll.md`
**Prerequisite:** INC-01 checked; only relevant if hiring employees
**Tags:** `[GENERIC]` `[PROV]` `[FED]`

**Scope:** Source deduction registration, DAS remittance schedule and deadlines,
first payroll run checklist, year-end T4/RL-1 filing, vacation pay rules.

**On Start:** Ask "Do you have or plan to hire paid employees?" — if no, mark skill as N/A in `qc-status.md`.

**Steps:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| PAY-01 | Register for source deductions with Revenu Québec (employer account) | Free | Before first payroll |
| PAY-02 | Register for payroll with CRA (RP account) | Free | Before first payroll |
| PAY-03 | Determine remittance frequency (quarterly / monthly / accelerated) | Free | At registration |
| PAY-04 | Set up payroll records (employee TD1/TP-1015 forms collected) | Free | Before first pay |
| PAY-05 | First payroll run: withhold QPP, QPIP, QIT, EI, FIT, employer contributions | Free | Per pay cycle |
| PAY-06 | DAS remittance to Revenu Québec (recurring) | Free | Per frequency |
| PAY-07 | CRA payroll remittance (recurring) | Free | Per frequency |
| PAY-08 | Year-end: issue T4 (CRA) + RL-1 (Revenu Québec) | Free to file | Feb 28 / Feb 28 |
| PAY-09 | Vacation pay compliance | Ongoing | Per employee |

**Key warnings to embed:**

- Director personal liability for unremitted source deductions (same as OBNL warning)
- Accelerated remittance triggers if average monthly withholdings > $25,000
- RL-1s filed via RQ ClicSÉQUR — account setup takes time, do it early

---

### Skill 6: `quebec-income-tax` [NEW]

**Type:** Step-by-step with entity-type branching
**Creates:** `qc-income-tax.md`
**Prerequisite:** INC-01 checked
**Tags:** `[GENERIC][PROV][FED]` (for-profit) or `[OBNL][PROV][FED]` (OBNL)

**On Start:** Read `Entity type` from `qc-status.md`. If not set, ask.
Branch to the appropriate step sequence.

#### Branch A — For-profit corporation

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| TAX-01 | Confirm fiscal year-end (set at incorporation or at first T2) | Free | At setup |
| TAX-02 | Assess instalment obligation (if prior year tax > $3,000) | Free | 2nd and 3rd month of FY |
| TAX-03 | Year-end: prepare financial statements | $500–$3,000 | Within 6 months of FY-end |
| TAX-04 | File T2 corporate income tax return (CRA) | Free to file | Within 6 months of FY-end |
| TAX-05 | Pay balance owing | Variable | Within 2 months of FY-end |
| TAX-06 | Annual recurring (TAX-02 through TAX-05) | — | Annual |

#### Branch B — OBNL

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| TAX-01 | Confirm fiscal year-end | Free | At setup |
| TAX-02 | Year-end: prepare financial statements | $500–$3,000 | Within 6 months of FY-end |
| TAX-03 | File CO-17.SP with Revenu Québec (claim s.998 exemption) | Free to file | Within 6 months of FY-end |
| TAX-04 | File T2 with CRA (claim 149(1)(l) exemption) | Free to file | Within 6 months of FY-end |
| TAX-05 | File T1044 NPO Information Return if assets > $200k or revenues > $100k | Free to file | With T2 |
| TAX-06 | Annual recurring (TAX-02 through TAX-05) | — | Annual |

**Key warnings to embed:**

- OBNL: cannot issue charitable tax receipts; 149(1)(l) exemption is not charitable status
- For-profit: instalment interest compounds daily — set calendar reminders

---

### Skill 7: `quebec-insurance` [NEW]

**Type:** Advisory (decision guide, not sequential steps)
**Creates:** `qc-insurance.md` (checklist of coverage obtained)
**Prerequisite:** none
**Tags:** `[GENERIC]`

**Scope:** Guides the user through selecting appropriate coverage by entity type and
activity profile. Produces a checklist of coverage obtained with insurer, policy number,
renewal date.

**Advisory sections:**

| Section | Content |
| --- | --- |
| INS-01 | General liability — mandatory minimum for any entity with third-party exposure |
| INS-02 | Directors & officers (D&O) — highly recommended for any board; protects directors personally |
| INS-03 | Property — for entities owning equipment, vehicles, or physical assets |
| INS-04 | Errors & omissions (E&O) — for professional services organizations |
| INS-05 | Event liability — one-time or annual events open to the public |
| INS-06 | Sector-specific riders — e.g., snowmobile club trail operations (see `quebec-snowmobile-club`) |

For each section: explain what it covers, who needs it, typical cost range, how to obtain it.
Record each coverage obtained in `qc-insurance.md`.

---

### Skill 8: `quebec-accounting` [NEW]

**Type:** Advisory (decision guide)
**Creates:** `qc-accounting.md` (decisions log)
**Prerequisite:** none
**Tags:** `[GENERIC]`

**Scope:** Guides decisions around bookkeeping setup before the first transaction. Not a
recurring step guide — run once at entity formation.

**Advisory sections:**

| Section | Content |
| --- | --- |
| ACC-01 | Fiscal year-end choice — tradeoffs between calendar year, incorporation anniversary, sector cycle (Apr 1–Mar 31 for FCMQ/PACM) |
| ACC-02 | Accounting software — QuickBooks, Wave (free), Sage, Acomba (Quebec-specific); tradeoffs |
| ACC-03 | Chart of accounts basics — standard Quebec OBNL chart vs for-profit chart |
| ACC-04 | Bookkeeper vs CPA — when to DIY, when to hire, what to expect to pay |
| ACC-05 | Record retention — Quebec rules: 6 years for most documents |

---

## File Structure

```text
quebec-legal-entity/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── quebec-incorporation/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-obnl/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-snowmobile-club/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-gst-qst/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-payroll/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-income-tax/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-insurance/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   └── quebec-accounting/
│       ├── SKILL.md
│       └── instructions.md
└── README.md
```

---

## Migration Summary

| | Old | New |
| --- | --- | --- |
| Plugin dir | `legal-entity-incorporation/` | `quebec-legal-entity/` |
| State file | `obnl-status.md` (single) | `qc-status.md` + 8 per-skill files |
| Step IDs | S1-xx, S2-xx, S3-xx | INC-xx, OBNL-xx, SNOW-xx, GST-xx, PAY-xx, TAX-xx, INS-xx, ACC-xx |
| GST/QST reg step | In `quebec-incorporation` (S1-04) | Moved to `quebec-gst-qst` (GST-02) |
| Payroll reg step | In `quebec-incorporation` (S1-06) | Moved to `quebec-payroll` (PAY-01/02) |
| OBNL tax returns | In `quebec-obnl` (S2-08/S2-09/S2-12) | Moved to `quebec-income-tax` (TAX-03–05) |

Old plugin directory is deleted; no backwards compatibility shim needed (no users).

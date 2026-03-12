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

**Scope:** This plugin targets Quebec OBNL (non-profit) entities primarily. For-profit
incorporation proper (drafting and filing articles of incorporation) is out of scope — the
`quebec-incorporation` skill assumes a for-profit entity already holds its NEQ when it
starts INC-03. The GST/QST, payroll, income-tax, insurance, and accounting skills apply
equally to for-profit and OBNL entities.

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

Created by `quebec-incorporation` on first run. One line per skill showing high-level
status. Provides a single overview of the entity's entire Quebec compliance picture.

```markdown
# Quebec Legal Entity Status
schema_version: 1
Organization: [name]
Entity type: for-profit | obnl
Last updated: YYYY-MM-DD

## Skills
- [ ] quebec-incorporation — not started
- [ ] quebec-obnl — not started (obnl only)
- [ ] quebec-gst-qst — not started
- [n/a] quebec-payroll — not applicable (no employees)
- [ ] quebec-income-tax — not started
- [ ] quebec-insurance — not started
- [ ] quebec-accounting — not started
- [ ] quebec-snowmobile-club — not started (sector-specific)
```

Completed entry example: `- [x] quebec-gst-qst — completed 2025-06-15`

Rules:

- `Entity type` set on first run (asked once by `quebec-incorporation`); immutable
  thereafter. To change it, delete `qc-status.md` and all per-skill files and restart.
- Skills mark themselves complete in this file when all their steps are done.
- `[n/a]` is a valid state for `quebec-payroll` (set when user answers "no employees").
- If a file named `obnl-status.md` is detected in the working directory, tell the user:
  "A legacy state file (`obnl-status.md`) was found. The `quebec-legal-entity` plugin
  uses a new format. Please rename or remove it and restart this skill."
  Check filename first (most reliable); do not rely on header text alone.
- `qc-status.md` uses `schema_version: 1`. The old `obnl-status.md` also used
  `schema_version: 1` but is identified by filename, not by header.

### Per-skill detail files

Each skill reads and writes its own file for step-level tracking.

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

Step-by-step skills use checkbox format. Advisory skills use a decisions/coverage log
format (defined per-skill below).

---

## Step ID Scheme

Skill-prefixed IDs replace the numeric S1-xx / S2-xx / S3-xx scheme:

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

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-incorporation.md), Edit(qc-incorporation.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-incorporation
- User asks to register a Quebec business, organization, or legal entity
- User needs to do a name search at the REQ
- User is beginning the Quebec incorporation process

DO NOT activate when:
- User is specifically asking about OBNL/non-profit steps (use quebec-obnl)
- User is asking about federal incorporation via Corporations Canada / CNCA
- User is asking about snowmobile club sector steps (use quebec-snowmobile-club)
```

**Changes from current version:**

- State file renamed from `obnl-status.md` to `qc-incorporation.md`; `qc-status.md` created alongside it
- Step IDs: S1-xx → INC-xx
- GST/QST registration step (S1-04) removed — replaced with post-completion prompt to `quebec-gst-qst`
- Source deduction registration step (S1-06) removed — replaced with post-completion prompt to `quebec-payroll`
- CRA Business Number step (S1-05) removed — subsumed by GST/QST registration in `quebec-gst-qst`
- Entity type asked on first run; stored in `qc-status.md`
- Post-incorporation gate updated: for OBNL entities, INC-03 requires OBNL-05; for
  for-profit entities, INC-03 unlocks when the user confirms they have their NEQ

**On Start logic:**

1. Check for `obnl-status.md` — if present, show legacy warning (see State File section)
2. Check for `qc-status.md` — if absent, create it and `qc-incorporation.md` from templates
3. Ask entity type if not set: "Is this organization a for-profit corporation or an OBNL
   (non-profit)?" — store answer in `qc-status.md`
4. Read `qc-incorporation.md`, show status, jump to first unchecked step

**Steps:**

| ID | Action | Cost (2025) | Delay | Tag |
| --- | --- | --- | --- | --- |
| INC-01 | Name search at REQ | Free | Immediate | `[GENERIC][PROV]` |
| INC-02 | Name reservation (optional) | $27.00 / $40.50 priority | 2–5 bus. days | `[GENERIC][PROV]` |
| *(post-incorporation gate — see below)* | | | | |
| INC-03 | Initial REQ declaration (within 60 days of NEQ) | Free | Immediate | `[GENERIC][PROV]` |
| INC-04 | Bank account opened | $0–$25/mo | 1–2 weeks | `[GENERIC]` |
| INC-05 | REQ annual update declaration (recurring) | $41.00 / $61.50 priority | Immediate | `[GENERIC][PROV]` |

**Post-incorporation gate (between INC-02 and INC-03):**

- For OBNL: "Steps INC-03 onward require letters patent and NEQ. Complete
  `/quebec-legal-entity:quebec-obnl` through OBNL-05, then return here."
  Gate opens when OBNL-05 is checked in `qc-obnl.md`.
- For for-profit: "Do you have your NEQ from the REQ?" If yes, unlock INC-03.
  If no: "You need to complete incorporation first (articles of incorporation via
  registreentreprises.gouv.qc.ca). Return here once you have your NEQ." Note that
  for-profit articles of incorporation are outside the scope of this plugin.

**Completion prompts:**

- After INC-02 (OBNL): continue with `quebec-obnl`
- After all INC steps: prompt for `quebec-gst-qst`, `quebec-payroll`,
  `quebec-income-tax`, `quebec-insurance`, `quebec-accounting`

---

### Skill 2: `quebec-obnl` [MIGRATED]

**Type:** Step-by-step
**Creates:** `qc-obnl.md`
**Prerequisite:** INC-01 checked in `qc-incorporation.md`
**Tags:** `[OBNL]` `[PROV]` `[FED]`

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-obnl.md), Edit(qc-obnl.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-obnl
- User is specifically registering a Quebec OBNL / organisme sans but lucratif
- User needs to file Form RE-303 with the Registraire des entreprises

DO NOT activate when:
- User wants generic Quebec entity registration only (use quebec-incorporation)
- User wants federal non-profit via Corporations Canada / CNCA
- User is asking only about snowmobile sector steps (use quebec-snowmobile-club)
```

**Changes from current version:**

- State file renamed to `qc-obnl.md`; step IDs: S2-xx → OBNL-xx
- S2-08 (CO-17.SP) and S2-09 (T2+T1044) removed — moved to `quebec-income-tax`
- S2-12 (annual tax returns confirmation) removed — now tracked in `qc-income-tax.md`
- OBNL completion prompts user to run `quebec-income-tax` for recurring tax obligations
- OBNL-05 milestone still surfaces NEQ, B2_date, D1_deadline explicitly

**On Start logic:** Same as current skill (check INC-01, explain 3-skill chain if no state
file found, jump to first unchecked OBNL step).

**Steps:**

| ID | Action | Cost (2025) | Delay | Tag |
| --- | --- | --- | --- | --- |
| OBNL-01 | Confirm 3+ founding members and mission | Free | 1–4 weeks | `[OBNL][PROV]` |
| OBNL-02 | Draft RE-303 + sworn declaration | $0–$100 | 1–3 weeks | `[OBNL][PROV]` |
| OBNL-03 | Draft by-laws (dissolution clause required) | $0–$2,000 | 1–4 weeks | `[OBNL][PROV]` |
| OBNL-04 | File RE-303 with REQ (mail/in-person only) | $199.00 / $298.50 priority | 5–10 bus. days | `[OBNL][PROV]` |
| OBNL-05 | Receive letters patent + NEQ *(milestone)* | Included | Same as OBNL-04 | `[OBNL][PROV]` |
| OBNL-06 | Hold constitutive general assembly | Free | Within weeks | `[OBNL][PROV]` |
| OBNL-07 | Set up minute book | $0–$200 | Concurrent | `[OBNL][PROV]` |
| OBNL-08 | Annual general assembly (recurring) | Free | Annual | `[OBNL][PROV]` |
| OBNL-09 | Annual financial statements (recurring) | $500–$3,000/year | Annual | `[OBNL]` |

**Completion prompts:** continue with INC-03 (post-inc gate); then `quebec-income-tax`;
then `quebec-snowmobile-club` if applicable.

---

### Skill 3: `quebec-snowmobile-club` [MIGRATED]

**Type:** Step-by-step
**Creates:** `qc-snowmobile-club.md`
**Prerequisite:** OBNL-05 + OBNL-06 checked in `qc-obnl.md`
**Tags:** `[SECTOR-SPECIFIC]`

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-snowmobile-club.md), Edit(qc-snowmobile-club.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-snowmobile-club
- User is operating a Quebec snowmobile club and has completed OBNL incorporation
- User asks about FCMQ membership, MTQ/PACM grants, or VHR trail designation

DO NOT activate when:
- User has not yet incorporated their OBNL (use quebec-obnl first)
- User is asking about generic incorporation (use quebec-incorporation)
- User is asking about other trail organizations (ATV, cycling, hiking)
```

**Changes from current version:**

- Directory renamed: `snowmobile-club-qc/` → `quebec-snowmobile-club/`
- State file renamed to `qc-snowmobile-club.md`; step IDs: S3-xx → SNOW-xx
- No content changes

**On Start logic:** Same as current (check OBNL-05/OBNL-06, verify NEQ populated, show
PACM calendar alert).

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
**Prerequisite:** INC-01 checked (or user confirms they have an existing NEQ)
**Tags:** `[GENERIC]` `[PROV]` `[FED]`

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-gst-qst.md), Edit(qc-gst-qst.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-gst-qst
- User asks about GST, QST, TPS, TVQ registration or filing
- User needs to register for or file sales tax returns in Quebec

DO NOT activate when:
- User is asking about income taxes (use quebec-income-tax)
- User is asking about payroll deductions (use quebec-payroll)
```

**On Start logic:**

1. Read `qc-status.md` for entity type and Organization name
2. Read `qc-gst-qst.md` if present; create from template if absent
3. Show current GST/QST status; jump to first unchecked step

**Instructions.md outline:**

- **On Start:** Read state files; if `qc-gst-qst.md` absent, create from template
- **Scope note:** In Quebec, Revenu Québec administers both GST and QST — one
  registration covers both
- **Voluntary registration:** Explain ITC/RTI benefit even below $30,000 threshold
- **Filing frequency:** Guide monthly/quarterly/annual selection based on expected volume
- **Recurring step:** GST-06 is a recurring reminder with next due date tracked

**Steps:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| GST-01 | Assess registration obligation (mandatory threshold or voluntary) | Free | Immediate |
| GST-02 | Register for GST/QST with Revenu Québec (LM-1 or online) | Free | 2–4 weeks |
| GST-03 | Select filing frequency (monthly / quarterly / annual) | Free | At registration |
| GST-04 | Set up ITC/RTI tracking in bookkeeping system | Free | Before first return |
| GST-05 | File first GST/QST return | Free to file | Per selected frequency |
| GST-06 | Ongoing return filing (recurring) | Free to file | Per frequency |

**Key warnings to embed:**

- Voluntary registration is often beneficial even below $30,000 threshold (ITC recovery)
- Late filing penalty: 1% of net tax owing + 0.25% of net tax per additional month
  late, maximum 24 months (maximum penalty = 7% of net tax)
- Instalment obligations trigger when annual net tax exceeds $3,000

---

### Skill 5: `quebec-payroll` [NEW]

**Type:** Step-by-step (conditional — N/A if no employees)
**Creates:** `qc-payroll.md`
**Prerequisite:** INC-01 checked
**Tags:** `[GENERIC]` `[PROV]` `[FED]`

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-payroll.md), Edit(qc-payroll.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-payroll
- User is hiring employees or has payroll obligations in Quebec
- User asks about source deductions, DAS, T4, RL-1, or payroll remittances

DO NOT activate when:
- User is asking about GST/QST (use quebec-gst-qst)
- User is asking about corporate income taxes (use quebec-income-tax)
```

**On Start logic:**

1. Read `qc-status.md`; if `quebec-payroll` is `[n/a]`, confirm: "Payroll was previously
   marked not applicable. Do you now have employees?" If yes, reset to not started.
2. If not N/A: ask "Do you have or plan to hire paid employees?" If no, write
   `[n/a] quebec-payroll — not applicable (no employees)` to `qc-status.md` and exit.
3. Read `qc-payroll.md` if present; create from template if absent
4. Show status; jump to first unchecked step

**Instructions.md outline:**

- **On Start:** Employee check logic (steps 1–4 above); create `qc-payroll.md` template
  if absent; jump to first unchecked step
- **N/A path:** Write `[n/a]` to `qc-status.md` immediately; confirm to user and exit
- **NEVER:** Skip the employee question; proceed with steps if user said no employees
- **ALWAYS:** Warn about director liability before PAY-01; note ClicSÉQUR setup timing
  before PAY-08
- **Recurring steps:** PAY-06, PAY-07, PAY-08 are recurring; track next due date for each
- **Completion prompt:** "Payroll is set up. Ensure GST/QST and income-tax skills are
  also complete."

**Steps:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| PAY-01 | Register employer account with Revenu Québec (source deductions) | Free | Before first payroll |
| PAY-02 | Register RP payroll account with CRA | Free | Before first payroll |
| PAY-03 | Determine remittance frequency (quarterly / monthly / accelerated) | Free | At registration |
| PAY-04 | Collect employee TD1 (federal) and TP-1015 (provincial) forms | Free | Before first pay |
| PAY-05 | Run first payroll: withhold QPP, QPIP, QIT, EI, FIT + employer contributions | Free | Per pay cycle |
| PAY-06 | DAS remittance to Revenu Québec (recurring) | Free | Per frequency |
| PAY-07 | CRA payroll remittance (recurring) | Free | Per frequency |
| PAY-08 | Year-end: issue T4 (CRA) + RL-1 (Revenu Québec) | Free to file | Feb 28 annually |
| PAY-09 | Vacation pay tracking | Ongoing | Per employee |

**Key warnings to embed:**

- Director personal liability for unremitted source deductions
- Accelerated remittance triggers when average monthly withholdings exceed $25,000
- RL-1 filed via Revenu Québec ClicSÉQUR — set up the account before year-end

---

### Skill 6: `quebec-income-tax` [NEW]

**Type:** Step-by-step with entity-type branching
**Creates:** `qc-income-tax.md`
**Prerequisite:** INC-01 checked
**Tags:** `[GENERIC][PROV][FED]` (for-profit) or `[OBNL][PROV][FED]` (OBNL)

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-income-tax.md), Edit(qc-income-tax.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-income-tax
- User asks about corporate income tax, T2, CO-17.SP, or T1044

DO NOT activate when:
- User is asking about GST/QST (use quebec-gst-qst)
- User is asking about payroll deductions (use quebec-payroll)
- User is asking about personal income taxes (out of scope)
```

**On Start logic:**

1. Read `Entity type` from `qc-status.md`. If not set, ask: "Is your organization a
   for-profit corporation or an OBNL?" Store answer.
2. Read `qc-income-tax.md` if present; create from appropriate template if absent
3. Show status; proceed with the branch matching entity type

**Instructions.md outline:**

- **On Start:** Entity type branch selection (steps 1–3 above)
- **Branch selection:** Display which branch applies; note it is driven by entity type
  in `qc-status.md`
- **NEVER:** Apply OBNL tax steps to a for-profit or vice versa
- **ALWAYS:** Surface fiscal year-end at TAX-01 and record it; prompt user to set a
  calendar reminder for instalment and filing deadlines
- **OBNL T1044 gate:** Before TAX-05, ask the three threshold questions (assets, revenues,
  public property) and only surface the T1044 step if any threshold is met
- **CCPC instalment note:** At TAX-02 for for-profit, explain the two-instalment method
  and safe-harbour options; recommend consulting a CPA for first-year instalment setup
- **Recurring TAX-06:** Track next FY-end date; remind user when next cycle is approaching
- **Completion prompt:** "Annual tax obligations are set up. Return each year at
  [FY-end minus 2 months] to file on time."

**Branch A — For-profit corporation:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| TAX-01 | Confirm fiscal year-end | Free | At setup |
| TAX-02 | Assess instalment obligation (net tax > $3,000 in current or prior year) | Free | 2nd and 3rd month of FY |
| TAX-03 | Year-end: prepare financial statements | $500–$3,000 | Within 6 months of FY-end |
| TAX-04 | File T2 corporate income tax return (CRA) | Free to file | Within 6 months of FY-end |
| TAX-05 | Pay balance owing | Variable | 2 months after FY-end (3 months for eligible CCPCs) |
| TAX-06 | Annual recurring (TAX-02 through TAX-05) | — | Annual |

**Branch B — OBNL:**

| ID | Action | Cost (2025) | Delay |
| --- | --- | --- | --- |
| TAX-01 | Confirm fiscal year-end | Free | At setup |
| TAX-02 | Year-end: prepare financial statements | $500–$3,000 | Within 6 months of FY-end |
| TAX-03 | File CO-17.SP with Revenu Québec (claim s.998 exemption) | Free to file | Within 6 months of FY-end |
| TAX-04 | File T2 with CRA (claim 149(1)(l) exemption) | Free to file | Within 6 months of FY-end |
| TAX-05 | File T1044 NPO Information Return if required (see below) | Free to file | With T2 |
| TAX-06 | Annual recurring (TAX-02 through TAX-05) | — | Annual |

T1044 is required if **any one** of: total assets > $200,000 at year-end; total revenues
> $100,000 in the year; corporation received or held property from the public with value
> $100,000.

**Key warnings to embed:**

- OBNL: cannot issue charitable tax receipts; 149(1)(l) exemption ≠ registered charity
- For-profit: instalment interest compounds daily — set calendar reminders
- CCPC balance-owing deadline is 3 months (not 2) if eligible for small business deduction

---

### Skill 7: `quebec-insurance` [NEW]

**Type:** Advisory (decision guide)
**Creates:** `qc-insurance.md`
**Prerequisite:** none
**Tags:** `[GENERIC]`

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-insurance.md), Edit(qc-insurance.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-insurance
- User asks what insurance their Quebec entity needs
- User wants to review or update their insurance coverage

DO NOT activate when:
- User is asking about snowmobile-specific insurance (use quebec-snowmobile-club)
- User is asking about employee benefits or group insurance programs
```

**On Start logic:**

1. Read `qc-status.md` for entity type
2. Read `qc-insurance.md` if present; create from template if absent
3. Walk through each INS section interactively

**Instructions.md outline:**

- **On Start:** Read entity type; create `qc-insurance.md` from template if absent;
  show current coverage log; ask "Would you like to review all sections or jump to a
  specific one?"
- **Advisory mode:** For each INS section, explain what it is, ask if the entity needs
  it, record the decision (obtained or declined) in `qc-insurance.md`
- **NEVER:** Tell the user a specific insurer is the only option; present as examples
- **ALWAYS:** Note that sector-specific coverage (snowmobile trails) is handled in
  `quebec-snowmobile-club`, not here
- **Completion prompt:** "Insurance review complete. Review annually before each
  renewal date."

**`qc-insurance.md` format (decisions log):**

```markdown
# Insurance Coverage Log
Organization: [name]
Last updated: YYYY-MM-DD

## Coverage

| Type | Required | Insurer | Policy # | Annual Premium | Renewal Date |
| --- | --- | --- | --- | --- | --- |
| General liability | yes | [insurer] | [#] | $[amount] | YYYY-MM-DD |
| D&O | yes | [insurer] | [#] | $[amount] | YYYY-MM-DD |
| Property | no | — | — | — | — |
| E&O | no | — | — | — | — |
| Event liability | no | — | — | — | — |
| Sector-specific | see snowmobile-club | — | — | — | — |
```

**Advisory sections:**

| Section | Content |
| --- | --- |
| INS-01 | General liability — minimum for any entity with third-party exposure |
| INS-02 | Directors & officers (D&O) — strongly recommended for any board |
| INS-03 | Property — for entities owning equipment, vehicles, or physical assets |
| INS-04 | Errors & omissions (E&O) — for professional services organizations |
| INS-05 | Event liability — for events open to the public |
| INS-06 | Sector-specific riders — refer to `quebec-snowmobile-club` for trail operations |

For each section: explain what it covers, who needs it, typical cost range, how to obtain.
Record each coverage decision (obtained or explicitly declined) in `qc-insurance.md`.

---

### Skill 8: `quebec-accounting` [NEW]

**Type:** Advisory (decision guide, run once)
**Creates:** `qc-accounting.md`
**Prerequisite:** none
**Tags:** `[GENERIC]`

**SKILL.md content:**

```yaml
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-accounting.md), Edit(qc-accounting.md), AskUserQuestion

ONLY activate when:
- User invokes /quebec-legal-entity:quebec-accounting
- User asks about bookkeeping setup, accounting software, or fiscal year choice
- User wants guidance on accounting for their Quebec entity

DO NOT activate when:
- User is asking about tax return filing (use quebec-income-tax)
- User is asking about payroll records (use quebec-payroll)
```

**On Start logic:**

1. Read `qc-status.md` for entity type and organization name
2. Read `qc-accounting.md` if present; show existing decisions; offer to revisit any
3. Walk through each ACC section that has not yet been decided

**Instructions.md outline:**

- **On Start:** Read entity type; create `qc-accounting.md` from template if absent;
  show existing decisions; ask "Walk through all sections or jump to a specific one?"
- **Advisory mode:** For each ACC section, present options with tradeoffs tailored to
  entity type (OBNL vs for-profit); record the decision in `qc-accounting.md`
- **NEVER:** Recommend a specific software product as definitively best; present tradeoffs
- **ALWAYS:** Flag fiscal year-end choice as highest-stakes decision (difficult to change
  later); recommend FCMQ-aligned April 1–March 31 if entity is a snowmobile club
- **Completion prompt:** "Accounting setup decisions are logged. Revisit this skill if
  your situation changes (e.g., hiring staff, significant asset purchases)."

**`qc-accounting.md` format (decisions log):**

```markdown
# Accounting Setup Log
Organization: [name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| ACC-01 Fiscal year-end | March 31 | Aligns with FCMQ/PACM cycle |
| ACC-02 Software | Wave (free) | Sufficient for small OBNL |
| ACC-03 Chart of accounts | OBNL standard | Provided by Wave template |
| ACC-04 Bookkeeper | Annual CPA for tax returns | DIY month-to-month |
| ACC-05 Record retention | 6 years | Calendar reminder set |
```

**Advisory sections:**

| Section | Content |
| --- | --- |
| ACC-01 | Fiscal year-end — tradeoffs: calendar year, incorporation date, sector alignment |
| ACC-02 | Software — Wave (free), QuickBooks, Sage, Acomba (Quebec-native); tradeoffs |
| ACC-03 | Chart of accounts — standard OBNL vs for-profit; Quebec specificities |
| ACC-04 | Bookkeeper vs CPA — when to DIY, when to hire, expected costs |
| ACC-05 | Record retention — Quebec law requires 6 years for most financial documents |

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
| Skill dir | `snowmobile-club-qc/` | `quebec-snowmobile-club/` |
| State file | `obnl-status.md` (single) | `qc-status.md` + 8 per-skill files |
| Step IDs | S1-xx, S2-xx, S3-xx | INC-xx, OBNL-xx, SNOW-xx, GST-xx, PAY-xx, TAX-xx, INS-xx, ACC-xx |
| GST/QST reg step | In `quebec-incorporation` (S1-04) | Moved to `quebec-gst-qst` (GST-02) |
| CRA BN step | In `quebec-incorporation` (S1-05) | Subsumed by GST-02 |
| Payroll reg step | In `quebec-incorporation` (S1-06) | Moved to `quebec-payroll` (PAY-01/02) |
| OBNL tax returns | In `quebec-obnl` (S2-08/S2-09/S2-12) | Moved to `quebec-income-tax` (TAX-03–05) |

Old plugin directory deleted entirely; no backwards compatibility needed (no users).

# Batch F — Financial Operations Design Spec

## Overview

Three new skills covering day-to-day financial operations for a Quebec entity.
These complement the existing accounting and payroll skills with deeper
operational guidance.

**Skills:**

1. `quebec-banking` — Bank product selection, authorized signatories, online
   banking setup, and ongoing banking hygiene
2. `quebec-document-management` — Digital record validity under LCCJTI/CRA,
   scanning workflow, what to keep as paper, naming conventions, backup
3. `quebec-expenses` — Expense policy, receipt requirements for ITC claims,
   CRA mileage rate, board/volunteer reimbursement procedure

**Relationship to existing skills:**

- `INC-04` (in `quebec-incorporation`) covers *opening* a bank account as a
  quick step. `quebec-banking` goes deeper — product choice, signing authority
  policy, and ongoing operations. INC-04 should link to this skill on completion.
- `ACC-05` (in `quebec-accounting`) covers the 6-year retention rule but says
  nothing about *how* to archive. `quebec-document-management` fills that gap.
- `quebec-payroll` covers source deductions but not employee expense
  reimbursement. `quebec-expenses` fills that gap.

**Dependencies:** None. Each skill can be run at any time after entity
formation. `quebec-banking` is most useful immediately after INC-04.

---

## File structure per skill

Each skill is a directory under `quebec-legal-entity/skills/<name>/` containing:

- **SKILL.md** — YAML front-matter activation header (name, description with
  ONLY/DO NOT, allowed-tools). Includes `---` delimiters.
- **instructions.md** — Procedural content: On Start logic, state file
  template, NEVER/ALWAYS, step/section detail, key warnings, completion block.

---

## State Files

| Skill | State file | Type |
| --- | --- | --- |
| `quebec-banking` | `qc-banking.md` | Sequential steps |
| `quebec-document-management` | `qc-document-management.md` | Advisory decisions log |
| `quebec-expenses` | `qc-expenses.md` | Advisory decisions log |

---

## Skill 1: `quebec-banking`

### SKILL.md

```markdown
---
name: quebec-banking
description: |
  Interactive guide for business banking setup and ongoing operations for a
  Quebec entity. Covers bank product selection, authorized signatories policy,
  online banking setup, and banking hygiene for OBNLs and for-profits.

  Complements INC-04 (bank account opening step) with deeper operational
  guidance. Run after INC-04 to establish banking policies and controls.

  Reads and writes qc-banking.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-banking
  - User is choosing a bank or banking product for their Quebec entity
  - User asks about authorized signatories, signing authority policy, or
    online banking setup for a Quebec business or OBNL

  DO NOT activate when:
  - User is asking about opening the bank account itself (that is INC-04 in
    quebec-incorporation)
  - User is asking about GST/QST filing (use quebec-gst-qst)
  - User is asking about payroll remittances (use quebec-payroll)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-banking.md), Edit(qc-banking.md), AskUserQuestion
---
```

### instructions.md content

**On Start:**

1. Read `qc-status.md` for entity type and Organization name.
2. Read `qc-banking.md`; create from template if absent.
3. Present status; jump to first unchecked step.

**State file template (`qc-banking.md`):**

```markdown
# Banking Status — [organization name]
schema_version: 1
Bank: pending
Account_type: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] BNK-01 — Banking institution selected
- [ ] BNK-02 — Authorized signatories policy established
- [ ] BNK-03 — Online banking and e-transfer configured
- [ ] BNK-04 — Dual-signature threshold set (if OBNL)
- [ ] BNK-05 — Banking information recorded in minute book
```

**NEVER / ALWAYS:**

NEVER:
- Recommend a single institution as definitively best — present options with
  tradeoffs relevant to the entity type
- Skip BNK-04 for OBNLs — dual-signature controls are a governance best
  practice and often required by funders (PACM, grants)

ALWAYS:
- At BNK-01: recommend Desjardins Caisse for community OBNLs as the first
  option — local credit unions understand OBNL banking and often waive fees
- At BNK-02: explain that authorized signatories must be formally approved by
  board resolution (recorded in minute book) — verbal authority is insufficient
- At BNK-05: remind user to file the banking authorization resolution in the
  minute book (OBNL-07 or GOV-04)

**Steps:**

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| BNK-01 | Select banking institution and account product (see options below) | $0–$25/month | 1–2 weeks for appointment |
| BNK-02 | Board resolution to designate authorized signatories; specify who can sign cheques, authorize e-transfers, and access accounts | Free | At or before account opening |
| BNK-03 | Set up online banking access; configure e-transfer limits; add secondary users for bookkeeper/treasurer | Free | At account opening |
| BNK-04 | For OBNLs: establish dual-signature threshold (e.g., any transaction over $1,000 requires two authorized signatories) | Free | At account opening |
| BNK-05 | Record account number, institution, authorized signatories, and board resolution in minute book | Free | After account opened |

**Institution options for Quebec entities:**

| Institution | Best for | Monthly fee | Notes |
| --- | --- | --- | --- |
| Desjardins Caisse (local) | Community OBNLs | Often waived for OBNLs | Local caisses know OBNL context; FCMQ members often bank here |
| Banque Nationale | Growing OBNLs and for-profits | $0–$30 | Strong Quebec presence; good online banking |
| BMO Non-profit | National OBNLs | Reduced fees | National reach; less locally embedded |
| RBC / TD | For-profit corporations | $0–$30 | Standard business accounts; competitive |

**Key Warning:**

> **Board resolution required:** A bank account authorized signatory is not
> determined by job title alone — it requires a formal board resolution naming
> the individual(s). When directors change, update the signing authority
> immediately with the bank and record the change in the minute book.
>
> **Dual-signature for OBNLs:** Major funders (MTQ/PACM, Tourisme Québec)
> expect to see dual-signature controls in an OBNL's financial procedures.
> Some grant programs require evidence of internal controls at application.

**Completion:**

When BNK-05 is checked, update `qc-status.md`:
`- [x] quebec-banking — completed [YYYY-MM-DD]`

Then prompt: "Banking is set up. Ensure the signing authority board resolution
is filed in the minute book before any transactions. Revisit when authorized
signatories change."

---

## Skill 2: `quebec-document-management`

### SKILL.md

```markdown
---
name: quebec-document-management
description: |
  Advisory guide for document management and archiving for Quebec entities.
  Covers digital record validity under Quebec's LCCJTI and CRA electronic
  record rules, what must stay as paper originals, scanning workflow,
  file naming conventions, backup strategy, and retention calendar.

  Short answer: scanned documents are legally valid in Quebec under the LCCJTI
  (Loi concernant le cadre juridique des technologies de l'information) and
  accepted by CRA, with three exceptions that must stay as paper originals.

  This is an advisory skill — it guides setup decisions and documents choices.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-document-management
  - User asks whether scanned documents are legally valid in Quebec
  - User is setting up a document management or archiving system
  - User wants to know what to keep as paper vs digital

  DO NOT activate when:
  - User is asking about record retention periods (those are in ACC-05 in
    quebec-accounting — 6 years)
  - User is asking about privacy of personal data (use quebec-privacy)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-document-management.md), Edit(qc-document-management.md),
  AskUserQuestion
---
```

### instructions.md content

**On Start:**

1. Read `qc-status.md` for Organization name.
2. Read `qc-document-management.md`; create from template if absent.
3. Walk through advisory sections.

**State file template (`qc-document-management.md`):**

```markdown
# Document Management Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| DOC-01 Digital validity confirmed | pending | — |
| DOC-02 Paper originals list | pending | — |
| DOC-03 Scanning workflow | pending | — |
| DOC-04 File naming convention | pending | — |
| DOC-05 Backup strategy | pending | — |
| DOC-06 Retention calendar | pending | — |
```

**NEVER / ALWAYS:**

NEVER:
- Tell the user all documents can be digitized — three categories must stay
  as paper originals (see DOC-02)
- Recommend keeping physical originals of everything — the goal is a
  sustainable digital-first system with targeted paper exceptions

ALWAYS:
- Lead with the direct answer: scanned documents are legally valid in Quebec
  under the LCCJTI and CRA's electronic records policy, subject to DOC-02
  exceptions
- At DOC-05: require at least two backup locations (local + cloud) — a single
  location is not a backup

**Advisory Sections:**

**DOC-01 — Digital record validity**

Under Quebec's *Loi concernant le cadre juridique des technologies de
l'information* (LCCJTI), a digital document (including a scan of a paper
original) has the same legal force as the paper original provided:

- Its integrity is maintained (not altered after creation)
- The technology used is reliable and the process documented
- Origin can be established

CRA also accepts digital records for all tax purposes provided they are
legible and complete. See IT-518 and CRA's "Electronic Records" guidance.

**DOC-02 — Documents that must stay as paper originals**

Keep the following as physical paper originals:

1. **Notarized or sworn documents** — RE-303 sworn declaration (déclaration sous
   serment); notarized agreements. The notary's or commissioner's wet signature
   and seal cannot be digitized away.
2. **Letters patent** — The original REQ-issued letters patent with the official
   seal. Keep in the minute book. A certified copy is acceptable for most
   purposes, but the original must be preserved.
Everything else — invoices, receipts, bank statements, board minutes, insurance
policies, tax returns — can be scanned and the paper discarded after scanning.

**Watch for:** Contracts where the counterparty contractually requires a
wet-signature original (e.g., some landowner access agreements, institutional
grant agreements). This is a negotiated contractual requirement, not a legal
absolute — the LCCJTI and electronic signature law recognize digital signatures
as valid for contracts unless the counterparty specifically requires otherwise.

**DOC-03 — Scanning workflow**

Recommended workflow for sustainable digital archiving:

1. Scan at 300 dpi minimum (600 dpi for legal documents with fine print)
2. Save as PDF/A (archival format) — not JPEG
3. Name the file immediately (see DOC-04) before filing
4. Verify legibility before discarding the paper original
5. For GST/QST receipts: ensure the scan shows the supplier name, date,
   amount, and GST/QST registration number (required for ITC claims)

**DOC-04 — File naming convention**

Recommended convention: `YYYY-MM-DD_category_description.pdf`

Examples:
- `2026-03-01_facture_hydro-quebec-mars.pdf`
- `2026-02-28_DAS_remittance-fevrier.pdf`
- `2026-01-15_contrat_acces-terrain-dupont.pdf`

Organize into folders by fiscal year, then category:
`[FY] / Factures / Contrats / Gouvernement / Paie / Assurances`

**DOC-05 — Backup strategy**

Minimum: two backup locations — one local (external drive or NAS) and one
cloud (Google Drive, Dropbox, OneDrive). Cloud backup should be automatic.

Recommended for OBNLs: Google Workspace for Nonprofits (free for eligible
OBNLs) — includes Google Drive with 100 GB pooled storage.

**DOC-06 — Retention calendar**

Documents must be retained for at least 6 years from the end of the fiscal
year (Revenu Québec and CRA). The following are retained indefinitely:
corporate minute book, letters patent, by-laws, land access agreements in
force.

Set an annual calendar reminder to purge documents older than 6 years.

**Key Warning:**

> **Integrity requirement:** A digital document's legal validity depends on
> its integrity. Do not edit PDFs after they are filed (use read-only or
> locked storage). If a document must be corrected, create a new version and
> retain the original.

**Completion:**

When all DOC sections have been decided, update `qc-status.md`:
`- [x] quebec-document-management — completed [YYYY-MM-DD]`

Then prompt: "Document management system is established. Review annually and
update when storage platforms or retention requirements change."

---

## Skill 3: `quebec-expenses`

### SKILL.md

```markdown
---
name: quebec-expenses
description: |
  Advisory guide for expense management for Quebec entities. Covers expense
  policy setup, receipt requirements for GST/QST input tax credit (ITC) claims,
  CRA automobile allowance rates, board member and volunteer expense
  reimbursement procedures, and per diem policies.

  This is an advisory skill — it helps establish expense policies and
  documents decisions.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-expenses
  - User asks about expense reimbursement policies or procedures
  - User wants to set up an expense claim process for employees, board
    members, or volunteers
  - User asks about what receipts are required for tax purposes

  DO NOT activate when:
  - User is asking about payroll source deductions (use quebec-payroll)
  - User is asking about GST/QST return filing (use quebec-gst-qst)
  - User is asking about accounting software setup (use quebec-accounting)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-expenses.md), Edit(qc-expenses.md), AskUserQuestion
---
```

### instructions.md content

**On Start:**

1. Read `qc-status.md` for entity type and Organization name.
2. Read `qc-expenses.md`; create from template if absent.
3. Walk through advisory sections.

**State file template (`qc-expenses.md`):**

```markdown
# Expense Policy Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| EXP-01 Expense policy document | pending | — |
| EXP-02 Receipt requirements | pending | — |
| EXP-03 Mileage/auto allowance | pending | — |
| EXP-04 Board/volunteer reimbursement | pending | — |
| EXP-05 Per diem policy | pending | — |
| EXP-06 Approval workflow | pending | — |
```

**NEVER / ALWAYS:**

NEVER:
- Tell a user that informal verbal expense approvals are adequate for a
  funded OBNL — grant funders require documented expense procedures
- Suggest that volunteers cannot be reimbursed for expenses — they can and
  should be; only wages trigger payroll obligations

ALWAYS:
- At EXP-02: explain the specific receipt requirements for GST/QST ITC claims
  (supplier name, date, amount, GST/QST number) — incomplete receipts lose
  the ITC
- At EXP-03: direct user to the current CRA prescribed automobile allowance
  rate (changes annually — verify at canada.ca); using the CRA rate means the
  reimbursement is non-taxable to the recipient

**Advisory Sections:**

**EXP-01 — Written expense policy**

A written expense policy:
- Defines what is reimbursable (mileage, meals, accommodation, supplies)
- Sets approval authority (who approves whose expenses; president's expenses
  approved by treasurer or vice-president)
- Specifies maximum amounts (daily meal cap, hotel cap)
- States the reimbursement timeline (e.g., within 30 days of submission)
- Is required by most grant funders

FCMQ and MTQ/PACM audits may request the policy.

**EXP-02 — Receipt requirements for ITC/RTI claims**

CRA/RQ apply a three-tier receipt rule for ITC/RTI claims:

- **Under $30:** No receipt required (petty cash rule)
- **$30–$149.99:** Simplified receipt acceptable — must show supplier name,
  date, amount, and GST/QST indication; supplier's registration number is
  not required at this tier
- **$150 and over:** Full invoice required — must show supplier name, date,
  amount, GST/QST amounts, and supplier's GST/QST registration number

Credit card statements alone are insufficient at any tier — the itemized
receipt is required.

**EXP-03 — Automobile allowance / mileage**

Using the CRA prescribed per-kilometre rate (updated annually):
- The reimbursement is tax-free to the recipient (no payroll deductions)
- The organization can deduct the full amount as a business expense
- The vehicle owner covers their own maintenance, insurance, and fuel

As an example, the 2025 CRA rate was $0.72/km for the first 5,000 km and
$0.66/km thereafter. **Verify the current year's rate at canada.ca before
approving the policy** — the rate changes annually.

Using a rate above the CRA prescribed amount: the excess is a taxable benefit
to the recipient (requires payroll treatment).

**EXP-04 — Board member and volunteer reimbursement**

Board members and volunteers may be reimbursed for out-of-pocket expenses:
- Travel to board meetings, FCMQ assemblies, MTQ consultations
- Supplies purchased for the organization
- Meals during official organization activities

Reimbursement of actual expenses is NOT a taxable benefit and does NOT trigger
payroll obligations. Paying a flat honorarium or stipend (a fixed amount
regardless of actual expenses) IS taxable.

**EXP-05 — Per diem policy**

A per diem is a fixed daily allowance for meals and incidental expenses when
traveling on organization business. CRA's reasonable per diem rates (example — verify current rates annually):
- Breakfast: $23, Lunch: $29, Dinner: $52

Per diems at or below CRA guidelines are generally non-taxable. Set per diem
rates in the expense policy to avoid disputes. **Verify current rates at
canada.ca/en/revenue-agency — updated periodically.**

**EXP-06 — Approval workflow**

Recommended minimum workflow:
1. Claimant submits expense form with original receipts (or scanned copies)
2. Treasurer reviews receipts against policy
3. Second signatory (president or vice-president) approves for amounts over
   the dual-signature threshold (see BNK-04 in `qc-banking.md`)
4. Reimbursement by cheque or e-transfer; record in bookkeeping software

**Key Warning:**

> **Grant audit readiness:** PACM and other grant funders may audit expense
> claims. Maintain organized expense files with the approval form and receipt
> attached. Electronic submissions are acceptable; use the DOC-04 naming
> convention from `qc-document-management.md`.

**Completion:**

When all EXP sections have been decided, update `qc-status.md`:
`- [x] quebec-expenses — completed [YYYY-MM-DD]`

Then prompt: "Expense policies are established. Revisit EXP-03 annually to
confirm the CRA mileage rate and EXP-05 to confirm per diem rates."

---

## `qc-status.md` entries

```markdown
- [ ] quebec-banking — not started
- [x] quebec-banking — completed [YYYY-MM-DD]

- [ ] quebec-document-management — not started
- [x] quebec-document-management — completed [YYYY-MM-DD]

- [ ] quebec-expenses — not started
- [x] quebec-expenses — completed [YYYY-MM-DD]
```

Initial state written to `qc-status.md` on first run: `not started`.

---

## File Structure

```text
quebec-legal-entity/
└── skills/
    ├── quebec-banking/
    │   ├── SKILL.md
    │   └── instructions.md
    ├── quebec-document-management/
    │   ├── SKILL.md
    │   └── instructions.md
    └── quebec-expenses/
        ├── SKILL.md
        └── instructions.md
```

---

## README additions

Three new skill entries appended to `quebec-legal-entity/README.md`.

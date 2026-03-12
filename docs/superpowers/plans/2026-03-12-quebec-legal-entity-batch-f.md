# Batch F — Financial Operations Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three financial operations skills to the `quebec-legal-entity` plugin: `quebec-banking` (sequential banking setup), `quebec-document-management` (digital archiving advisory), and `quebec-expenses` (expense policy advisory).

**Architecture:** Three directories under `quebec-legal-entity/skills/<name>/`, each containing `SKILL.md` (bare YAML front-matter) and `instructions.md`. `quebec-banking` uses sequential steps (BNK-01 to BNK-05). `quebec-document-management` and `quebec-expenses` use advisory decisions-log state files. All three have Completion blocks that write to `qc-status.md`. `EXP-06` cross-references the dual-signature threshold set in `BNK-04`. README.md gets three new entries.

**Tech Stack:** Markdown, YAML front-matter. Plugin framework expects bare `---`-delimited YAML in SKILL.md (no code fence wrappers).

**Spec:** `docs/superpowers/specs/2026-03-12-quebec-legal-entity-batch-f-operations-design.md`

---

## Chunk 1: Three Skill Files

### Task 1: `quebec-banking` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-banking/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-banking/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-banking/SKILL.md` with exact content:

```
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

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-banking/instructions.md` with exact content:

````markdown
# Quebec Business Banking — Setup and Operations Guide

This skill guides you through business banking setup and ongoing banking
controls for a Quebec entity. It complements the quick INC-04 step (opening
the bank account) with deeper guidance on product selection, authorized
signatories policy, online banking configuration, and dual-signature controls.

---

## On Start

1. Read `qc-status.md` for entity type (for-profit or OBNL) and Organization name.
2. Read `qc-banking.md` if present; create it from the template below if absent.
3. Present current status; jump to first unchecked step.

**`qc-banking.md` template (create if absent):**

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

---

## NEVER / ALWAYS

### NEVER

- Recommend a single institution as definitively best — present options with
  tradeoffs relevant to the entity type (OBNL vs for-profit, size, geography)
- Skip BNK-04 for OBNLs — dual-signature controls are a governance best
  practice and are often required by funders (MTQ/PACM, Tourisme Québec,
  other grant programs) as evidence of internal financial controls

### ALWAYS

- At BNK-01: recommend Desjardins Caisse (local branch) as the first option
  for community OBNLs — local credit unions understand OBNL banking context
  and often waive monthly fees for non-profits
- At BNK-02: explain that authorized signatories must be formally approved
  by board resolution recorded in the minute book — verbal authority or
  job title alone is not sufficient for the bank or for funders
- At BNK-05: remind the user to file the banking authorization resolution
  in the minute book (OBNL-07 for OBNLs, GOV-04 for for-profits)

---

## Steps

---

### BNK-01 `[GENERIC]` — Select banking institution and account product

**What to do:**
Choose a banking institution and the appropriate account product for the entity.

**Institution options for Quebec entities:**

| Institution | Best for | Monthly fee | Notes |
| --- | --- | --- | --- |
| Desjardins Caisse (local branch) | Community OBNLs | Often waived for OBNLs | Local caisses understand OBNL context; FCMQ members often bank here; relationship banking is stronger |
| Banque Nationale | Growing OBNLs and for-profits | $0–$30/month | Strong Quebec presence; good online banking; bilingual |
| BMO Non-profit Banking | National OBNLs | Reduced fees | National reach; less locally embedded than Desjardins |
| RBC / TD | For-profit corporations | $0–$30/month | Standard business accounts; competitive for-profit rates |

**Account types:**
- **Chequing account (compte courant):** For day-to-day operations — use this as
  the primary account
- **Savings / reserve account:** For grant reserves, trail maintenance funds —
  separate from operating account for cleaner bookkeeping

**Cost:** $0–$25/month (often waived for OBNLs)
**Delay:** Allow 1–2 weeks for an appointment and account opening

**After institution and product selected:** Record in `qc-banking.md`
(Bank and Account_type fields). Check `BNK-01`.

---

### BNK-02 `[GENERIC]` — Establish authorized signatories policy

**What to do:**
Pass a board resolution formally designating who is authorized to:
- Sign cheques
- Authorize e-transfers
- Access and operate the bank account
- Accept credit and debit facilities

**Board resolution must specify:**
- The names of each authorized signatory (by name, not just title — titles change)
- The scope of authority (e.g., sole authority for amounts under the dual-signature
  threshold; dual authority for amounts at or above the threshold)
- Whether any signatory has sole authority for specific transaction types
  (e.g., treasurer can authorize routine payments under $500 without co-signature)

**Important:** When directors or officers change, the bank signing authority must
be updated immediately with a new board resolution. Leaving a departed director
on signing authority is both a governance risk and a fraud risk.

**Cost:** Free
**Delay:** At or before account opening

**After board resolution passed:** Record signatory names and scope in
`qc-banking.md`. Check `BNK-02`.

---

### BNK-03 `[GENERIC]` — Configure online banking and e-transfer

**What to do:**
Set up online banking access and configure e-transfer settings:

1. **Primary online banking user:** Register the main administrator (typically
   treasurer or bookkeeper)
2. **Secondary users:** Add secondary access for bookkeeper with read-only
   or limited authority as appropriate
3. **E-transfer limits:** Confirm the daily and per-transaction e-transfer
   limits match your operational needs (most banks allow adjustment on request)
4. **Notifications:** Enable email or SMS alerts for all transactions — this
   is a fraud detection control
5. **Interac e-Transfer Autodeposit:** Consider whether autodeposit is appropriate
   (convenient but removes the security question layer)

**Cost:** Free
**Delay:** At account opening

**After online banking configured:** Check `BNK-03` in `qc-banking.md`.

---

### BNK-04 `[GENERIC]` — Set dual-signature threshold (OBNLs and for-profits with boards)

**What to do:**
Establish a dollar threshold above which two authorized signatories must approve
a transaction (cheque, e-transfer, or payment authorization).

**Why this matters:**
- Major funders (MTQ/PACM, Tourisme Québec, Fondation McConnell) expect to see
  dual-signature financial controls in an OBNL's procedures
- Some grant programs require evidence of internal controls at the application
  stage or during financial audits
- Prevents any single individual from unilaterally committing large sums

**Common threshold choices for small OBNLs:**
- `$500` — strict control suitable for very small clubs
- `$1,000` — common default for most OBNLs; balances control with operational ease
- `$2,500` — suitable if most transactions are small and board capacity is limited

**Record the threshold in:** `qc-banking.md` AND in the board resolution (BNK-02
resolution should state the threshold). This threshold is also referenced by
the expense approval workflow in `qc-expenses.md` (EXP-06).

**For sole-shareholder for-profits without a board:** BNK-04 is not applicable —
record as `[n/a] — no board / sole shareholder` and proceed.

**Cost:** Free
**Delay:** At account opening; set in board resolution

**After threshold set:** Record the dollar amount in `qc-banking.md`. Check `BNK-04`.

---

### BNK-05 `[GENERIC]` — Record banking information in minute book

**What to do:**
File the following in the corporate minute book:

1. The board resolution authorizing account opening and designating signatories
   (from BNK-02)
2. Account number and institution name
3. The dual-signature threshold (from BNK-04)
4. Any subsequent resolutions changing signatories

**Where in minute book:**
- OBNLs: file under OBNL-07 (minute book section)
- For-profits: file under GOV-04 (minute book section)

**Cost:** Free
**Delay:** After account opened and first resolution passed

**After filing in minute book:** Check `BNK-05` in `qc-banking.md`.

---

## KEY WARNINGS

> **Board resolution required for signatories:** A bank account authorized
> signatory is not determined by job title alone — it requires a formal board
> resolution naming the individual(s). When directors or officers change, update
> the signing authority immediately with the bank and record the change in the
> minute book with a new resolution.
>
> **Dual-signature for OBNLs:** Major funders (MTQ/PACM, Tourisme Québec) expect
> dual-signature controls in an OBNL's financial procedures. Some grant programs
> require evidence of internal controls at the application stage. Set the threshold
> and record it before submitting any grant application.

---

## Completion

When BNK-01 through BNK-05 are checked, update `qc-status.md`:
`- [x] quebec-banking — completed [YYYY-MM-DD]`

Then prompt: "Banking is set up. Ensure the signing authority board resolution
is filed in the minute book before any transactions are made. Revisit when
authorized signatories change (new directors, officer changes). The
dual-signature threshold set in BNK-04 is referenced by the expense approval
workflow — complete `/quebec-legal-entity:quebec-expenses` to set up EXP-06."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-banking/
git commit -m "feat(quebec-legal-entity): add quebec-banking skill (banking setup and controls)"
```

---

### Task 2: `quebec-document-management` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-document-management/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-document-management/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-document-management/SKILL.md` with exact content:

```
---
name: quebec-document-management
description: |
  Advisory guide for document management and archiving for Quebec entities.
  Covers digital record validity under Quebec's LCCJTI and CRA electronic
  record rules, what must stay as paper originals, scanning workflow,
  file naming conventions, backup strategy, and retention calendar.

  Short answer: scanned documents are legally valid in Quebec under the LCCJTI
  (Loi concernant le cadre juridique des technologies de l'information) and
  accepted by CRA, with two hard legal exceptions that must stay as paper
  originals.

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

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-document-management/instructions.md` with exact content:

````markdown
# Quebec Document Management — Digital Archiving Guide

This skill guides you through setting up a document management and archiving
system for a Quebec entity. The short answer: scanned documents are legally
valid in Quebec and accepted by CRA, with two hard legal exceptions that
must remain as paper originals.

---

## On Start

1. Read `qc-status.md` for Organization name.
2. Read `qc-document-management.md` if present; create it from the template
   below if absent.
3. Walk through advisory sections in order, asking whether the organization
   has addressed each area, then record decisions.

**`qc-document-management.md` template (create if absent):**

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

---

## NEVER / ALWAYS

### NEVER

- Tell the user that all documents can be digitized — two categories must stay
  as paper originals due to hard legal requirements (see DOC-02)
- Recommend keeping physical originals of everything — the goal is a
  sustainable digital-first system with targeted, clearly defined paper exceptions
- Classify "wet-signature contracts" as a categorical legal exception — they
  are a contractual matter that depends on what the counterparty requires, not
  a legal absolute under the LCCJTI

### ALWAYS

- Lead with the direct answer: scanned documents are legally valid in Quebec
  under the LCCJTI and CRA's electronic records policy, subject to the two
  hard exceptions in DOC-02
- At DOC-05: require at least two backup locations (one local, one cloud) —
  a single storage location is not a backup
- After each section, record the decision (implemented, in progress, or
  explicitly declined with reason) in `qc-document-management.md`

---

## Advisory Sections

For each section: explain the rule, discuss implementation options, and record
the decision in `qc-document-management.md`.

---

### DOC-01 — Digital record validity under LCCJTI and CRA

**What to know:**
Under Quebec's *Loi concernant le cadre juridique des technologies de
l'information* (LCCJTI), a digital document — including a scan of a paper
original — has the same legal force as the paper original provided:

- Its **integrity** is maintained (the document has not been altered after
  creation)
- The **technology** used is reliable and the process is documented
- The **origin** can be established (who created or received it)

CRA also accepts digital records for all tax purposes. CRA's electronic records
policy requires that digital records be:
- Legible when displayed or printed
- Complete (all pages, all attachments)
- Organized so they can be retrieved promptly on request

**Practical implication:** You can scan paper invoices, receipts, bank
statements, board minutes, contracts, and insurance policies, then discard the
paper originals — with the two exceptions listed in DOC-02.

**After confirming:** Record "LCCJTI validity confirmed — digital-first policy
adopted" in `qc-document-management.md`. Check `DOC-01`.

---

### DOC-02 — Documents that must stay as paper originals

**The two hard legal exceptions:**

1. **Notarized or sworn documents** — Any document that bears a notary's or
   commissioner of oaths's wet signature and official seal: sworn declarations
   (déclarations sous serment) such as the RE-303 OBNL declaration, notarized
   agreements, notarized powers of attorney. The notary's physical seal cannot
   be authentically reproduced digitally — a scan is useful for reference but
   the signed original must be kept.

2. **Letters patent** — The original REQ-issued letters patent bearing the
   official government seal (for OBNLs incorporated under Quebec's Companies
   Act via RE-303). Keep the original in the minute book. A certified copy is
   acceptable for most purposes (e.g., bank account opening), but the original
   must be preserved for the life of the organization.

**Everything else** — invoices, receipts, bank statements, board minutes,
insurance policies, tax returns, contracts, grant applications, payroll records
— can be scanned and the paper discarded after scanning, subject to the
scanning workflow in DOC-03.

**Watch for — wet-signature contracts:**
Some counterparties contractually require a wet-signature original (e.g., some
landowner trail access agreements, institutional grant contribution agreements,
financial institution forms). This is a **negotiated contractual requirement**,
not a legal absolute — Quebec's LCCJTI and the Act to establish a legal framework
for information technology both recognize electronic signatures as valid for
contracts unless the parties agree otherwise. When a counterparty's contract
language requires a wet-signature original, you must comply with that contract
term; but this is case-by-case, not a categorical rule across all contracts.

**After confirming exceptions list:** Record "Paper originals list established:
notarized docs + letters patent" in `qc-document-management.md`. Check `DOC-02`.

---

### DOC-03 — Scanning workflow

**Recommended workflow for sustainable digital archiving:**

1. **Scan at 300 dpi minimum** — use 600 dpi for legal documents with fine
   print, small text, or official seals
2. **Save as PDF/A** (ISO 19005 archival format) — not JPEG, not plain PDF.
   PDF/A embeds fonts and prevents future software from altering the content.
   Most modern scanners and scanner apps support PDF/A export.
3. **Name the file immediately** (see DOC-04 naming convention) before moving
   it to the archive folder
4. **Verify legibility** before discarding the paper original — open the scan
   on screen and confirm all text is readable, all pages are captured, and
   the scanner did not clip any edges
5. **For GST/QST receipts specifically:** The scan must show supplier name,
   date, total amount, the GST/QST amounts (or "taxes incluses" with the
   computed amounts), and the supplier's GST/QST registration number — all are
   required for an ITC/RTI claim. A receipt that lacks the registration number
   on the original also lacks it on the scan; the ITC will be denied regardless
   of format.

**After workflow documented:** Record the scanning tool/app chosen and dpi
setting in `qc-document-management.md`. Check `DOC-03`.

---

### DOC-04 — File naming convention

**Recommended convention:** `YYYY-MM-DD_category_description.pdf`

**Examples:**
- `2026-03-01_facture_hydro-quebec-mars.pdf`
- `2026-02-28_DAS_remittance-fevrier.pdf`
- `2026-01-15_contrat_acces-terrain-dupont.pdf`
- `2026-03-12_resolution_signataires-banque.pdf`
- `2025-12-31_etats-financiers_annuels.pdf`

**Folder structure — organize by fiscal year, then category:**

```
[YYYY] Exercice financier/
├── Factures/
├── Contrats/
├── Gouvernement/       (tax filings, RQ correspondence, CRA)
├── Paie/               (payroll records)
├── Assurances/
├── Subventions/        (PACM, grant applications and reports)
└── Résolutions/        (board resolutions, AGM minutes)
```

**Date rule:** Use the document date (invoice date, contract date, resolution
date), not the scan date.

**After convention adopted:** Record the chosen convention in
`qc-document-management.md`. Check `DOC-04`.

---

### DOC-05 — Backup strategy

**Minimum requirement:** Two backup locations — one local and one cloud.
A single storage location (even cloud) is not a backup: if the account is
compromised, suspended, or the provider fails, documents are lost.

**Recommended configuration:**

| Location | Tool | Notes |
| --- | --- | --- |
| Local | External hard drive or NAS | Keep at a different physical location from the primary computer (e.g., a board member's home) |
| Cloud (primary) | Google Drive, OneDrive, or Dropbox | Enable automatic sync; ensure the folder is shared with at least two authorized users |

**Recommended for eligible OBNLs:**
Google Workspace for Nonprofits (free for registered Canadian charities and
eligible non-profits) includes Google Drive with pooled storage. Apply at
google.com/nonprofits.

**Backup schedule:** Cloud backup should be automatic and continuous (sync
tool). Local backup: at minimum monthly, or after any significant document batch.

**After backup configured:** Record the two backup locations in
`qc-document-management.md`. Check `DOC-05`.

---

### DOC-06 — Retention calendar

**Minimum retention periods:**

| Document type | Retention period | Authority |
| --- | --- | --- |
| Tax records (invoices, receipts, returns) | 6 years from end of fiscal year | Revenu Québec / CRA |
| Payroll records | 6 years | Revenu Québec / CRA |
| Employment records | 6 years from end of employment | ANT |
| Corporate minute book | Indefinitely | Corporate law |
| Letters patent / articles | Indefinitely | Corporate law |
| By-laws | Indefinitely | Corporate law |
| Land access agreements (in force) | Duration + 6 years | Contractual + tax |

**Annual action:** Set a recurring calendar reminder each year to purge
documents that have passed their retention period. Typical purge: each
January, delete documents from 7 years prior (e.g., January 2027: purge
documents dated before December 31, 2020).

**After calendar set:** Record the purge schedule in `qc-document-management.md`.
Check `DOC-06`.

---

## KEY WARNING

> **Integrity requirement:** A digital document's legal validity under the
> LCCJTI depends on its integrity — the document must not have been altered
> after it was created or received. Do not edit PDFs after they are filed.
> Store archived documents in a read-only or locked folder where ordinary
> users cannot modify files. If a document must be corrected, create a new
> version, name it clearly (e.g., `2026-03-01_facture_hydro-v2-corrigee.pdf`),
> and retain both the original and the corrected version.

---

## Completion

When all DOC sections have been decided (implemented or explicitly declined
with documented reason), update `qc-status.md`:
`- [x] quebec-document-management — completed [YYYY-MM-DD]`

Then prompt: "Document management system is established. Review annually:
confirm backup is functioning (DOC-05), run the retention purge (DOC-06),
and update the paper-originals list (DOC-02) if new notarized documents have
been created."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-document-management/
git commit -m "feat(quebec-legal-entity): add quebec-document-management skill (digital archiving advisory)"
```

---

### Task 3: `quebec-expenses` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-expenses/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-expenses/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-expenses/SKILL.md` with exact content:

```
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

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-expenses/instructions.md` with exact content:

````markdown
# Quebec Expense Management — Policy and Reimbursement Guide

This skill guides you through setting up an expense policy, receipt procedures,
mileage reimbursement, volunteer expense procedures, and an approval workflow
for a Quebec entity.

---

## On Start

1. Read `qc-status.md` for entity type (for-profit or OBNL) and Organization name.
2. Read `qc-expenses.md` if present; create it from the template below if absent.
3. Walk through advisory sections in order, asking whether each area has been
   addressed, then record decisions.

**`qc-expenses.md` template (create if absent):**

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

---

## NEVER / ALWAYS

### NEVER

- Tell a user that informal verbal expense approvals are adequate for a funded
  OBNL — grant funders (MTQ/PACM, Tourisme Québec) require documented expense
  procedures and may audit; verbal approvals are not auditable
- Suggest that volunteers cannot be reimbursed for expenses — they can and
  should be; only wages and stipends trigger payroll obligations, not
  reimbursement of actual out-of-pocket expenses

### ALWAYS

- At EXP-02: explain the three-tier ITC receipt rule precisely (under $30,
  $30–$149.99, $150+) including exactly what information is required at each tier
- At EXP-03: direct the user to verify the current year's CRA prescribed
  automobile allowance rate at canada.ca before finalizing the policy — the
  rate changes annually; state the 2025 rate as an example only, never as
  the current rate

---

## Advisory Sections

For each section: explain the requirement or best practice, discuss options,
and record the decision in `qc-expenses.md`.

---

### EXP-01 — Written expense policy

**What to do:**
Create a written expense policy document. Grant funders and auditors expect
a documented policy; a verbal or ad hoc process is not acceptable for an
organization receiving public funds.

**The policy must address:**
- What expenses are reimbursable: mileage, meals, accommodation, supplies,
  registration fees, event costs
- Approval authority: who approves whose expenses; the president's or treasurer's
  own expenses should be approved by a different officer (e.g., treasurer
  approves other directors; vice-president approves treasurer's claims)
- Maximum amounts: daily meal cap, hotel cap, mileage rate in use
- Receipt requirements: reference EXP-02 tiers
- Reimbursement timeline: e.g., within 30 days of approved submission
- Non-reimbursable items: alcohol (unless specifically approved), personal
  expenses, spouse/family travel

**Cost:** Free (internal document)
**Delay:** Draft before first expense claims are submitted

**FCMQ and MTQ/PACM audits** may request the policy document. Keep it current
and ensure it is accessible to all board members and staff.

**After policy drafted:** Record "expense policy written and adopted on [date]"
in `qc-expenses.md`. Check `EXP-01`.

---

### EXP-02 — Receipt requirements for ITC/RTI claims

**What to know:**
CRA and Revenu Québec apply a three-tier receipt rule for input tax credit
(ITC) and input tax refund (RTI) claims. The requirements are cumulative —
a higher tier requires everything the lower tier requires plus additional fields.

**Three-tier receipt rule:**

| Amount | Receipt type | Required information |
| --- | --- | --- |
| Under $30 | No receipt required | Petty cash rule — no receipt needed, but keep a petty cash log |
| $30–$149.99 | Simplified receipt | Supplier name, date of purchase, total amount, and an indication that GST/QST was charged (e.g., "taxes included" or the GST/QST amounts); supplier's registration number is NOT required at this tier |
| $150 and over | Full invoice | Supplier name and address, date, description of goods or services, total amount before tax, GST amount and CRA registration number (15-digit BN with RT suffix), QST amount and Revenu Québec registration number (10-digit NE with TQ suffix) |

**Credit card statements alone are insufficient at any tier** — the itemized
receipt is required. A credit card statement shows that a payment was made but
not what was purchased or the tax amounts.

**Practical implication:** For any purchase at $150 or over, request a full
invoice with the supplier's GST/QST registration numbers before leaving the
counter or closing the online order. A receipt that lacks the registration
numbers cannot be fixed retroactively — the ITC is lost.

**After confirming:** Record the three-tier rule in the organization's
expense policy. Record "ITC receipt tiers documented" in `qc-expenses.md`.
Check `EXP-02`.

---

### EXP-03 — Automobile allowance / mileage reimbursement

**What to know:**
CRA sets a prescribed per-kilometre automobile allowance rate annually. Using
the CRA rate has two advantages:
1. The reimbursement is **non-taxable** to the recipient — no payroll
   deductions required
2. The organization can **deduct the full amount** as a business expense

**Example — 2025 CRA rate (verify current year at canada.ca):**
- $0.72/km for the first 5,000 km driven for organization purposes in the year
- $0.66/km for each kilometre over 5,000 km

**IMPORTANT: Verify the current year's rate before approving the policy.**
The CRA rate changes annually. Always direct the user to canada.ca/en/revenue-agency
(search "automobile allowance rates") for the current rate. The 2025 figures
above are examples — do not present them as the current rate without confirming.

**If the organization pays above the CRA rate:** The excess over the prescribed
rate is a taxable benefit to the recipient and requires payroll treatment
(source deductions on the excess).

**Required documentation for mileage claims:**
- Date of each trip
- Origin and destination
- Business purpose
- Kilometres driven

**After confirming mileage rate:** Record the rate in use and the date it was
adopted in `qc-expenses.md`. Note: "Rate to be verified annually at canada.ca."
Check `EXP-03`.

---

### EXP-04 — Board member and volunteer expense reimbursement

**What to know:**
Board members and volunteers may be reimbursed for actual out-of-pocket
expenses incurred on behalf of the organization:
- Travel to and from board meetings, FCMQ assemblies, or MTQ consultations
- Supplies purchased for the organization
- Meals during official organization activities (meetings, events)

**Important distinction:**
- **Reimbursement of actual expenses** (receipt required) = NOT a taxable
  benefit; does NOT trigger payroll obligations
- **Honorarium or stipend** (fixed amount regardless of actual expenses) = IS
  taxable income to the recipient; requires a T4 or T4A slip and potentially
  payroll deductions

Reimbursing a volunteer for $47 in gas costs (with receipt) is not income.
Paying a volunteer a flat $100 "honorarium" is taxable income.

**After confirming volunteer reimbursement procedure:** Record the procedure
(real expense reimbursement vs. honorarium policy) in `qc-expenses.md`.
Check `EXP-04`.

---

### EXP-05 — Per diem policy

**What to know:**
A per diem is a fixed daily allowance for meals and incidental expenses when
a board member, employee, or volunteer travels on organization business. CRA
publishes "reasonable" meal rates periodically.

**Example CRA meal rates (verify current rates at canada.ca — updated periodically):**
- Breakfast: $23
- Lunch: $29
- Dinner: $52

Per diems at or below CRA's reasonable rate are generally non-taxable to the
recipient. Always verify current rates at canada.ca/en/revenue-agency.

**Policy recommendation:** Set per diem rates in the written expense policy
(EXP-01). Specify:
- Whether the organization pays per diem or requires actual receipts for meals
- The maximum per diem amounts for each meal type
- When per diems apply (overnight travel vs. day trips)

**After confirming:** Record the per diem amounts and source date in
`qc-expenses.md`. Note: "Per diem rates to be verified annually at canada.ca."
Check `EXP-05`.

---

### EXP-06 — Approval workflow

**What to do:**
Document a step-by-step expense approval workflow for the organization.

**Recommended minimum workflow:**

1. **Claimant submits expense form** with receipts attached (original paper
   receipts or scanned copies named per the DOC-04 convention from
   `qc-document-management.md`)
2. **Treasurer reviews** receipts against the expense policy: confirms receipts
   meet the EXP-02 tier requirements, confirms the expense is reimbursable,
   confirms amounts are within policy limits
3. **Second signatory approves** for any reimbursement amount at or above the
   dual-signature threshold established in BNK-04 (`qc-banking.md`). For
   amounts below the threshold, treasurer approval alone is sufficient.
   (If `qc-banking.md` has not been completed, ask the user what dual-signature
   threshold they intend to use and record it here temporarily.)
4. **Reimbursement issued** by cheque or e-transfer; the bookkeeper records
   the transaction in bookkeeping software with the expense category and
   receipt reference
5. **Grant audit readiness:** PACM and other grant funders may audit expense
   claims. Maintain organized expense files with the approval form and receipt
   attached together. Electronic files are acceptable — use the DOC-04 naming
   convention.

**After workflow documented and adopted:** Record "approval workflow adopted on
[date]" in `qc-expenses.md`. Check `EXP-06`.

---

## KEY WARNING

> **Grant audit readiness:** PACM and other grant funders may audit expense
> claims. Maintain organized expense files with the approval form and receipt
> attached. Electronic submissions are acceptable; use the DOC-04 naming
> convention from `qc-document-management.md` for consistent filing.
> An expense claim without a receipt or without documented approval is
> ineligible for reimbursement from grant funds.

---

## Completion

When all EXP sections have been decided, update `qc-status.md`:
`- [x] quebec-expenses — completed [YYYY-MM-DD]`

Then prompt: "Expense policies are established. Revisit annually:
- EXP-03: verify the current CRA automobile allowance rate at canada.ca
  (changes each January)
- EXP-05: verify current CRA per diem rates at canada.ca
- EXP-02: no annual change needed — the three-tier ITC thresholds are
  set by regulation and do not change frequently, but confirm if CRA
  publishes an update"
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-expenses/
git commit -m "feat(quebec-legal-entity): add quebec-expenses skill (expense policy advisory)"
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
### `/quebec-legal-entity:quebec-banking`

**Purpose:** Business banking setup and controls guide. Covers institution
selection (with options for community OBNLs and for-profits), authorized
signatories policy via board resolution, online banking and e-transfer
configuration, dual-signature threshold for OBNLs (BNK-04 — referenced by
expense approval workflow in EXP-06), and recording banking information in the
minute book. Complements INC-04 (account opening) with deeper operational
guidance.

**Tags used:** `[GENERIC]`

**Creates:** `qc-banking.md`

**Depends on:** `quebec-incorporation` (INC-04 recommended first — bank
account should exist before configuring controls)

---

### `/quebec-legal-entity:quebec-document-management`

**Purpose:** Advisory digital archiving guide. Covers digital record validity
under Quebec's LCCJTI and CRA electronic records policy (scanned documents are
valid, with two hard legal exceptions: notarized docs and letters patent),
scanning workflow (300 dpi, PDF/A format), file naming convention
(`YYYY-MM-DD_category_description.pdf`), backup strategy (two locations
minimum), and 6-year retention calendar. Distinguishes hard legal exceptions
from contractual wet-signature requirements (case-by-case).

**Tags used:** `[GENERIC]`

**Creates:** `qc-document-management.md`

**Depends on:** Nothing required — run at any time after entity formation

---

### `/quebec-legal-entity:quebec-expenses`

**Purpose:** Advisory expense management guide. Covers written expense policy,
three-tier ITC receipt requirements (under $30 no receipt, $30–$149.99
simplified receipt without registration number, $150+ full invoice with
GST/QST registration numbers), CRA automobile allowance mileage rate (verify
annually at canada.ca — 2025 example: $0.72/km first 5,000 km / $0.66/km
thereafter), board and volunteer reimbursement vs. taxable honorariums, per
diem policy, and approval workflow cross-referencing BNK-04 dual-signature
threshold.

**Tags used:** `[GENERIC]`

**Creates:** `qc-expenses.md`

**Depends on:** `quebec-banking` (BNK-04 dual-signature threshold used by
EXP-06 approval workflow)

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
is correct after adding the three new skills.

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/README.md
git commit -m "docs(quebec-legal-entity): add batch F skills to README (banking, document-management, expenses)"
```

# Batch E — For-Profit Governance Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add one for-profit corporate governance skill (`quebec-forprofit-governance`) to the `quebec-legal-entity` plugin, covering shareholders' agreement, share structure, for-profit minute book, and annual governance resolutions.

**Architecture:** One directory under `quebec-legal-entity/skills/quebec-forprofit-governance/` containing `SKILL.md` (bare YAML front-matter) and `instructions.md` (sequential step guide). On Start, the skill checks `qc-status.md` entity type and exits with an informational message if the entity is an OBNL. State is tracked in `qc-forprofit-governance.md`. README.md gets one new entry. `qc-status.md` gets one new line (for-profit only).

**Tech Stack:** Markdown, YAML front-matter. Plugin framework expects bare `---`-delimited YAML in SKILL.md (no code fence wrappers).

**Spec:** `docs/superpowers/specs/2026-03-12-quebec-legal-entity-batch-e-forprofit-design.md`

---

## Chunk 1: Skill Files

### Task 1: `quebec-forprofit-governance` skill

**Files:**
- Create: `quebec-legal-entity/skills/quebec-forprofit-governance/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-forprofit-governance/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-forprofit-governance/SKILL.md` with exact content:

```
---
name: quebec-forprofit-governance
description: |
  Interactive guide for for-profit Quebec corporation governance: shareholders'
  agreement, share structure setup, for-profit minute book, and annual
  governance resolutions.

  Applies to Quebec business corporations incorporated under the Quebec
  Business Corporations Act (LSAQ — Loi sur les sociétés par actions) or
  federally under the CBCA.

  Reads and writes qc-forprofit-governance.md to track progress.
  Requires entity type = for-profit in qc-status.md.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-forprofit-governance
  - User has a for-profit corporation and needs to set up governance structure
  - User asks about shareholders' agreements, share issuance, or corporate
    resolutions in Quebec

  DO NOT activate when:
  - Entity type is OBNL (use quebec-obnl for OBNL governance)
  - User has not yet incorporated (complete quebec-incorporation first)
  - User is asking about OBNL minute book (covered in quebec-obnl step OBNL-07)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-forprofit-governance.md), Edit(qc-forprofit-governance.md),
  AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-forprofit-governance/instructions.md` with exact content:

````markdown
# Quebec For-Profit Governance — Corporate Structure Guide

This skill guides you through corporate governance setup for a Quebec
for-profit corporation: share structure, shareholders' agreement, minute book,
and annual governance resolutions.

---

## On Start

1. Read `qc-status.md`. Check the entity type field:
   - If entity type is **OBNL**: inform the user:
     > "This skill is for for-profit corporations only. For OBNL governance,
     > use `/quebec-legal-entity:quebec-obnl`."
     Exit — do not proceed.
   - If entity type is **for-profit**: continue.
   - If `qc-status.md` does not exist or entity type is unclear: ask the user
     to confirm their entity type before proceeding.

2. Check `qc-incorporation.md` for INC-03 (initial REQ declaration filed).
   If INC-03 is not checked, tell the user:
   > "Your corporation needs a NEQ before governance setup can begin.
   > Complete `/quebec-legal-entity:quebec-incorporation` through step INC-03
   > (initial REQ declaration) first."
   Exit — do not proceed.

3. Ask: "Was your corporation incorporated under the Quebec LSAQ (Loi sur
   les sociétés par actions) or federally under the CBCA (Canada Business
   Corporations Act)?"
   Record the answer in `qc-forprofit-governance.md`
   (Incorporation_jurisdiction field).

4. Read `qc-forprofit-governance.md` if present; create it from the template
   below if absent.

5. Present current status; jump to first unchecked step.

**`qc-forprofit-governance.md` template (create if absent):**

```markdown
# For-Profit Governance Status — [organization name]
schema_version: 1
Incorporation_jurisdiction: LSAQ | CBCA
Share_classes: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] GOV-01 — Share structure defined
- [ ] GOV-02 — Initial shares issued (organizational resolution)
- [ ] GOV-03 — Shareholders' agreement signed (if 2+ shareholders)
- [ ] GOV-04 — For-profit minute book set up
- [ ] GOV-05 — First annual shareholder meeting held
- [ ] GOV-06 — Annual governance resolutions (recurring, next: [date])
```

---

## NEVER / ALWAYS

### NEVER

- Skip GOV-03 for corporations with 2+ shareholders — a shareholders' agreement
  is critical to prevent deadlock and forced buyout disputes; it is the most
  litigated corporate document in small business disputes
- Mark GOV-02 complete without confirming that share issuance has been
  recorded in the share register (a share register entry is the legal evidence
  of ownership)
- Present this skill to an OBNL — exit immediately at On Start if entity type
  is OBNL

### ALWAYS

- At GOV-01: explain the difference between authorized shares (maximum the
  articles permit) and issued shares (actually allocated to shareholders);
  recommend a simple structure for small corporations (one class of common
  shares with no restrictions) unless there is a specific reason for
  complexity (different classes for income splitting, investor rights, etc.)
- At GOV-03: strongly recommend a lawyer — shareholders' agreements govern
  what happens when partners disagree, one wants to leave, or the business
  needs to be valued; template agreements are inadequate for most situations
- At GOV-05: note the 15-month deadline under LSAQ for holding the first
  annual general meeting after incorporation

---

## Steps

---

### GOV-01 `[GENERIC]` — Define share structure

**What to do:**
Decide on the share structure for the corporation before any shares are issued.
This decision is recorded in the articles of incorporation (already filed) and
in the share register.

**Key concepts:**

- **Authorized shares:** The maximum number of shares the corporation may issue
  (set in the articles). Many small corporations authorize an unlimited number
  of common shares for flexibility.
- **Issued shares:** The shares actually allocated to shareholders. Start with
  a small number (e.g., 100 common shares) — you can issue more later.
- **Share classes:** Most small corporations use a single class of common shares
  with equal voting, dividend, and liquidation rights. Multiple classes are
  used for income splitting (e.g., Class A voting, Class B dividend), investor
  rights (preferred shares), or employee equity programs.

**Recommendation for small corporations:**
One class of common shares (unlimited authorized, small initial issuance)
unless you have a specific reason for complexity. Adding complexity costs
money and creates legal risk if not structured correctly — consult a lawyer
before issuing multiple classes.

**Cost:** Free (internal decision); $500–$2,000 with corporate lawyer
**Delay:** 1–2 weeks if lawyer involved; immediate if decided internally

**After defining structure:** Record share class name(s) and rights in
`qc-forprofit-governance.md` (Share_classes field). Check `GOV-01`.

---

### GOV-02 `[GENERIC]` — Issue initial shares (organizational resolution)

**What to do:**
Pass an organizational resolution authorizing the issuance of initial shares
to the founding shareholders. Record the share issuance in the share register.

**Required documentation:**
1. **Organizational resolution** (résolution d'organisation): A directors'
   resolution authorizing the issuance of shares, stating the number of shares,
   class, price per share, and consideration received (e.g., $1 per share, cash
   or services).
2. **Share register** (registre des actionnaires): Record the name and address
   of each shareholder, share class, number of shares, and certificate number
   if certificates are issued. The share register is the definitive legal record
   of share ownership.
3. **Share certificates** (optional): Physical or electronic certificates. Not
   legally required under LSAQ but commonly issued; record in share register.

**Important:** A resolution alone is not sufficient — the share register must
be updated. A shareholder's ownership is established by the register entry,
not the certificate.

**Cost:** Free
**Delay:** Immediate after articles filed

**After issuing shares:** Update `qc-forprofit-governance.md`. Check `GOV-02`.

---

### GOV-03 `[GENERIC]` — Shareholders' agreement (if 2+ shareholders)

**What to do:**
If the corporation has two or more shareholders, negotiate and sign a
shareholders' agreement before any significant activity begins.

**What it covers:**

- **Share transfer restrictions:** Can shareholders sell freely, or must they
  offer shares to existing shareholders first (right of first refusal)?
- **Shotgun clause:** Mechanism for a deadlocked shareholder to force a buyout
  at a set price — the other party can buy or sell at that price.
- **Valuation method:** How shares are valued if one party leaves or is bought
  out (book value, formula, independent appraisal).
- **Voting arrangements:** Decision-making thresholds; can one shareholder
  block decisions?
- **Drag-along / tag-along:** If a majority wants to sell the company, can
  they force minority shareholders to sell too?

**Important note on Unanimous Shareholder Agreement (USA):**
A USA (accord unanime des actionnaires) is a special form that can transfer
director powers to shareholders, bypassing the board. This has significant
liability implications (shareholders become personally liable for director
obligations). Get legal advice before using a USA.

**LSAQ vs CBCA differences (relevant to agreement drafting):**
- **CBCA:** At least 25% of directors must be Canadian residents. Disputes
  go to federal courts.
- **LSAQ:** No director residency requirement. Disputes go to Quebec courts.
  A Quebec-only business should generally use LSAQ.

**Cost:** $1,500–$5,000 with a corporate lawyer (recommended); template
agreements exist but are inadequate for most situations
**Delay:** 2–6 weeks with lawyer

**If only one shareholder:** Mark GOV-03 as `[n/a] — sole shareholder` in
`qc-forprofit-governance.md`. Check `GOV-03`.

**After agreement signed:** Record date and confirm both parties have signed
copies. Check `GOV-03` in `qc-forprofit-governance.md`.

---

### GOV-04 `[GENERIC]` — Set up for-profit minute book

**What to do:**
Assemble the corporation's minute book (registre de la société). This is the
official record of the corporation's legal and governance documents.

**Required contents:**

| Document | Notes |
| --- | --- |
| Articles of incorporation | Original or certified copy from REQ/Corporations Canada |
| By-laws | Corporate by-laws adopted at organization; can use standard-form by-laws |
| Share register | Updated per GOV-02 |
| Register of directors | Names, addresses, dates of appointment and resignation |
| Organizational resolutions | GOV-02 share issuance resolution and any other organizational resolutions |
| Banking authorization resolution | From BNK-02 in `qc-banking.md` (when complete) |
| Shareholders' agreement | Signed copy (if GOV-03 completed) |

**Format:** A three-ring binder or a digital minute book service (e.g., Lawyerfully,
Ownr, or your lawyer's service). Digital is acceptable under the LCCJTI.

**Cost:** $0 (DIY binder); $100–$200 (commercial minute book service);
included in lawyer's incorporation fee if they handled incorporation
**Delay:** Concurrent with GOV-02

**After minute book assembled:** Check `GOV-04` in `qc-forprofit-governance.md`.

---

### GOV-05 `[GENERIC]` — First annual shareholders' meeting (AGM)

**What to do:**
Hold the first annual general meeting (AGM) of shareholders. Under the LSAQ,
this must be held within 15 months of incorporation.

**Agenda items for first AGM:**

1. **Elect directors** (or confirm organizational directors)
2. **Appoint auditor** (or resolution to waive audit if applicable — small
   private corporations can waive if all shareholders consent)
3. **Approve financial statements** (may be waived if first year is incomplete)
4. **Declare dividends** (if any)

**Formal requirements:**

- Provide written notice to all shareholders (LSAQ specifies minimum notice
  period — typically 21 days for formal notice)
- Record minutes of the meeting and keep in minute book
- Written resolution in lieu of meeting is valid if all shareholders consent
  in writing

**Cost:** Free
**Delay:** Within 15 months of incorporation (LSAQ); similar deadline under CBCA

**After first AGM:** Record minutes in minute book. Update register of directors
if there were any changes. Check `GOV-05` in `qc-forprofit-governance.md`.

---

### GOV-06 `[GENERIC]` — Annual governance resolutions (recurring)

**What to do:**
Each year, hold an AGM or pass annual resolutions to:

1. Re-elect or confirm directors for the next year
2. Approve the prior year's financial statements
3. Declare dividends (if applicable)
4. Appoint or reconfirm auditor (or renew waiver)
5. Confirm any material changes to share structure or by-laws

**When:** Within 6 months of fiscal year-end (LSAQ requirement).

**Option for small corporations:** A written resolution signed by all
shareholders is valid in lieu of a formal AGM meeting.

**Cost:** Free (internal effort); $500–$1,500/year if done through a lawyer

**After each annual resolution cycle:** Update next due date in
`qc-forprofit-governance.md`. Check `GOV-06` (recurring).

---

## KEY WARNINGS

> **Shareholders' agreement ≠ articles of incorporation:** The articles
> (filed with REQ or Corporations Canada) govern the corporation publicly
> and are accessible to anyone. The shareholders' agreement is a private
> contract between shareholders that supplements the articles and is NOT
> filed with any registry. Keep it confidential.
>
> **LSAQ vs CBCA:** Key differences: director residency requirements
> (CBCA requires 25% Canadian residents; LSAQ has no residency requirement);
> jurisdiction of courts for disputes (federal vs Quebec). A Quebec-only
> business should generally use LSAQ unless there is a specific reason for
> federal incorporation (national operations, investor requirement, etc.).
>
> **Unanimous Shareholder Agreement (USA):** Under both the CBCA and LSAQ,
> a USA (accord unanime des actionnaires) can transfer director powers to
> shareholders. This means shareholders take on personal liability for
> director obligations (including source deduction liability). Get legal
> advice before adopting a USA.

---

## Completion

When GOV-01 through GOV-05 are checked (GOV-06 is recurring), update
`qc-status.md`:
`- [x] quebec-forprofit-governance — completed [YYYY-MM-DD]`

Then prompt: "Corporate governance structure is established. Annual obligation:
hold AGM or pass annual resolutions within 6 months of fiscal year-end (GOV-06).
Consider also completing:

- `/quebec-legal-entity:quebec-banking` — authorized signatories and banking policy
- `/quebec-legal-entity:quebec-expenses` — expense reimbursement procedures
- `/quebec-legal-entity:quebec-income-tax` — corporate tax filing obligations"
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-forprofit-governance/
git commit -m "feat(quebec-legal-entity): add quebec-forprofit-governance skill (for-profit governance advisory)"
```

---

## Chunk 2: README Update and Validation

### Task 2: Update README.md

**Files:**
- Modify: `quebec-legal-entity/README.md`

- [ ] **Step 1: Append one skill entry to README.md**

Append the following content to `quebec-legal-entity/README.md` immediately
before the `## Progress Tracking` section:

```markdown
### `/quebec-legal-entity:quebec-forprofit-governance`

**Purpose:** For-profit corporate governance guide. Covers share structure
definition (authorized vs issued shares, share classes), initial share
issuance via organizational resolution and share register update,
shareholders' agreement (strongly recommended for 2+ shareholders: right of
first refusal, shotgun clause, valuation method), for-profit minute book
assembly, first annual shareholders' meeting (AGM within 15 months under
LSAQ), and annual governance resolutions. Exits with an informational message
if the entity type in `qc-status.md` is OBNL.

**Tags used:** `[GENERIC]`

**Creates:** `qc-forprofit-governance.md`

**Depends on:** `quebec-incorporation` (INC-03 must be complete — corporation
must have a NEQ before governance setup)

**Note:** Adds `- [ ] quebec-forprofit-governance — not started (for-profit only)`
to `qc-status.md` on first run.

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
is correct after adding the new skill.

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/README.md
git commit -m "docs(quebec-legal-entity): add batch E skill to README (forprofit-governance)"
```

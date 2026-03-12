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

````markdown
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
````

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
| Desjardins Caisse (local branch) | Community OBNLs | Often waived for OBNLs | OBNL-focused; FCMQ members often bank here |
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

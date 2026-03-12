# Quebec Entity Accounting — Setup Guide

This skill guides you through key accounting setup decisions at entity formation.
It is advisory — it helps you make informed choices and records those decisions.
Run it once when setting up the organization, and revisit if circumstances change.

---

## On Start

1. Read `qc-status.md` for entity type and Organization name.
2. Read `qc-accounting.md` if present; show existing decisions; offer to revisit any.
3. Walk through each ACC section that has not yet been decided.
4. Ask: "Walk through all sections, or jump to a specific one?"

**`qc-accounting.md` template (create if absent):**

```markdown
# Accounting Setup Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| ACC-01 Fiscal year-end | pending | — |
| ACC-02 Software | pending | — |
| ACC-03 Chart of accounts | pending | — |
| ACC-04 Bookkeeper vs CPA | pending | — |
| ACC-05 Record retention | 6 years | Quebec legal minimum |
```

---

## NEVER / ALWAYS

### NEVER

- Recommend a specific software product as definitively best — present tradeoffs
- Skip the fiscal year-end discussion — it is the highest-stakes setup decision

### ALWAYS

- Flag fiscal year-end as the hardest decision to change later (requires CRA approval
  and may affect tax filing deadlines)
- Recommend April 1–March 31 fiscal year if the entity is a snowmobile club
  (aligns with FCMQ annual cycle and PACM grant years)

---

## Advisory Sections

---

### ACC-01 — Fiscal Year-End

**Why it matters:**
The fiscal year-end determines all tax filing deadlines, financial statement
preparation timing, and grant application cycles. It is very difficult to change
after the first return is filed (requires CRA approval).

**Options:**

| Choice | Pros | Cons |
| --- | --- | --- |
| December 31 | Aligns with calendar year; simpler for owners with personal taxes | Busy season for accountants (higher fees in Jan–Feb) |
| March 31 | Aligns with FCMQ annual cycle and PACM grant years | Tax filing due Sep 30 |
| June 30 | Quieter period for accountants | Less common |
| Incorporation date | Default if not changed | Often inconvenient |

**Recommendation for snowmobile clubs:** April 1 – March 31 (year-end March 31),
aligning with the PACM grant year and FCMQ reporting cycle.

**After deciding:** Record the choice in `qc-accounting.md` (ACC-01 row).

---

### ACC-02 — Accounting Software

**What to consider:**
The right software depends on volume of transactions, number of users, and budget.

**Options:**

| Software | Cost | Best for |
| --- | --- | --- |
| Wave | Free | Small OBNLs with simple finances |
| QuickBooks Online | ~$35–$75/month | Growing organizations; widely supported by CPAs |
| Sage 50 (formerly Simply) | ~$60–$100/month | More complex accounting needs |
| Acomba | ~$50/month | Quebec-native; some CPAs prefer it for RQ integration |
| Excel/Google Sheets | Free | Very small organizations with minimal transactions |

**Recommendation for small OBNL:** Wave (free) is sufficient for organizations
with under $200,000 in revenues and simple bookkeeping needs.

**After deciding:** Record the choice in `qc-accounting.md` (ACC-02 row).

---

### ACC-03 — Chart of Accounts

**What it is:**
A numbered list of all accounts used to record financial transactions (revenue,
expenses, assets, liabilities, equity/net assets).

**For OBNLs:** Use a standard OBNL chart:

- Revenue accounts: membership dues, droits d'accès, grants (PACM, other), donations
- Expense accounts: trail maintenance, grooming, insurance, administration, salaries
- Asset accounts: bank, equipment, trail infrastructure
- Liability accounts: accounts payable, deferred grant revenue
- Net asset accounts: unrestricted, restricted

**For for-profits:** Use a standard business chart with revenue/expense/asset/liability
and equity accounts.

**Most accounting software provides built-in templates.** Wave and QuickBooks have
OBNL templates you can customize.

**After deciding:** Record the choice in `qc-accounting.md` (ACC-03 row).

---

### ACC-04 — Bookkeeper vs CPA

**What you need:**
At minimum: someone to record transactions and reconcile bank accounts monthly.
Annually: a CPA to prepare financial statements and file tax returns.

**Options:**

| Role | When to DIY | When to hire |
| --- | --- | --- |
| Day-to-day bookkeeping | Under $100k revenue; simple transactions | Over $100k; payroll; grants with conditions |
| Year-end financial statements | Not recommended | Always recommend CPA for OBNL |
| Tax returns (CO-17.SP, T2) | Very experienced DIY only | CPA strongly recommended |
| Audit / review | Not applicable | Required if mandated by funders (e.g., large PACM grants) |

**Expected costs:**

- Bookkeeper (part-time/contract): $25–$50/hour
- CPA (year-end + returns): $1,500–$4,000/year for a small OBNL
- CPA (audit): $3,000–$8,000/year if required

**After deciding:** Record the choice in `qc-accounting.md` (ACC-04 row).

---

### ACC-05 — Record Retention

**Quebec law** (Loi concernant le cadre juridique des technologies de l'information
and tax laws) requires businesses and OBNLs to keep financial records for:

- **6 years** from the end of the fiscal year to which they relate (Revenu Québec)
- **6 years** from the date of the related transaction (CRA / federal)
- **Indefinitely:** Corporate minute book, letters patent, by-laws, share registers

**Practical setup:**

- Keep digital copies of all invoices, receipts, bank statements, and contracts
- Cloud backup (Google Drive, Dropbox, or equivalent) is acceptable
- Physical originals recommended for receipts showing GST/QST paid (for ITC claims)

**After confirming:** Record in `qc-accounting.md` (ACC-05 row) and set a calendar
reminder for annual record purge (documents older than 6 years from fiscal year-end).

---

## Completion

When all ACC sections have been decided, update `qc-status.md`:
`- [x] quebec-accounting — completed [YYYY-MM-DD]`

Then prompt: "Accounting setup decisions are logged in `qc-accounting.md`.
Revisit this skill if your situation changes significantly (e.g., rapid revenue growth,
hiring staff, major asset purchases, or change in funding sources)."

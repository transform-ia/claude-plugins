# Quebec Corporate Income Tax

This skill guides you through corporate income tax obligations.
The steps differ depending on your entity type — read from `qc-status.md`.

---

## On Start

1. Read `Entity type` from `qc-status.md`. If not set, ask:
   "Is your organization a **for-profit corporation** or an **OBNL** (non-profit)?"
   Record the answer in `qc-status.md`.

2. Tell the user which branch applies:
   - For-profit: "Using **Branch A (for-profit T2)** steps."
   - OBNL: "Using **Branch B (OBNL CO-17.SP + T2)** steps."

3. Read `qc-income-tax.md` if present; create from the appropriate template if absent.

4. Show status; proceed with the branch matching entity type.

**`qc-income-tax.md` template — Branch A (for-profit):**

```markdown
# Income Tax Status — [organization name] (for-profit)
schema_version: 1
Entity_type: for-profit
Fiscal_year_end: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] TAX-01 — Fiscal year-end confirmed
- [ ] TAX-02 — Instalment obligation assessed
- [ ] TAX-03 — Financial statements prepared (annual, next: [date])
- [ ] TAX-04 — T2 filed (annual, next due: [date])
- [ ] TAX-05 — Balance owing paid (annual, next due: [date])
- [ ] TAX-06 — Annual recurring (next cycle: [FY-end date])
```

**`qc-income-tax.md` template — Branch B (OBNL):**

```markdown
# Income Tax Status — [organization name] (OBNL)
schema_version: 1
Entity_type: obnl
Fiscal_year_end: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] TAX-01 — Fiscal year-end confirmed
- [ ] TAX-02 — Financial statements prepared (annual, next: [date])
- [ ] TAX-03 — CO-17.SP filed (annual, next due: [date])
- [ ] TAX-04 — T2 filed (annual, next due: [date])
- [ ] TAX-05 — T1044 filed if required (annual)
- [ ] TAX-06 — Annual recurring (next cycle: [FY-end date])
```

---

## NEVER / ALWAYS

### NEVER

- Apply OBNL tax steps (CO-17.SP, T1044) to a for-profit entity
- Apply for-profit instalment rules to an OBNL

### ALWAYS

- Record the fiscal year-end at TAX-01 and prompt user to set calendar reminders
- At TAX-05 (OBNL): ask the three T1044 threshold questions before deciding if
  the step is required
- At TAX-02 (for-profit): explain the two-instalment safe-harbour; recommend a CPA
  for first-year instalment setup

---

## Branch A — For-Profit Corporation

---

### TAX-01 `[GENERIC][PROV][FED]` — Confirm fiscal year-end

**What to do:**
Confirm your corporation's fiscal year-end. This is typically set in your articles
of incorporation or can be chosen at first tax filing.

**Common choices:**

- December 31 (calendar year — simple, aligns with personal taxes)
- March 31 (aligns with government program cycles)
- Any date that suits your business cycle

**Cost:** Free
**Delay:** At setup (one-time)

**After confirming:** Record the fiscal year-end in `qc-income-tax.md`. Check `TAX-01`.
Prompt user to set calendar reminders for filing and payment deadlines.

---

### TAX-02 `[GENERIC][FED]` — Assess instalment obligation

**What to do:**
Determine whether you must pay corporate tax instalments during the year.

**Instalment requirement:** Required when your net tax owing exceeds $3,000 in the
**current or prior tax year**.

**For CCPCs (Canadian-Controlled Private Corporations):** Two options exist:

1. Monthly instalments (1/12 of prior year tax)
2. Two-instalment method (pay 2/3 of prior year tax by 2nd month, 1/3 by 3rd month)

**Safe harbour:** No interest if instalments equal the prior year's tax. Consult a
CPA for your first year's instalment setup.

**Cost:** Free (assessment)
**Delay:** 2nd and 3rd month of fiscal year (for payment)

**After confirming:** Check `TAX-02` in `qc-income-tax.md`.

---

### TAX-03 `[GENERIC][PROV][FED]` — Prepare financial statements

**What to do:**
Prepare year-end financial statements: balance sheet and income statement.
These are required for T2 preparation.

**Cost:** $500–$3,000 (bookkeeper/accountant)
**Delay:** Within 6 months of fiscal year-end

**After confirming:** Check `TAX-03` in `qc-income-tax.md`.
Record the next fiscal year-end date for planning.

---

### TAX-04 `[GENERIC][FED]` — File T2 corporate income tax return

**What to do:**
File the T2 Corporate Income Tax Return with CRA.

**Due:** Within 6 months of fiscal year-end (e.g., June 30 for a December 31 year-end).

**Where:** Via tax software (TaxPrep, Profile, etc.) or through your CPA.

**Cost:** Free to file; included in CPA fees.
**Delay:** Within 6 months of fiscal year-end

**After confirming:** Check `TAX-04` in `qc-income-tax.md`.
Record the next due date.

---

### TAX-05 `[GENERIC][FED]` — Pay balance owing

**What to do:**
Pay any remaining corporate income tax balance owing.

**Due:**

- **General corporations:** 2 months after fiscal year-end
- **Eligible CCPCs (small business deduction):** 3 months after fiscal year-end

Note: The payment deadline is **earlier** than the return filing deadline.
Interest accrues daily on unpaid amounts from the due date.

**Cost:** Variable
**Delay:** 2–3 months after fiscal year-end

**After confirming:** Check `TAX-05` in `qc-income-tax.md`.

---

### TAX-06 `[GENERIC]` — Annual recurring (Branch A)

This step marks the completion of each annual cycle. When TAX-05 is done,
update the next cycle start date in `qc-income-tax.md` and re-open TAX-02
through TAX-05 for the next fiscal year.

---

## Branch B — OBNL (Non-Profit)

---

### TAX-01 `[OBNL][PROV][FED]` — Confirm fiscal year-end

**What to do:**
Confirm your OBNL's fiscal year-end. This should have been set at the constitutive
general assembly (OBNL-06) and recorded in the by-laws.

**Common choices for OBNLs:**

- March 31 (aligns with FCMQ/PACM grant cycles — strongly recommended for snowmobile clubs)
- December 31

**Cost:** Free
**Delay:** At setup (one-time)

**After confirming:** Record in `qc-income-tax.md`. Check `TAX-01`.
Prompt user to set calendar reminders: "file by [FY-end + 6 months]".

---

### TAX-02 `[OBNL][PROV][FED]` — Prepare financial statements

**What to do:**
Prepare year-end financial statements (bilan + état des résultats).
Required for CO-17.SP and T2 preparation and for presentation at the AGA (OBNL-08).

**Cost:** $500–$3,000/year
**Delay:** Within 6 months of fiscal year-end

**After confirming:** Check `TAX-02` in `qc-income-tax.md`.

---

### TAX-03 `[OBNL][PROV]` — File CO-17.SP with Revenu Québec

**What to do:**
File Form CO-17.SP ("Déclaration de revenus des organismes sans but lucratif")
with Revenu Québec.

**Exemption:** Most OBNLs are exempt from Quebec corporate income tax under
section 998 of the Taxation Act. However, the return must still be filed to
claim the exemption.

**Due:** Within 6 months of fiscal year-end.

**Where:** revenuquebec.ca or through your accountant/CPA.

**Cost:** Free to file; included in accounting fees.
**Delay:** Within 6 months of fiscal year-end

**After confirming:** Check `TAX-03` in `qc-income-tax.md`. Record next due date.

---

### TAX-04 `[OBNL][FED]` — File T2 with CRA (149(1)(l) exemption)

**What to do:**
File the T2 Corporate Income Tax Return with CRA, claiming exemption under
ITA paragraph 149(1)(l) (non-profit organization for social welfare, civic
improvement, pleasure, recreation, or any other purpose except profit).

**Due:** Within 6 months of fiscal year-end.

**Cost:** Free to file; included in CPA fees.
**Delay:** Within 6 months of fiscal year-end

**After confirming:** Check `TAX-04` in `qc-income-tax.md`. Record next due date.

---

### TAX-05 `[OBNL][FED]` — File T1044 NPO Information Return (if required)

**What to do:**
Determine whether the T1044 is required, then file if so.

**T1044 is required if ANY ONE of the following applies:**

- Total assets exceeded $200,000 at the end of the previous fiscal year
- Total revenues exceeded $100,000 in the fiscal year
- The corporation received or held property from the public (donated or in trust)
  with a total value exceeding $100,000

Ask the user each of these three questions. If any is yes, file the T1044.

**Filed together with:** T2 (same due date).

**Cost:** Free to file.

**After confirming (or confirming not required):** Check `TAX-05` in `qc-income-tax.md`.

---

### TAX-06 `[OBNL]` — Annual recurring (Branch B)

When TAX-05 is done, update the next cycle start date in `qc-income-tax.md`
and re-open TAX-02 through TAX-05 for the next fiscal year.

---

## Key Warnings

> **No charitable receipts:** The 149(1)(l) NPO exemption is NOT charitable status.
> The organization cannot issue tax-deductible donation receipts to donors. To issue
> receipts, the organization would need to apply for registered charity status with
> CRA — a separate and more demanding process not covered by this skill.
>
> **CCPC payment deadline:** For-profit corporations eligible for the small business
> deduction (CCPCs) have 3 months (not 2) to pay the balance owing after year-end.
> Confirm your CCPC status with your CPA.
>
> **Instalment interest:** Compounds daily on shortfalls. Set calendar reminders for
> instalment due dates.

---

## Completion

When all TAX steps are checked, update `qc-status.md`:
`- [x] quebec-income-tax — completed [YYYY-MM-DD]`

Then prompt: "Annual income tax obligations are set up. Return each year at
[FY-end minus 2 months] to begin the filing cycle on time."

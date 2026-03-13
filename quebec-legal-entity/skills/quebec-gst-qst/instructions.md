# Quebec GST/QST — Registration and Ongoing Filing

This skill guides you through GST and QST obligations for your Quebec entity.

**Key fact:** In Quebec, Revenu Québec administers both the federal GST (5%) and
provincial QST (9.975%) — one registration covers both taxes. This differs from
other provinces where CRA handles GST directly.

---

## On Start

**Before proceeding:** Read `skills/_shared/learnings-protocol.md`. Then read
`skills/quebec-gst-qst/learnings.md` if it exists and incorporate any entries into your
working knowledge for this session.

1. Read `qc-status.md` for entity type and Organization name.
2. Read `qc-gst-qst.md` if present; create it from the template below if absent.
3. Show current GST/QST status; jump to first unchecked step.

**`qc-gst-qst.md` template (create if absent):**

```markdown
# GST/QST Status — [organization name]
schema_version: 1
GST_QST_number: pending
Filing_frequency: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] GST-01 — Registration obligation assessed
- [ ] GST-02 — Registered for GST/QST (number: pending)
- [ ] GST-03 — Filing frequency selected
- [ ] GST-04 — ITC/RTI tracking set up
- [ ] GST-05 — First return filed
- [ ] GST-06 — Ongoing filing (recurring, next due: [date])
```

---

## NEVER / ALWAYS

### NEVER

- Tell an entity below the $30,000 threshold that they cannot register voluntarily
- Skip the instalment warning for entities with significant tax volumes
- Confuse GST registration with income tax registration (they are separate)

### ALWAYS

- Remind the user that Revenu Québec handles both GST and QST in Quebec
- At GST-03, guide the selection of filing frequency based on expected annual volume
- After GST-02, record the GST/QST registration number in `qc-gst-qst.md`

---

## Steps

---

### GST-01 `[GENERIC][PROV][FED]` — Assess registration obligation

**What to do:**
Determine whether GST/QST registration is mandatory or voluntary for your entity.

**Mandatory registration:** Required when total taxable supplies (revenues from
taxable goods and services) exceed $30,000 in a single calendar quarter or over
four consecutive quarters.

**Voluntary registration:** Allowed at any time, even below the threshold.
**Often beneficial** because registered entities can claim Input Tax Credits (ITCs
for GST) and Input Tax Refunds (RTIs for QST) on business purchases, potentially
recovering significant tax paid on expenses.

**OBNL note:** Membership fees and fundraising activities may be exempt supplies.
Droits d'accès (trail access fees) are generally taxable supplies.

**Cost:** Free
**Delay:** Immediate (assessment)

**After completing assessment:** Check `GST-01` in `qc-gst-qst.md`.
Note whether registration is mandatory or voluntary.

---

### GST-02 `[GENERIC][PROV][FED]` — Register for GST/QST

**What to do:**
Register for both GST and QST with Revenu Québec using a single registration.

**Where:** revenuquebec.ca → "Mon dossier pour les entreprises" (online, preferred)
or complete Form LM-1-V and mail/submit in person.

**Information required:**

- NEQ (Numéro d'entreprise du Québec)
- Nature of business activities
- Estimated annual revenues from taxable supplies
- Fiscal year-end
- Preferred filing frequency (see GST-03)

**Cost:** Free
**Delay:** 2–4 weeks to receive registration confirmation and number

**After confirming receipt:** Record the GST/QST registration number in
`qc-gst-qst.md` (replace "pending"). Check `GST-02`.

---

### GST-03 `[GENERIC][PROV][FED]` — Select filing frequency

**What to do:**
Choose how often you will file GST/QST returns. Revenu Québec may assign a
frequency based on estimated volume, but you can request a different one.

**Filing frequency options:**

| Frequency | Annual taxable supplies | Return due |
| --- | --- | --- |
| Annual | Under $1,500,000 | 3 months after fiscal year-end |
| Quarterly | Under $6,000,000 | 1 month after quarter-end |
| Monthly | Any amount | 1 month after month-end |

**Recommendation for small OBNLs:** Annual or quarterly. Monthly is burdensome
unless you have high volumes of purchases generating significant ITC/RTI claims.

**Cost:** Free
**Delay:** At registration

**After confirming frequency:** Record in `qc-gst-qst.md` (Filing_frequency field).
Check `GST-03`.

---

### GST-04 `[GENERIC][PROV][FED]` — Set up ITC/RTI tracking

**What to do:**
Configure your bookkeeping system to track:

- GST and QST paid on eligible business purchases (generates ITCs/RTIs)
- GST and QST collected on taxable supplies (creates liability)

**Why this matters:** Without tracking, you cannot claim ITCs/RTIs and will
overpay taxes. Your net remittance = tax collected − ITCs/RTIs.

**In practice:**

- Use your accounting software (Wave, QuickBooks, etc.) to tag each purchase
  and sale with the correct tax treatment
- Keep receipts showing GST/QST paid (required for ITC/RTI claims)
- Non-registrants cannot claim ITCs/RTIs retroactively after registration

**Cost:** Free (time to configure software)
**Delay:** Before first return

**After confirming setup:** Check `GST-04` in `qc-gst-qst.md`.

---

### GST-05 `[GENERIC][PROV][FED]` — File first GST/QST return

**What to do:**
File your first combined GST/QST return through Revenu Québec.

**Where:** revenuquebec.ca → "Mon dossier pour les entreprises" (online, preferred)
or Form FPZ-500-V (paper).

**What to report:**

- Total taxable supplies for the period
- GST collected (5%)
- QST collected (9.975%)
- Less: ITCs (GST on eligible purchases)
- Less: RTIs (QST on eligible purchases)
- Net tax owing (or refund due)

**Cost:** Free to file
**Delay:** Per selected frequency (annual/quarterly/monthly)

**If net tax owing exceeds $3,000 annually:** Instalment payments will be
required in subsequent years (see warning below).

**After confirming filing:** Check `GST-05` in `qc-gst-qst.md`.

---

### GST-06 `[GENERIC][PROV][FED]` — Ongoing return filing (recurring)

**What to do:**
File GST/QST returns on your selected schedule. Each return covers the supplies
and purchases for that period.

**Due dates:**

- Annual: 3 months after fiscal year-end
- Quarterly: 1 month after quarter-end
- Monthly: 1 month after month-end

**Instalment obligations:** If your net tax for the prior year exceeded $3,000,
you must make instalment payments. Revenu Québec will notify you.

**Cost:** Free to file
**Delay:** Per frequency

**After each filing:** Update the `next due` date in `qc-gst-qst.md`.
Check `GST-06` (re-check annually to confirm ongoing compliance).

---

## Key Warnings

> **Late filing penalty:** 1% of net tax owing + 0.25% of net tax per additional
> month late, maximum 24 months (maximum penalty = 7% of net tax). Interest also
> accrues on unpaid amounts. File on time even if you cannot pay.
>
> **Voluntary registration advantage:** Registering below the $30,000 threshold
> allows you to claim ITCs/RTIs on all eligible business purchases retroactively
> to registration. For capital-intensive organizations, this can be significant.
>
> **Instalment trigger:** When annual net tax exceeds $3,000 for the first time,
> Revenu Québec will require quarterly instalments in the following year.

---

## Completion

When all steps are checked, update `qc-status.md`:
`- [x] quebec-gst-qst — completed [YYYY-MM-DD]`

Then prompt: "GST/QST is registered and first return filed. Remember to file
returns on your selected schedule and update the next due date in `qc-gst-qst.md`
after each filing."

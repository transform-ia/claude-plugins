# Quebec Legal Entity — Generic Incorporation Steps

This skill guides you through the generic Quebec legal entity formation steps.
These steps apply to any organization type — for-profit or non-profit.

**Non-profit (OBNL) users:** After completing pre-incorporation steps here,
continue with `/legal-entity-incorporation:quebec-obnl` for OBNL-specific steps,
then return here for post-incorporation steps once you have your letters patent and NEQ.

---

## On Start: Read or Create State File

1. Check for `obnl-status.md` in the current working directory.
2. If absent: create it with the template below (schema_version: 1, all boxes unchecked).
   Ask the user: "What is the name of your organization?" and pre-fill the Organization field.
3. If present: read it, present the current status, and jump to the first unchecked step.

**State file template (create if absent):**

````markdown
# OBNL Incorporation Status
schema_version: 1
Organization: [organization name]
NEQ: pending
B2_date: pending
D1_deadline: pending
E2_next_window: [Year] June–August
Last updated: YYYY-MM-DD

## Skill 1: quebec-incorporation
- [ ] S1-01 (A2a) - Name search completed
- [ ] S1-02 (A2b) - Name reservation (optional)
--- Post-incorporation (requires Skill 2 step S2-05 complete) ---
- [ ] S1-03 (D1) - Initial REQ declaration filed (within 60 days = D1_deadline)
- [ ] S1-04 (D2) - GST/QST registration (if applicable)
- [ ] S1-05 (D6) - CRA Business Number obtained
- [ ] S1-06 (D3) - Source deductions registered (if hiring employees)
- [ ] S1-07 (F1) - Bank account opened
- [ ] S1-08 (G1) - REQ annual update (annual, next due: [date])

## Skill 2: quebec-obnl
- [ ] S2-01 (A1) - Founding members confirmed (min. 3)
- [ ] S2-02 (A3) - RE-303 drafted + sworn declaration notarized
- [ ] S2-03 (A4) - By-laws drafted (dissolution clause included)
- [ ] S2-04 (B1) - RE-303 filed with REQ
- [ ] S2-05 (B2) - Letters patent received + NEQ assigned
- [ ] S2-06 (C1) - Constitutive general assembly held
- [ ] S2-07 (C2) - Minute book set up
- [ ] S2-08 (D4) - CO-17.SP filed (annual, first due: [date])
- [ ] S2-09 (D5) - T2 + T1044 filed (annual, first due: [date])
- [ ] S2-10 (G2) - AGA held (annual, next: [date])
- [ ] S2-11 (G3) - Financial statements prepared (annual)
- [ ] S2-12 (G4) - Tax returns filed (annual)

## Skill 3: snowmobile-club-qc
- [ ] S3-01 (E1) - FCMQ application submitted
- [ ] S3-02 (E1b) - FCMQ membership approved (board decision)
- [ ] S3-03 (E2) - MTQ/PACM application submitted (window: E2_next_window)
- [ ] S3-04 (E3) - Insurance obtained (FCMQ base + additional)
- [ ] S3-05 (E4) - VHR trail designation obtained from MTQ
- [ ] S3-06 (G5) - FCMQ annual renewal (next: [date])
````

---

## Resumption Logic

- If steps S1-01 and S1-02 are checked but S1-03 onward are not: check whether
  S2-05 (letters patent) is checked. If yes, proceed to S1-03. If no, inform the
  user: "Post-incorporation steps (S1-03 onward) require your letters patent and NEQ
  from the OBNL skill. Complete `/legal-entity-incorporation:quebec-obnl` through
  step S2-05 first, then return here."

---

## Steps

After reading/creating the state file, guide the user through each unchecked step
in order. For each step: explain what to do, list required documents/forms,
show cost and expected delay, then ask "Have you completed this step?" before
marking it done in `obnl-status.md`.

---

### S1-01 `[GENERIC][PROV]` — Name search at REQ

**What to do:**
Search the Registre des entreprises du Québec to confirm the desired name is available.

**URL:** <https://www.registreentreprises.gouv.qc.ca> (public search, no login needed)

**Rules:**

- Name must comply with the Charter of the French Language: primarily French, or
  French-first (e.g., "Club de motoneige X inc." not "X Snowmobile Club inc.")
- Must not be identical or confusingly similar to an existing registered entity
- Must not be misleading about the nature of the organization

**Cost:** Free
**Delay:** Immediate

**After confirming completion:** Update `obnl-status.md` — check `S1-01`.

---

### S1-02 `[GENERIC][PROV]` — Name reservation (optional)

**What to do:**
Reserve the name for 90 days to protect it while you prepare filing documents.

**Where:** registreentreprises.gouv.qc.ca → "Réserver un nom"

**Cost:** $27.00 (regular) / $40.50 (priority)
**Delay:** 2–5 business days for confirmation

**This step is optional.** Recommend it if drafting documents will take more than
a week or if the name is distinctive and worth protecting.

**After confirming completion:** Update `obnl-status.md` — check `S1-02`.

---

## Post-Incorporation Gate

> **STOP:** Steps S1-03 through S1-08 require your letters patent and NEQ number.
> These are issued by the REQ after filing your incorporation documents (Skill 2, step S2-05).
>
> If you have not yet received your letters patent, continue with:
> `/legal-entity-incorporation:quebec-obnl`
>
> Once you have your letters patent (S2-05 checked), return here to complete S1-03 onward.

When the user returns with S2-05 complete, confirm their NEQ is recorded in `obnl-status.md`
and calculate the D1 deadline:

```text
D1_deadline = B2_date + 60 calendar days
```

Update `obnl-status.md` with both values.

---

### S1-03 `[GENERIC][PROV]` — Initial REQ declaration (Déclaration initiale)

**What to do:**
File the initial declaration within 60 days of receiving your letters patent.

**Deadline:** D1_deadline (60 days from B2_date). **Mandatory — late filing triggers fines.**

**Where:** Mon Bureau at registreentreprises.gouv.qc.ca (requires login/account)

**Required information:**

- Directors' names and addresses
- Registered office address
- Description of activities

**Cost:** Free
**Delay:** Immediate online processing

**After confirming completion:** Update `obnl-status.md` — check `S1-03`.

---

### S1-04 `[GENERIC][PROV][FED]` — GST/QST registration

**What to do:**
Register for GST (5%) and QST (9.975%) with Revenu Québec if your taxable supplies
will exceed $30,000 in a single calendar quarter or over four consecutive quarters.

**In Quebec, Revenu Québec administers BOTH taxes** — one registration covers both.

**Where:** revenuquebec.ca → "S'inscrire" → LM-1 form (or online)

**Note:** Trail access fees (droits d'accès) are generally taxable supplies.
Register proactively if you expect to reach the threshold.

**Cost:** Free
**Delay:** 2–4 weeks to receive registration number

**After confirming completion:** Update `obnl-status.md` — check `S1-04`.

---

### S1-05 `[GENERIC][FED]` — CRA Business Number (BN)

**What to do:**
A 9-digit CRA Business Number is assigned automatically when you register for
GST/HST. If you registered with Revenu Québec (S1-04), your BN is included.

If you skipped S1-04 (below the threshold), you can request a BN directly at
canada.ca/en/revenue-agency.

**Cost:** Free
**Delay:** Concurrent with S1-04 (or 1–2 weeks if requested separately)

**After confirming completion:** Record the BN and update `obnl-status.md` — check `S1-05`.

---

### S1-06 `[GENERIC][PROV][FED]` — Source deduction registration

**What to do:**
Only required if you will hire paid employees (e.g., trail groomer operators,
part-time administrators).

Register with Revenu Québec for: QPP, QPIP, Quebec income tax withholding.
Register with CRA for: CPP (not QPP for Quebec employers), EI, federal income tax.

**Where:** revenuquebec.ca → "Inscription employeur"

**Cost:** Free
**Delay:** Register before first payroll

**Skip this step if you have no employees.** Update `obnl-status.md` accordingly
(mark as N/A or checked with a note).

**After confirming completion (or N/A):** Update `obnl-status.md` — check `S1-06`.

---

### S1-07 `[GENERIC]` — Open business bank account

**What to do:**
Open a bank account in the organization's name. Most banks require an appointment.

**Required documents (typical):**

- Letters patent (original or certified copy)
- NEQ number
- Current by-laws
- Minutes of constitutive assembly (showing authorization to open account and
  naming authorized signatories)
- Government-issued photo ID for all authorized signatories

**Recommended institutions for Quebec OBNLs:**

- Desjardins Caisse (local credit unions — strongly recommended for community
  organizations; often have OBNL-specific accounts with reduced/waived fees)
- Banque Nationale
- BMO Non-profit account

**Cost:** $0–$25/month (many institutions waive fees for small non-profits)
**Delay:** 1–2 weeks (requires appointment + document review)

**After confirming completion:** Update `obnl-status.md` — check `S1-07`.

---

### S1-08 `[GENERIC][PROV]` — Annual REQ update declaration (recurring)

**What to do:**
File the annual update declaration (déclaration de mise à jour annuelle) with the REQ.

**When:** REQ sends a notice annually. File promptly — late filing incurs a 50%
surcharge on registration fees plus interest.

**What to update:** Current directors, registered office address, activities.

**Where:** Mon Bureau at registreentreprises.gouv.qc.ca

**Cost:** $41.00 (regular) / $61.50 (priority)
**Delay:** Immediate online processing

**Note:** This is a recurring annual obligation. When completing it for the first
year, record the next due date in `obnl-status.md`.

**After confirming completion:** Update `obnl-status.md` — check `S1-08` and set next due date.

---

## Completion

When all pre-incorporation steps are checked, prompt: "Great — you're ready to
file your OBNL incorporation documents. Continue with:
`/legal-entity-incorporation:quebec-obnl`"

When all post-incorporation steps are also checked, prompt: "All generic
incorporation steps are complete. If you are operating a snowmobile club, continue
with `/legal-entity-incorporation:snowmobile-club-qc`"

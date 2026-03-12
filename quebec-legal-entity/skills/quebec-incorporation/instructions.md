# Quebec Legal Entity — Generic Incorporation Steps

This skill guides you through the generic Quebec legal entity formation steps.
These steps apply to any organization type — for-profit or non-profit.

**Non-profit (OBNL) users:** After completing pre-incorporation steps here,
continue with `/quebec-legal-entity:quebec-obnl` for OBNL-specific steps,
then return here for post-incorporation steps once you have your letters patent and NEQ.

---

## On Start

1. **Check for legacy file:** If `obnl-status.md` exists in the working directory,
   stop and tell the user:
   > "A legacy state file (`obnl-status.md`) was found from a previous version of
   > this plugin. The `quebec-legal-entity` plugin uses new state files. Please
   > rename or remove `obnl-status.md` and restart this skill."

2. **Check for `qc-status.md`:** If absent, ask:
   "What is the name of your organization?" and "Is this organization a
   **for-profit corporation** or an **OBNL** (non-profit)?"
   Create `qc-status.md` from the template below with those answers filled in.

3. **Check for `qc-incorporation.md`:** If absent, create it from the template below.

4. **Read `qc-incorporation.md`:** Present current status and jump to first unchecked step.

**`qc-status.md` template (create if absent):**

````markdown
# Quebec Legal Entity Status
schema_version: 1
Organization: [organization name]
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
````

**`qc-incorporation.md` template (create if absent):**

```markdown
# Incorporation Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps
- [ ] INC-01 — Name search completed
- [ ] INC-02 — Name reservation (optional)
--- Post-incorporation gate (requires OBNL-05 for OBNL; user confirms NEQ for for-profit) ---
- [ ] INC-03 — Initial REQ declaration filed (deadline: [D1_deadline])
- [ ] INC-04 — Bank account opened
- [ ] INC-05 — REQ annual update (annual, next due: [date])
```

---

## Resumption Logic

- If INC-01 and INC-02 are checked but INC-03 onward are not:
  - **OBNL:** Check whether OBNL-05 is checked in `qc-obnl.md`. If yes, proceed to INC-03.
    If no, tell the user: "Post-incorporation steps (INC-03 onward) require your letters
    patent and NEQ. Complete `/quebec-legal-entity:quebec-obnl` through step OBNL-05 first,
    then return here."
  - **For-profit:** Ask: "Do you have your NEQ from the Registraire des entreprises?"
    If yes, unlock INC-03. If no, tell the user: "You need to complete incorporation
    first (articles of incorporation via registreentreprises.gouv.qc.ca). For-profit
    articles of incorporation are outside the scope of this skill. Return here once
    you have your NEQ."

---

## Steps

For each step: explain what to do, list required documents/forms,
show cost and delay, then ask "Have you completed this step?" before checking it.

---

### INC-01 `[GENERIC][PROV]` — Name search at REQ

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

**After confirming completion:** Update `qc-incorporation.md` — check `INC-01`.
Update `qc-status.md` Last updated date.

---

### INC-02 `[GENERIC][PROV]` — Name reservation (optional)

**What to do:**
Reserve the name for 90 days to protect it while you prepare filing documents.

**Where:** registreentreprises.gouv.qc.ca → "Réserver un nom"

**Cost:** $27.00 (regular) / $40.50 (priority)
**Delay:** 2–5 business days for confirmation

**This step is optional.** Recommend it if drafting documents will take more than
a week or if the name is distinctive and worth protecting.

**After confirming completion:** Update `qc-incorporation.md` — check `INC-02`.

---

## Post-Incorporation Gate

> **STOP:** Steps INC-03 through INC-05 require your NEQ number.
>
> **If OBNL:** These steps require your letters patent, issued by the REQ after filing
> your incorporation documents (OBNL skill, step OBNL-05).
> Continue with: `/quebec-legal-entity:quebec-obnl`
> Once you have your letters patent (OBNL-05 checked), return here.
>
> **If for-profit:** Confirm that you have your NEQ from the REQ before continuing.
> For-profit articles of incorporation are outside the scope of this skill.

When the user returns with NEQ confirmed, record the NEQ and — for OBNL entities —
calculate the D1 deadline:

```text
D1_deadline = B2_date + 60 calendar days
```

Update `qc-incorporation.md` with the D1_deadline value in the INC-03 line.

---

### INC-03 `[GENERIC][PROV]` — Initial REQ declaration (Déclaration initiale)

**What to do:**
File the initial declaration within 60 days of receiving your NEQ.

**Deadline:** D1_deadline (60 days from letters patent date). **Mandatory — late filing triggers fines.**

**Where:** Mon Bureau at registreentreprises.gouv.qc.ca (requires login/account)

**Required information:**

- Directors' names and addresses
- Registered office address
- Description of activities

**Cost:** Free
**Delay:** Immediate online processing

**After confirming completion:** Update `qc-incorporation.md` — check `INC-03`.

---

### INC-04 `[GENERIC]` — Open business bank account

**What to do:**
Open a bank account in the organization's name. Most banks require an appointment.

**Required documents (typical):**

- Letters patent (original or certified copy) — OBNL only
- NEQ number
- Current by-laws — OBNL only
- Minutes of constitutive assembly (showing authorization to open account and
  naming authorized signatories) — OBNL only
- Government-issued photo ID for all authorized signatories

**Recommended institutions for Quebec OBNLs:**

- Desjardins Caisse (local credit unions — strongly recommended for community
  organizations; often have OBNL-specific accounts with reduced/waived fees)
- Banque Nationale
- BMO Non-profit account

**Cost:** $0–$25/month (many institutions waive fees for small non-profits)
**Delay:** 1–2 weeks (requires appointment + document review)

**After confirming completion:** Update `qc-incorporation.md` — check `INC-04`.

---

### INC-05 `[GENERIC][PROV]` — Annual REQ update declaration (recurring)

**What to do:**
File the annual update declaration (déclaration de mise à jour annuelle) with the REQ.

**When:** REQ sends a notice annually. File promptly — late filing incurs a 50%
surcharge on registration fees plus interest.

**What to update:** Current directors, registered office address, activities.

**Where:** Mon Bureau at registreentreprises.gouv.qc.ca

**Cost:** $41.00 (regular) / $61.50 (priority)
**Delay:** Immediate online processing

**Note:** This is a recurring annual obligation. Record the next due date in
`qc-incorporation.md` when completing for the first time.

**After confirming completion:** Update `qc-incorporation.md` — check `INC-05`
and set next due date.

---

## Completion

When all pre-incorporation steps are checked (INC-01, INC-02), prompt:
"Great — you're ready to file your OBNL incorporation documents. Continue with:
`/quebec-legal-entity:quebec-obnl`"

When all post-incorporation steps are also checked, update `qc-status.md`:
`- [x] quebec-incorporation — completed [YYYY-MM-DD]`

Then prompt:
"All incorporation steps are complete. Continue with:

- `/quebec-legal-entity:quebec-gst-qst` — GST/QST registration and filing
- `/quebec-legal-entity:quebec-payroll` — payroll setup (if you have employees)
- `/quebec-legal-entity:quebec-income-tax` — annual corporate income tax
- `/quebec-legal-entity:quebec-insurance` — insurance coverage review
- `/quebec-legal-entity:quebec-accounting` — bookkeeping setup"

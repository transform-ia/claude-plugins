# Quebec OBNL — Non-Profit Incorporation (Part III)

This skill guides you through OBNL-specific incorporation steps under
Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

**Why Quebec Part III (not federal CNCA)?**
For a Quebec-only organization, Quebec Part III is the right choice:
single registration with the REQ gives you both incorporation and your NEQ
simultaneously, there is no dual registration cost, and Quebec civil law applies
directly. All ~197 FCMQ-member snowmobile clubs use this route.

---

## On Start: Read State File and Check Prerequisites

1. Read `qc-status.md`. If absent, tell the user:
   > "This skill is step 2 of a chain for Quebec legal entity registration:
   > 1. `/quebec-legal-entity:quebec-incorporation` — generic steps (name search, REQ)
   > 2. `/quebec-legal-entity:quebec-obnl` ← you are here (OBNL-specific incorporation)
   > 3. `/quebec-legal-entity:quebec-snowmobile-club` — snowmobile sector (FCMQ, MTQ/PACM)
   >
   > Start with `/quebec-legal-entity:quebec-incorporation` first — it creates the state
   > files and completes the name search (INC-01)."

2. Verify INC-01 is checked in `qc-incorporation.md`. If not, list it as a blocking step.

3. Read `qc-obnl.md`. If absent, create it from the template below.

4. Present current OBNL phase status and jump to first unchecked OBNL step.

**`qc-obnl.md` template (create if absent):**

```markdown
# OBNL Incorporation Status — [organization name]
schema_version: 1
NEQ: pending
B2_date: pending
D1_deadline: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] OBNL-01 — Founding members confirmed (min. 3)
- [ ] OBNL-02 — RE-303 drafted + sworn declaration notarized
- [ ] OBNL-03 — By-laws drafted (dissolution clause included)
- [ ] OBNL-04 — RE-303 filed with REQ
- [ ] OBNL-05 — Letters patent received + NEQ assigned
- [ ] OBNL-06 — Constitutive general assembly held
- [ ] OBNL-07 — Minute book set up
- [ ] OBNL-08 — AGA held (annual, next: [date])
- [ ] OBNL-09 — Financial statements prepared (annual, next: [date])
```

---

## NEVER / ALWAYS

### NEVER

- Suggest federal CNCA incorporation for a Quebec-only organization
- Skip the dissolution clause warning before drafting by-laws
- Mark OBNL-05 complete without recording the NEQ and B2_date in `qc-obnl.md`
- Suggest filing RE-303 online — paper submission (mail or in person) only as of 2025

### ALWAYS

- Warn about director personal liability before step OBNL-03
- Show the dissolution clause requirement before step OBNL-03
- After OBNL-05: calculate D1_deadline = B2_date + 60 calendar days and
  write it to `qc-obnl.md` and `qc-incorporation.md` immediately
- Surface the D1_deadline value explicitly to the user when OBNL-05 is completed

---

## Steps

For each step: explain what to do, list required documents/forms,
show cost and delay, then ask "Have you completed this step?" before checking it.

---

### OBNL-01 `[OBNL][PROV]` — Confirm founding members and mission

**What to do:**
Assemble at least 3 founding members (requérants fondateurs). Under Quebec Part III,
all founders must be natural persons (individuals), not corporations.

Define:

- The organization's legal name (in French or French-first)
- Mission and objectives (must be non-profit, non-commercial)
- Territory of operations
- Who will serve as initial directors (typically the 3 founders)

**Cost:** Free
**Delay:** 1–4 weeks (internal organization)

**After confirming completion:** Check `OBNL-01` in `qc-obnl.md`.

---

### ⚠️ CRITICAL WARNINGS — Show before OBNL-03 (by-laws drafting)

Display these warnings before the user begins drafting by-laws:

> **Director liability:** Quebec law holds directors jointly and severally liable
> for unremitted source deductions and tax obligations. Set up proper bookkeeping
> before your first revenue.
>
> **Dissolution clause (legally required):** Your by-laws MUST include a clause
> specifying that upon dissolution, remaining assets are transferred to another
> OBNL with similar objectives — NOT distributed to members. Omitting this clause
> can invalidate your non-profit status.
>
> **No charitable receipts:** As a 149(1)(l) NPO (not a registered charity),
> the organization cannot issue tax-deductible donation receipts. This is normal
> and expected for snowmobile clubs.
>
> **French language:** All government filings must be in French. The organization's
> name must be in French or French-first.

---

### OBNL-02 `[OBNL][PROV]` — Draft RE-303 and sworn declaration

**What to do:**
Complete Form RE-303 ("Demande de constitution en personne morale sans but lucratif").

**Available at:** registreentreprises.gouv.qc.ca → "Formulaires"

**Required fields:**

- Organization name (French required)
- Registered office address (must be in Quebec)
- Names and complete addresses of all 3+ founders
- Organization objectives/purposes — state clearly: non-profit, non-commercial,
  and describe the specific mission (e.g., "construction et entretien de sentiers
  de motoneige dans la région de...")
- Any restrictions on activities

**Sworn declaration (déclaration sous serment):**
One founder must sign a sworn declaration before:

- A commissioner of oaths (commissaire à l'assermentation) — available free or
  ~$5–10 at many city halls, REQ offices, and law offices
- Or a notary (~$50–100)

**Cost:** $0 (drafting) + $0–$100 (notarization)
**Delay:** 1–3 weeks to draft

**After confirming completion:** Check `OBNL-02` in `qc-obnl.md`.

---

### OBNL-03 `[OBNL][PROV]` — Draft by-laws (règlements administratifs)

**What to do:**
Draft the by-laws. These are NOT filed with the government but must be adopted
at the constitutive general assembly (OBNL-06).

**Required content:**

- Organization name and head office
- Mission and objectives
- Membership classes, admission criteria, dues structure
- Rights and obligations of members
- Board of directors: composition, election procedure, term lengths, removal
- Officers: president, secretary, treasurer
- Meeting procedures: quorum, notice periods, voting rules
- Fiscal year (e.g., April 1 – March 31 to align with FCMQ/PACM cycles)
- Signing authority for contracts and cheques
- **Dissolution clause (REQUIRED):** "Upon dissolution, remaining assets shall be
  transferred to an organization with similar non-profit objectives, as determined
  by the board of directors."
- Amendment procedure for by-laws

**Options:**

- DIY using a template (ESPACE OBNL: espacesobnl.ca has free templates)
- Lawyer-reviewed draft ($500–$2,000 — recommended for clubs expecting
  significant government funding)

**Cost:** $0 (DIY) / $500–$2,000 (lawyer)
**Delay:** 1–4 weeks

**After confirming completion:** Check `OBNL-03` in `qc-obnl.md`.

---

### OBNL-04 `[OBNL][PROV]` — File RE-303 with REQ

**What to do:**
Submit Form RE-303 and all required documents to the Registraire des entreprises.

**Submission method:** By mail or in person only (online submission not available
for Part III OBNLs as of 2025).

**Address:**

```text
Registraire des entreprises
787 boulevard Lebourgneuf, bureau 200
Québec (QC) G2J 0C4
```

**Required documents in the envelope:**

1. Completed and signed Form RE-303
2. Sworn declaration (déclaration sous serment) — original with wet signature
3. Proof of name search / name reservation confirmation
4. Payment (cheque payable to "Ministère des Finances du Québec")

**Fees:**

- Regular service: **$199.00**
- Priority service: **$298.50**

**Processing time:**

- Regular: ~10 business days after receipt
- Priority: ~5 business days after receipt

**After confirming submission:** Check `OBNL-04`. Note the submission date so you
can follow up if you do not receive letters patent within the expected window.

---

### OBNL-05 `[OBNL][PROV]` — Receive letters patent + NEQ

**What to do:**
Wait for the REQ to mail the letters patent (Lettres patentes) to your registered
address. The NEQ (10-digit Numéro d'entreprise du Québec) is assigned at the same time.

**The organization is legally constituted as of the date on the letters patent.**

**Immediately upon receiving:**

1. Record the NEQ in `qc-obnl.md` (replace "pending")
2. Record the B2_date (date on the letters patent)
3. Calculate D1_deadline = B2_date + 60 calendar days
4. Update `qc-obnl.md` with all three values
5. Update the INC-03 line in `qc-incorporation.md` with the D1_deadline

**Prompt the user explicitly** (surface all three values):

> "🎉 Your organization is legally incorporated! Record these values now:
>
> - NEQ: [the 10-digit number on your letters patent]
> - Date of letters patent (B2_date): [date on the document]
> - Initial REQ declaration deadline (D1_deadline): B2_date + 60 calendar days
>
> Update state files with these values, then continue with:
> `/quebec-legal-entity:quebec-incorporation` (steps INC-03 onward) — starting with
> the mandatory initial REQ declaration, due by D1_deadline.
> You will also need the letters patent to open your bank account and apply for
> FCMQ membership."

**After confirming receipt:** Check `OBNL-05` in `qc-obnl.md`.

---

### OBNL-06 `[OBNL][PROV]` — Hold constitutive general assembly

**What to do:**
Hold the constitutive general assembly (assemblée générale constitutive).
This must take place AFTER receiving letters patent.

**Mandatory agenda items:**

1. Adoption of by-laws (règlements administratifs)
2. Election of the board of directors
3. Appointment of officers (president, secretary, treasurer minimum)
4. Designation of authorized signatories for bank accounts and contracts
5. Adoption of fiscal year
6. Authorization to open bank accounts
7. Any other initial organizational decisions

**Quorum:** All 3+ founders must be present or represented by proxy.

**Record:** Formal minutes must be taken, signed by the secretary, and kept
in the minute book.

**Cost:** Free
**Delay:** Should be held within a few weeks of receiving letters patent

**After confirming completion:** Check `OBNL-06` in `qc-obnl.md`.

---

### OBNL-07 `[OBNL][PROV]` — Set up corporate minute book

**What to do:**
Create and maintain the corporate minute book (registre de l'organisme).
This is a legal obligation under the Quebec Companies Act.

**Required contents:**

- Original letters patent
- Current by-laws (and all future amendments)
- Minutes of all general assemblies and board meetings
- Register of directors (names, addresses, election and resignation dates)
- Register of members
- Copies of all government declarations

**Options:** A standard binder with dividers ($0) or a pre-formatted legal minute
book from a law stationer ($50–$200).

**Store:** At the registered office (or with a designated director).

**Cost:** $0–$200
**Delay:** Concurrent with or immediately after OBNL-06

**After confirming completion:** Check `OBNL-07` in `qc-obnl.md`.

---

### OBNL-08 `[OBNL][PROV]` — Annual general assembly (recurring)

**What to do:**
Hold the annual general assembly (AGA) — required by Quebec law at least once per year.

**Minimum notice:** 10 days to members (unless by-laws specify longer).

**Mandatory agenda:**

- Approval of financial statements
- Election/re-election of directors
- Approval of budget
- Other business

**Record:** Minutes must be recorded and filed in the minute book.

**Cost:** Free
**Delay:** Annual recurring obligation.

**After confirming completion:** Check `OBNL-08` and record next AGA date.

---

### OBNL-09 `[OBNL]` — Annual financial statements (recurring)

**What to do:**
Prepare annual financial statements: balance sheet (bilan) and income statement
(état des résultats).

These must be presented to members at the AGA and are required for:

- Tax return preparation (see `/quebec-legal-entity:quebec-income-tax`)
- Government funding applications (PACM)
- FCMQ annual reporting

**Cost:** $500–$3,000/year depending on complexity and whether you use a
bookkeeper, accountant, or CPA.

**After confirming completion:** Check `OBNL-09`.

---

## Completion

When all OBNL steps through OBNL-07 are checked, update `qc-status.md`:
`- [x] quebec-obnl — completed [YYYY-MM-DD]`

Then prompt:
"Your OBNL is legally incorporated and operational. Next steps:

1. Return to `/quebec-legal-entity:quebec-incorporation` to complete post-incorporation
   steps (INC-03 onward) — especially the initial REQ declaration (deadline: D1_deadline).
2. Set up tax filings with `/quebec-legal-entity:quebec-income-tax`.
3. If you are operating a snowmobile club, continue with:
   `/quebec-legal-entity:quebec-snowmobile-club`"

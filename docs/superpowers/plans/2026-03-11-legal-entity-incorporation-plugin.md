# legal-entity-incorporation Plugin Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the `legal-entity-incorporation` plugin with three interactive skills that guide a user through registering a Quebec OBNL (non-profit) and setting up a snowmobile club, tracking progress in a state file.

**Architecture:** Three skills in a dependency chain (`quebec-incorporation` → `quebec-obnl` → `snowmobile-club-qc`), each with a `SKILL.md` (activation metadata) and `instructions.md` (interactive workflow). Progress is persisted in an `obnl-status.md` file in the user's working directory.

**Tech Stack:** Markdown, YAML frontmatter, Claude Code plugin framework (SKILL.md + instructions.md pattern)

**Spec:** `docs/superpowers/specs/2026-03-11-legal-entity-incorporation-design.md`

---

## File Map

Files to create (all new):

```
legal-entity-incorporation/
├── .claude-plugin/
│   └── plugin.json                          ← plugin manifest
├── skills/
│   ├── quebec-incorporation/
│   │   ├── SKILL.md                         ← activation triggers + allowed-tools
│   │   └── instructions.md                  ← interactive step guide (generic steps)
│   ├── quebec-obnl/
│   │   ├── SKILL.md                         ← activation triggers + allowed-tools
│   │   └── instructions.md                  ← interactive step guide (OBNL steps)
│   └── snowmobile-club-qc/
│       ├── SKILL.md                         ← activation triggers + allowed-tools
│       └── instructions.md                  ← interactive step guide (sector steps)
└── README.md                                ← plugin documentation
```

---

## Chunk 1: Plugin Scaffold + Skill 1 (quebec-incorporation)

### Task 1: Create plugin directory structure and manifest

**Files:**
- Create: `legal-entity-incorporation/.claude-plugin/plugin.json`

- [ ] **Step 1: Create plugin.json**

```json
{
  "name": "legal-entity-incorporation",
  "version": "0.1.0",
  "description": "Interactive guides for incorporating a Quebec legal entity, OBNL non-profit, and snowmobile club operations"
}
```

Save to: `legal-entity-incorporation/.claude-plugin/plugin.json`

- [ ] **Step 2: Verify the file exists at the right path**

Run: `ls legal-entity-incorporation/.claude-plugin/`
Expected: `plugin.json`

- [ ] **Step 3: Commit**

```bash
git add legal-entity-incorporation/.claude-plugin/plugin.json
git commit -m "feat(legal-entity-incorporation): add plugin manifest"
```

---

### Task 2: Write README.md

**Files:**
- Create: `legal-entity-incorporation/README.md`

- [ ] **Step 1: Write README**

```markdown
# legal-entity-incorporation

Interactive Claude Code skills for registering legal entities in Quebec,
with specialization for OBNL non-profits and snowmobile clubs.

## Skills

### `/legal-entity-incorporation:quebec-incorporation`

Generic Quebec legal entity formation steps applicable to any organization type.
Covers: name search, initial REQ declaration, GST/QST, CRA BN, bank account,
annual REQ update.

**Tags:** `[GENERIC]` steps only.

### `/legal-entity-incorporation:quebec-obnl`

OBNL-specific incorporation under Quebec Companies Act Part III
(Loi sur les compagnies, Partie III).
Covers: RE-303 filing, letters patent, constitutive assembly, by-laws,
annual tax returns.

**Tags:** `[OBNL]` steps. Depends on `quebec-incorporation`.

### `/legal-entity-incorporation:snowmobile-club-qc`

Snowmobile sector operations for a Quebec club.
Covers: FCMQ membership, MTQ/PACM grants, VHR trail designation, insurance.

**Tags:** `[SECTOR-SPECIFIC]` steps. Depends on `quebec-obnl`.

## Progress Tracking

All three skills read and write `obnl-status.md` in your working directory.
This file tracks completed steps across sessions.

## Cost Estimates (2025)

| Stage | Minimum | Recommended |
|-------|---------|-------------|
| Startup | ~$200–$250 | ~$800–$2,500 |
| Annual | ~$540/year | ~$2,500–$5,500/year |

## Step Tags

| Tag | Meaning |
|-----|---------|
| `[GENERIC]` | Any Quebec legal entity |
| `[OBNL]` | Non-profit organizations only |
| `[SECTOR-SPECIFIC]` | Snowmobile clubs only |
| `[PROV]` | Provincial (REQ / Revenu Québec) |
| `[FED]` | Federal (CRA) |
```

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/README.md
git commit -m "feat(legal-entity-incorporation): add README"
```

---

### Task 3: Write SKILL.md for quebec-incorporation

**Files:**
- Create: `legal-entity-incorporation/skills/quebec-incorporation/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

```markdown
---
name: quebec-incorporation
description: |
  Interactive step-by-step guide for generic Quebec legal entity formation.
  Applicable to any organization type (for-profit or non-profit).
  Reads and writes obnl-status.md in the working directory to track progress.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:quebec-incorporation
  - User asks to start registering a Quebec business, organization, or legal entity
  - User needs to do a name search at the REQ
  - User is beginning the Quebec incorporation process

  DO NOT activate when:
  - User is specifically asking about OBNL/non-profit steps (use quebec-obnl)
  - User is asking about federal incorporation via Corporations Canada / CNCA
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---
```

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/skills/quebec-incorporation/SKILL.md
git commit -m "feat(legal-entity-incorporation): add quebec-incorporation SKILL.md"
```

---

### Task 4: Write instructions.md for quebec-incorporation

**Files:**
- Create: `legal-entity-incorporation/skills/quebec-incorporation/instructions.md`

- [ ] **Step 1: Write instructions.md**

````markdown
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

```markdown
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
```

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

**URL:** https://www.registreentreprises.gouv.qc.ca (public search, no login needed)

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

```
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
````

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/skills/quebec-incorporation/instructions.md
git commit -m "feat(legal-entity-incorporation): add quebec-incorporation instructions"
```

---

## Chunk 2: Skill 2 (quebec-obnl)

### Task 5: Write SKILL.md for quebec-obnl

**Files:**
- Create: `legal-entity-incorporation/skills/quebec-obnl/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

```markdown
---
name: quebec-obnl
description: |
  Interactive step-by-step guide for incorporating a Quebec non-profit (OBNL)
  under the Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

  Reads and writes obnl-status.md to track progress across sessions.
  Requires the name search step from quebec-incorporation to be complete.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:quebec-obnl
  - User is specifically registering a Quebec non-profit / OBNL / organisme
    sans but lucratif
  - User needs to file Form RE-303 with the Registraire des entreprises

  DO NOT activate when:
  - User wants generic Quebec entity registration only (use quebec-incorporation)
  - User wants federal non-profit via Corporations Canada / CNCA
  - User is asking only about snowmobile sector steps (use snowmobile-club-qc)
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---
```

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/skills/quebec-obnl/SKILL.md
git commit -m "feat(legal-entity-incorporation): add quebec-obnl SKILL.md"
```

---

### Task 6: Write instructions.md for quebec-obnl

**Files:**
- Create: `legal-entity-incorporation/skills/quebec-obnl/instructions.md`

- [ ] **Step 1: Write instructions.md**

````markdown
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

1. Read `obnl-status.md`. If absent, tell the user:
   > "This skill is step 2 of a 3-skill chain for Quebec legal entity registration:
   > 1. `/legal-entity-incorporation:quebec-incorporation` — generic steps (name search, REQ, bank account)
   > 2. `/legal-entity-incorporation:quebec-obnl` ← you are here (OBNL-specific incorporation)
   > 3. `/legal-entity-incorporation:snowmobile-club-qc` — snowmobile sector (FCMQ, MTQ/PACM)
   >
   > Start with `/legal-entity-incorporation:quebec-incorporation` first — it creates the state file
   > and completes the name search (S1-01)."

2. Verify S1-01 (name search) is checked. If not, list it as a blocking step.

3. Present current OBNL phase status and jump to first unchecked S2-xx step.

---

## NEVER / ALWAYS

### NEVER
- Suggest federal CNCA incorporation for a Quebec-only organization
- Skip the dissolution clause warning before drafting by-laws
- Mark B2 complete without recording the NEQ and B2_date in the state file

### ALWAYS
- Warn about director personal liability before step S2-03
- Show the dissolution clause requirement before step S2-03
- After S2-05: calculate D1_deadline = B2_date + 60 calendar days and
  write it to obnl-status.md immediately

---

## Steps

For each step: explain what to do, list required documents/forms,
show cost and delay, then ask "Have you completed this step?" before checking it.

---

### S2-01 `[OBNL][PROV]` — Confirm founding members and mission

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

**After confirming completion:** Check `S2-01` in `obnl-status.md`.

---

### ⚠️ CRITICAL WARNINGS — Read before S2-03 (by-laws drafting)

Show these warnings before proceeding:

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

### S2-02 `[OBNL][PROV]` — Draft RE-303 and sworn declaration

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

**After confirming completion:** Check `S2-02` in `obnl-status.md`.

---

### S2-03 `[OBNL][PROV]` — Draft by-laws (règlements administratifs)

**What to do:**
Draft the by-laws. These are NOT filed with the government but must be adopted
at the constitutive general assembly (S2-06).

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

**After confirming completion:** Check `S2-03` in `obnl-status.md`.

---

### S2-04 `[OBNL][PROV]` — File RE-303 with REQ

**What to do:**
Submit Form RE-303 and all required documents to the Registraire des entreprises.

**Submission method:** By mail or in person only (online submission not available
for Part III OBNLs as of 2025).

**Address:**
```
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

**After confirming submission:** Check `S2-04`. Note the submission date so you
can follow up if you do not receive letters patent within the expected window.

---

### S2-05 `[OBNL][PROV]` — Receive letters patent + NEQ

**What to do:**
Wait for the REQ to mail the letters patent (Lettres patentes) to your registered
address. The NEQ (10-digit Numéro d'entreprise du Québec) is assigned at the same time.

**The organization is legally constituted as of the date on the letters patent.**

**Immediately upon receiving:**
1. Record the NEQ in `obnl-status.md` (replace "pending")
2. Record the B2_date (date on the letters patent)
3. Calculate D1_deadline = B2_date + 60 calendar days
4. Update `obnl-status.md` with all three values

**Prompt the user explicitly** (surface all three values):
> "🎉 Your organization is legally incorporated! Record these values now:
> - NEQ: [the 10-digit number on your letters patent]
> - Date of letters patent (B2_date): [date on the document]
> - Initial REQ declaration deadline (D1_deadline): B2_date + 60 calendar days
>
> Update obnl-status.md with these values, then continue with:
> `/legal-entity-incorporation:quebec-incorporation` (steps S1-03 onward) — starting with
> the mandatory initial REQ declaration, due by D1_deadline.
> You will also need the letters patent to open your bank account and apply for FCMQ membership."

**After confirming receipt:** Check `S2-05` in `obnl-status.md`.

---

### S2-06 `[OBNL][PROV]` — Hold constitutive general assembly

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

**After confirming completion:** Check `S2-06` in `obnl-status.md`.

---

### S2-07 `[OBNL][PROV]` — Set up corporate minute book

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
**Delay:** Concurrent with or immediately after S2-06

**After confirming completion:** Check `S2-07` in `obnl-status.md`.

---

### S2-08 `[OBNL][PROV]` — Annual CO-17.SP (recurring)

**What to do:**
File form CO-17.SP ("Déclaration de revenus des organismes sans but lucratif")
with Revenu Québec annually.

Most OBNLs are exempt from Quebec corporate income tax under section 998 of the
Taxation Act, but the return must still be filed.

**Due:** Within 6 months of fiscal year-end.

**Cost:** Free to file; $500–$2,000/year for bookkeeper/accountant fees.
**Delay:** Annual recurring obligation.

**First due date:** 6 months after the end of your first fiscal year.
Record this date in `obnl-status.md`.

**After confirming completion:** Check `S2-08` and update next due date.

---

### S2-09 `[OBNL][FED]` — Annual T2 + T1044 (recurring)

**What to do:**
File the federal T2 corporate income tax return with CRA.
Claim exemption under ITA paragraph 149(1)(l) (NPO for social welfare,
civic improvement, pleasure, or recreation — not profit).

Also file **T1044 NPO Information Return** if:
- Total assets exceeded $200,000 at the end of the previous year, OR
- Total revenues exceeded $100,000 in the year

**Due:** Within 6 months of fiscal year-end.

**Cost:** Free to file; included in annual accounting fees.
**Delay:** Annual recurring obligation.

**After confirming completion:** Check `S2-09` and update next due date.

---

### S2-10 `[OBNL][PROV]` — Annual general assembly (recurring)

**What to do:**
Hold the annual general assembly (AGA) — required by Quebec law at least once
per year.

**Minimum notice:** 10 days to members (unless by-laws specify longer).

**Mandatory agenda:**
- Approval of financial statements
- Election/re-election of directors
- Approval of budget
- Other business

**Record:** Minutes must be recorded and filed in the minute book.

**Cost:** Free
**Delay:** Annual recurring obligation.

**After confirming completion:** Check `S2-10` and record next AGA date.

---

### S2-11 `[OBNL]` — Annual financial statements (recurring)

**What to do:**
Prepare annual financial statements: balance sheet (bilan) and income statement
(état des résultats).

These must be presented to members at the AGA and are required for:
- Tax return preparation (S2-08, S2-09)
- Government funding applications (PACM)
- FCMQ annual reporting

**Cost:** $500–$3,000/year depending on complexity and whether you use a
bookkeeper, accountant, or CPA.

**After confirming completion:** Check `S2-11`.

---

### S2-12 `[OBNL][PROV][FED]` — Annual tax returns (recurring)

File CO-17.SP (S2-08) and T2/T1044 (S2-09). This step confirms both are done.

**After confirming completion:** Check `S2-12`.

---

## Completion

When all S2 steps through S2-07 are checked, prompt:
"Your OBNL is legally incorporated and operational. Don't forget to complete
the post-incorporation steps in `/legal-entity-incorporation:quebec-incorporation`
(S1-03 through S1-07; S1-08 annual update becomes relevant after year one).

If you are operating a snowmobile club, continue with:
`/legal-entity-incorporation:snowmobile-club-qc`"
````

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/skills/quebec-obnl/instructions.md
git commit -m "feat(legal-entity-incorporation): add quebec-obnl instructions"
```

---

## Chunk 3: Skill 3 (snowmobile-club-qc)

### Task 7: Write SKILL.md for snowmobile-club-qc

**Files:**
- Create: `legal-entity-incorporation/skills/snowmobile-club-qc/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

```markdown
---
name: snowmobile-club-qc
description: |
  Interactive step-by-step guide for snowmobile-sector-specific steps after a
  Quebec OBNL has been incorporated: FCMQ membership, MTQ/PACM grants,
  VHR Act trail designation, and insurance.

  Reads and writes obnl-status.md to track progress.
  Requires letters patent and constitutive assembly (Skill 2 steps S2-05, S2-06).

  ONLY activate when:
  - User invokes /legal-entity-incorporation:snowmobile-club-qc
  - User is operating a Quebec snowmobile club and has completed OBNL incorporation
  - User asks about FCMQ membership, MTQ/PACM grants, or VHR trail designation

  DO NOT activate when:
  - User has not yet incorporated their OBNL (use quebec-obnl first)
  - User is asking about generic incorporation (use quebec-incorporation)
  - User is asking about other trail organizations (ATV, cycling, hiking — this
    skill is specific to snowmobile clubs affiliated with FCMQ)
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---
```

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/skills/snowmobile-club-qc/SKILL.md
git commit -m "feat(legal-entity-incorporation): add snowmobile-club-qc SKILL.md"
```

---

### Task 8: Write instructions.md for snowmobile-club-qc

**Files:**
- Create: `legal-entity-incorporation/skills/snowmobile-club-qc/instructions.md`

- [ ] **Step 1: Write instructions.md**

````markdown
# Quebec Snowmobile Club — Sector-Specific Operations

This skill guides you through sector-specific steps for a Quebec snowmobile club
after your OBNL has been incorporated (letters patent received, constitutive
assembly held).

---

## On Start: Read State File and Check Prerequisites

1. Read `obnl-status.md`. If absent, tell the user:
   > "Start with `/legal-entity-incorporation:quebec-incorporation` first."

2. Verify these prerequisite steps are checked:
   - S2-05 (letters patent + NEQ received)
   - S2-06 (constitutive general assembly held)

   If either is missing, list the blocking steps and stop.

3. Verify the NEQ field in `obnl-status.md` is populated (not "pending"). If still
   "pending", tell the user: "Your NEQ number is needed to apply for FCMQ membership.
   Update the NEQ field in obnl-status.md with the 10-digit number from your letters
   patent before continuing."

4. **PACM calendar alert:** Check the current date against the MTQ/PACM
   application window (June 1 – August 31 of each year):
   - If currently in the window: "⚠️ The MTQ/PACM application window is OPEN
     (June–August). Complete FCMQ membership (S3-01/S3-02) immediately to be
     eligible to apply this cycle."
   - If outside the window: "ℹ️ The next MTQ/PACM application window opens in
     June. You have time to complete FCMQ membership before then."

5. Present current S3-xx status and jump to first unchecked step.

---

## NEVER / ALWAYS

### NEVER
- Suggest the club can issue charitable tax receipts (it cannot — 149(1)(l) NPO)
- Skip the PACM calendar warning at skill start
- Mark E4 (trail designation) complete before the user confirms MTQ approval

### ALWAYS
- Remind the user that FCMQ contact should happen early — board meeting
  schedule affects the admission timeline
- Warn that missing the June–August PACM window means waiting a full year
- Confirm the user has their NEQ before starting S3-01

---

## Steps

---

### S3-01 `[SECTOR-SPECIFIC]` — Apply for FCMQ membership

**What to do:**
Submit a membership application to the Fédération des clubs de motoneigistes
du Québec (FCMQ).

**Contact FCMQ early** — admission requires a board decision, and board meetings
follow a schedule. The earlier you apply, the sooner you can access funding.

**Contact:**
- Email: info@fcmq.qc.ca
- Phone: 418-847-0898
- Website: fcmq.qc.ca

**Admission conditions:**
- Must be a legally constituted OBNL (letters patent required)
- Must operate or intend to operate a snowmobile trail network
- Application submitted to and approved by the FCMQ board of directors

**What membership gives you:**
- Access to the 30,000+ km FCMQ trail network
- Eligibility for MTQ/PACM financial assistance (Volet 1 + Volet 2)
- Group civil liability insurance ($1,000,000)
- Technical support, grooming equipment programs, signage standards
- Regional assembly participation (2–4 votes depending on club size)
- Droits d'accès revenue distribution system

**Cost:** Annual membership fee (confirm exact amount with FCMQ)
**Delay:** Application immediate; board approval weeks to months

**After confirming submission:** Check `S3-01` in `obnl-status.md`.

---

### S3-02 `[SECTOR-SPECIFIC]` — FCMQ membership approved

**What to do:**
Wait for FCMQ board approval of the membership application.

Follow up with FCMQ if you have not heard back within the expected timeframe
given their next board meeting date.

**Cost:** Included in S3-01
**Delay:** Depends on FCMQ board meeting schedule

**After confirming approval:** Check `S3-02` in `obnl-status.md`.

---

### S3-03 `[SECTOR-SPECIFIC]` — Apply for MTQ/PACM financial assistance

**What to do:**
Apply for the Programme d'aide financière aux clubs de motoneigistes du Québec
(PACM), administered by the Ministère des Transports du Québec (MTQ).

**⚠️ CRITICAL: Application window is June 1 – August 31 annually.**
Missing this window means waiting a full year for the next funding cycle.
Current program runs through March 31, 2027.

**Two funding components:**

**Volet 1 — Trail maintenance (entretien des sentiers):**
- Largest funding component
- Apply directly to MTQ during the annual call for projects
- Amount distributed based on trail kilometers, maintenance costs, regional factors
- Example: ~$545,000 distributed to Abitibi-Témiscamingue clubs in one cycle

**Volet 2 — Safety and club support (sécurité et soutien):**
- Administered through FCMQ
- Contact FCMQ directly for this component

**Eligibility:**
- Must be an active FCMQ member (S3-02 must be complete)
- Demonstrated snowmobile trail maintenance mission
- Must submit within the call-for-projects period

**Cost:** Free to apply
**Delay:** Annual application; funding allocated by fiscal year

**After confirming submission:** Check `S3-03` in `obnl-status.md` and record
the application year (E2_next_window).

---

### S3-04 `[SECTOR-SPECIFIC]` — Obtain liability insurance

**What to do:**
Ensure adequate insurance coverage for the club and its activities.

**FCMQ base coverage (included with membership):**
- $1,000,000 civil liability for the club and its activities
- Covers: trail maintenance operations, club events, member activities on trails

**Additional coverage recommended:**
- Directors and officers (D&O) liability — protects board members personally
- Property insurance for any equipment owned (snowgroomers, tools)
- Event insurance for organized races or public events

**Contact FCMQ's group insurer for member rates:**
- La Capitale / Intact (FCMQ preferred insurer — confirm current insurer with FCMQ)
- Expected range: $1,500–$4,000/year for D&O + equipment coverage on top of
  FCMQ base

**Cost:** $1,500–$4,000/year estimated for supplemental coverage
**Delay:** Concurrent with FCMQ membership process

**After confirming completion:** Check `S3-04` in `obnl-status.md`.

---

### S3-05 `[SECTOR-SPECIFIC]` — VHR Act trail designation (Loi sur les VHR)

**What to do:**
Obtain official trail network designation from the Ministère des Transports du
Québec under the Quebec Off-Highway Vehicles Act (Loi sur les véhicules hors route).

**Why this matters:** Trail designation is required to legally issue droits d'accès
(trail access fees/passes) to snowmobilers. Without designation, you cannot legally
collect trail access revenue.

**Process:**
- Work with your FCMQ regional representative — FCMQ assists clubs through this
  process
- Submit trail network map and documentation to MTQ
- MTQ reviews and approves the designated trail network

**Cost:** Variable (confirm with MTQ / FCMQ)
**Delay:** Variable — coordinate timing with FCMQ representative

**After confirming designation:** Check `S3-05` in `obnl-status.md`.

---

### S3-06 `[SECTOR-SPECIFIC]` — Annual FCMQ renewal and reporting (recurring)

**What to do:**
Renew FCMQ membership annually and fulfill annual reporting obligations.

**Annual obligations:**
- Renew membership with FCMQ (before the deadline they specify)
- Submit trail maintenance reports and activity statistics
- Provide financial data as required by FCMQ
- Participate in regional assemblies (2–4 votes depending on club size)
- Renew insurance coverage

**Cost:** Annual FCMQ membership fee + insurance renewal
**Delay:** Annual recurring obligation

**After confirming completion:** Check `S3-06` and record next renewal date.

---

## Completion

When all S3 steps are checked, prompt:
"Your snowmobile club is now fully operational! Here's a summary of your ongoing
annual obligations:

**Provincial:**
- S1-08: REQ annual update declaration ($41)
- S2-08: CO-17.SP tax return (Revenu Québec)
- S2-10: Annual general assembly
- S3-06: FCMQ renewal + PACM application (June–August window)

**Federal:**
- S2-09: T2 + T1044 (CRA)

**Tip:** Set calendar reminders for the June PACM window and your REQ update
notice — these are the two easiest obligations to miss."
````

- [ ] **Step 2: Commit**

```bash
git add legal-entity-incorporation/skills/snowmobile-club-qc/instructions.md
git commit -m "feat(legal-entity-incorporation): add snowmobile-club-qc instructions"
```

---

## Chunk 4: Validation and Final Commit

### Task 9: Validate plugin structure

- [ ] **Step 1: Run plugin validator**

Use the `plugin-dev:plugin-validator` agent to check the plugin structure:

```
Validate the plugin at: legal-entity-incorporation/
```

Expected: All skill files found, plugin.json valid, SKILL.md frontmatter correct
in all 3 skills.

- [ ] **Step 2: Fix any issues reported by the validator**

Address each issue before proceeding.

- [ ] **Step 3: Verify directory structure matches spec**

```bash
find legal-entity-incorporation/ -type f | sort
```

Expected output:
```
legal-entity-incorporation/.claude-plugin/plugin.json
legal-entity-incorporation/README.md
legal-entity-incorporation/skills/quebec-incorporation/SKILL.md
legal-entity-incorporation/skills/quebec-incorporation/instructions.md
legal-entity-incorporation/skills/quebec-obnl/SKILL.md
legal-entity-incorporation/skills/quebec-obnl/instructions.md
legal-entity-incorporation/skills/snowmobile-club-qc/SKILL.md
legal-entity-incorporation/skills/snowmobile-club-qc/instructions.md
```

- [ ] **Step 4: Verify SKILL.md frontmatter in all 3 skills**

Check that each SKILL.md has:
- `name:` field
- `description:` with ONLY/DO NOT activate conditions
- `allowed-tools:` including `Write(obnl-status.md)` and `Edit(obnl-status.md)`

- [ ] **Step 5: Final commit**

```bash
git add legal-entity-incorporation/
git commit -m "feat: add legal-entity-incorporation plugin with 3 skills

- quebec-incorporation: generic Quebec legal entity steps (S1-01 to S1-08)
- quebec-obnl: OBNL-specific Part III incorporation (S2-01 to S2-12)
- snowmobile-club-qc: FCMQ/MTQ/VHR sector steps (S3-01 to S3-06)

Each skill tracks progress in obnl-status.md with dependency chain.
Based on 2025 REQ/CRA fee schedules and FCMQ/MTQ program data."
```

---

## Verification

After implementation, verify end-to-end behavior:

1. **Invoke `quebec-incorporation`** — Claude should:
   - Create `obnl-status.md` with all checkboxes unchecked
   - Ask for organization name
   - Start at S1-01 (name search)
   - Show the post-incorporation gate before S1-03

2. **Invoke `quebec-obnl` without S1-01 checked** — Claude should:
   - Show the 3-skill chain onboarding message
   - Block with "complete S1-01 first" and stop

2b. **Invoke `quebec-obnl` with S1-01 checked and some S2 steps done** — Claude should:
   - Skip to first unchecked S2 step (resumption)

3. **Invoke `snowmobile-club-qc` without S2-05 checked** — Claude should:
   - Block with a clear message listing S2-05 and S2-06 as prerequisites

4. **Invoke `snowmobile-club-qc` with S2-05 and S2-06 checked** — Claude should:
   - Display PACM calendar alert
   - Start at S3-01 (FCMQ membership)

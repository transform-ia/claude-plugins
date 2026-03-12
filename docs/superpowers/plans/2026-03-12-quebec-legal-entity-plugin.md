# Quebec Legal Entity Plugin Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `legal-entity-incorporation/` with a new `quebec-legal-entity/` plugin containing 8 skills covering the full Quebec entity lifecycle.

**Architecture:** Each skill is a pair of markdown files (SKILL.md + instructions.md) in its own subdirectory. Three skills are migrated from the old plugin with updated step IDs and state file names; five are written from scratch. All skills share a master `qc-status.md` overview file plus per-skill detail files in the user's working directory.

**Tech Stack:** Markdown files, `npx markdownlint-cli2` for validation, plugin-validator agent for final check.

**Spec:** `docs/superpowers/specs/2026-03-11-quebec-legal-entity-plugin-design.md`

**Reference (old plugin — do not delete until Task 10):** `legal-entity-incorporation/`

---

## Chunk 1: Plugin scaffold + migrated skills

### Task 1: Plugin scaffold

**Files:**

- Create: `quebec-legal-entity/.claude-plugin/plugin.json`
- Create: `quebec-legal-entity/README.md`

- [ ] **Step 1: Create plugin.json**

```json
{
  "name": "quebec-legal-entity",
  "version": "0.1.0",
  "description": "Interactive guides for incorporating and operating a Quebec legal entity: OBNL non-profit, GST/QST, payroll, income tax, insurance, and accounting"
}
```

- [ ] **Step 2: Create README.md**

````markdown
# Quebec Legal Entity Plugin

Interactive step-by-step guides for the full lifecycle of a Quebec legal entity —
from name search through ongoing compliance obligations. Each skill reads and writes
state files in the working directory to persist progress across sessions.

## Skills

### `/quebec-legal-entity:quebec-incorporation`

**Purpose:** Generic Quebec legal entity formation guide, applicable to any organization
type (for-profit or non-profit). Walks through name search at the Registre des
entreprises du Québec (REQ), initial registration, and post-incorporation steps.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-status.md` (master overview), `qc-incorporation.md` (step detail)

---

### `/quebec-legal-entity:quebec-obnl`

**Purpose:** Quebec OBNL (Organisme à but non lucratif) non-profit registration guide.
Covers letters patent via RE-303, by-laws, board structure, and annual obligations.

**Tags used:** `[OBNL]`, `[PROV]`, `[FED]`

**Creates:** `qc-obnl.md`

**Depends on:** `quebec-incorporation` (INC-01 must be complete)

---

### `/quebec-legal-entity:quebec-snowmobile-club`

**Purpose:** Snowmobile club operations guide for Quebec clubs affiliated with the
Fédération des clubs de motoneigistes du Québec (FCMQ). Covers FCMQ membership,
MTQ/PACM grants, VHR trail designation, and insurance.

**Tags used:** `[SECTOR-SPECIFIC]`

**Creates:** `qc-snowmobile-club.md`

**Depends on:** `quebec-obnl` (OBNL-05 + OBNL-06 must be complete)

---

### `/quebec-legal-entity:quebec-gst-qst`

**Purpose:** GST/QST registration and ongoing return filing guide. Covers mandatory
and voluntary registration, filing frequency selection, ITC/RTI tracking, and
instalment obligations.

**Tags used:** `[GENERIC]`, `[PROV]`, `[FED]`

**Creates:** `qc-gst-qst.md`

---

### `/quebec-legal-entity:quebec-payroll`

**Purpose:** Payroll setup and compliance guide. Covers source deduction registration,
DAS remittance schedule, first payroll run, year-end T4/RL-1 filing, and vacation pay.
Marks itself N/A if the entity has no employees.

**Tags used:** `[GENERIC]`, `[PROV]`, `[FED]`

**Creates:** `qc-payroll.md`

---

### `/quebec-legal-entity:quebec-income-tax`

**Purpose:** Corporate income tax guide. Branches on entity type: T2 for for-profit
corporations, CO-17.SP + T2 + T1044 for OBNLs. Covers fiscal year-end, instalments,
and annual filing deadlines.

**Tags used:** `[GENERIC]`, `[PROV]`, `[FED]` (for-profit) or `[OBNL]`, `[PROV]`, `[FED]` (OBNL)

**Creates:** `qc-income-tax.md`

---

### `/quebec-legal-entity:quebec-insurance`

**Purpose:** Advisory insurance coverage guide. Walks through coverage types
(general liability, D&O, property, E&O, event) and records decisions in a coverage log.

**Tags used:** `[GENERIC]`

**Creates:** `qc-insurance.md`

---

### `/quebec-legal-entity:quebec-accounting`

**Purpose:** Advisory accounting setup guide. Covers fiscal year-end choice, software
selection, chart of accounts, bookkeeper vs CPA, and record retention. Run once at
entity formation.

**Tags used:** `[GENERIC]`

**Creates:** `qc-accounting.md`

---

## Progress Tracking

All skills read `qc-status.md` for a master overview, plus their own per-skill file
for step-level detail. Both files are created in the current working directory on first
run and are safe to commit alongside your organization's documents.

---

## Step Tags

| Tag | Meaning |
| --- | --- |
| `[GENERIC]` | Applies to any Quebec legal entity |
| `[OBNL]` | Applies to non-profits only |
| `[SECTOR-SPECIFIC]` | Applies to snowmobile clubs only |
| `[PROV]` | Provincial requirement (REQ / Revenu Québec) |
| `[FED]` | Federal requirement (CRA / Corporations Canada) |

---

## Cost Estimates

| Phase | Minimum | Recommended |
| --- | --- | --- |
| Startup (one-time) | ~$200–$250 | ~$800–$2,500 |
| Annual (ongoing) | ~$540/year | ~$2,500–$5,500/year |
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/README.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/.claude-plugin/plugin.json quebec-legal-entity/README.md
git commit -m "feat(quebec-legal-entity): add plugin scaffold (plugin.json + README)"
```

---

### Task 2: Migrate `quebec-incorporation` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-incorporation/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-incorporation/instructions.md`
- Reference: `legal-entity-incorporation/skills/quebec-incorporation/` (existing)

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-incorporation
description: |
  Interactive step-by-step guide for generic Quebec legal entity formation.
  Applicable to any organization type (for-profit or non-profit).

  Creates qc-status.md (master overview) and qc-incorporation.md (step detail)
  in the working directory on first run. Detects and rejects legacy obnl-status.md.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-incorporation
  - User asks to start registering a Quebec business, organization, or legal entity
  - User needs to do a name search at the REQ
  - User is beginning the Quebec incorporation process

  DO NOT activate when:
  - User is specifically asking about OBNL/non-profit steps (use quebec-obnl)
  - User is asking about federal incorporation via Corporations Canada / CNCA
  - User is asking about snowmobile club sector steps (use quebec-snowmobile-club)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-incorporation.md), Edit(qc-incorporation.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
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

```markdown
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
```

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
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-incorporation/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-incorporation/
git commit -m "feat(quebec-legal-entity): add quebec-incorporation skill (migrated from legal-entity-incorporation)"
```

---

### Task 3: Migrate `quebec-obnl` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-obnl/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-obnl/instructions.md`
- Reference: `legal-entity-incorporation/skills/quebec-obnl/` (existing)

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-obnl
description: |
  Interactive step-by-step guide for incorporating a Quebec non-profit (OBNL)
  under the Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

  Reads and writes qc-obnl.md to track progress across sessions.
  Requires the name search step from quebec-incorporation to be complete (INC-01).

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-obnl
  - User is specifically registering a Quebec non-profit / OBNL / organisme
    sans but lucratif
  - User needs to file Form RE-303 with the Registraire des entreprises

  DO NOT activate when:
  - User wants generic Quebec entity registration only (use quebec-incorporation)
  - User wants federal non-profit via Corporations Canada / CNCA
  - User is asking only about snowmobile sector steps (use quebec-snowmobile-club)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-obnl.md), Edit(qc-obnl.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

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
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-obnl/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-obnl/
git commit -m "feat(quebec-legal-entity): add quebec-obnl skill (migrated, OBNL-xx step IDs, tax steps removed)"
```

---

### Task 4: Migrate `quebec-snowmobile-club` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-snowmobile-club/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-snowmobile-club/instructions.md`
- Reference: `legal-entity-incorporation/skills/snowmobile-club-qc/` (old directory name)

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-snowmobile-club
description: |
  Interactive step-by-step guide for snowmobile-sector-specific steps after a
  Quebec OBNL has been incorporated: FCMQ membership, MTQ/PACM grants,
  VHR Act trail designation, and insurance.

  Reads and writes qc-snowmobile-club.md to track progress.
  Requires letters patent and constitutive assembly (OBNL-05 + OBNL-06).

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-snowmobile-club
  - User is operating a Quebec snowmobile club and has completed OBNL incorporation
  - User asks about FCMQ membership, MTQ/PACM grants, or VHR trail designation

  DO NOT activate when:
  - User has not yet incorporated their OBNL (use quebec-obnl first)
  - User is asking about generic incorporation (use quebec-incorporation)
  - User is asking about other trail organizations (ATV, cycling, hiking — this
    skill is specific to snowmobile clubs affiliated with FCMQ)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-snowmobile-club.md), Edit(qc-snowmobile-club.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
# Quebec Snowmobile Club — Sector-Specific Operations

This skill guides you through sector-specific steps for a Quebec snowmobile club
after your OBNL has been incorporated (letters patent received, constitutive
assembly held).

---

## On Start: Read State File and Check Prerequisites

1. Read `qc-status.md`. If absent, tell the user:
   > "Start with `/quebec-legal-entity:quebec-incorporation` first."

2. Verify these prerequisite steps are checked in `qc-obnl.md`:
   - OBNL-05 (letters patent + NEQ received)
   - OBNL-06 (constitutive general assembly held)

   If either is missing, list the blocking steps and stop.

3. Verify the NEQ field in `qc-obnl.md` is populated (not "pending"). If still
   "pending", tell the user: "Your NEQ number is needed to apply for FCMQ membership.
   Update the NEQ field in qc-obnl.md with the 10-digit number from your letters
   patent before continuing."

4. Read `qc-snowmobile-club.md`. If absent, create it from the template below.

5. **PACM calendar alert:** Check the current date against the MTQ/PACM
   application window (June 1 – August 31 of each year):
   - If currently in the window: "⚠️ The MTQ/PACM application window is OPEN
     (June–August). Complete FCMQ membership (SNOW-01/SNOW-02) immediately to be
     eligible to apply this cycle."
   - If outside the window: "ℹ️ The next MTQ/PACM application window opens in
     June. You have time to complete FCMQ membership before then."

6. Present current SNOW status and jump to first unchecked step.

**`qc-snowmobile-club.md` template (create if absent):**

```markdown
# Snowmobile Club Status — [organization name]
schema_version: 1
E2_next_window: [Year] June–August
Last updated: YYYY-MM-DD

## Steps
- [ ] SNOW-01 — FCMQ application submitted
- [ ] SNOW-02 — FCMQ membership approved (board decision)
- [ ] SNOW-03 — MTQ/PACM application submitted (window: E2_next_window)
- [ ] SNOW-04 — Insurance obtained (FCMQ base + additional)
- [ ] SNOW-05 — VHR trail designation obtained from MTQ
- [ ] SNOW-06 — FCMQ annual renewal (next: [date])
```

---

## NEVER / ALWAYS

### NEVER

- Suggest the club can issue charitable tax receipts (it cannot — 149(1)(l) NPO)
- Skip the PACM calendar warning at skill start
- Mark SNOW-05 (trail designation) complete before the user confirms MTQ approval

### ALWAYS

- Remind the user that FCMQ contact should happen early — board meeting
  schedule affects the admission timeline
- Warn that missing the June–August PACM window means waiting a full year
- Confirm the user has their NEQ before starting SNOW-01

---

## Steps

---

### SNOW-01 `[SECTOR-SPECIFIC]` — Apply for FCMQ membership

**What to do:**
Submit a membership application to the Fédération des clubs de motoneigistes
du Québec (FCMQ).

**Contact FCMQ early** — admission requires a board decision, and board meetings
follow a schedule. The earlier you apply, the sooner you can access funding.

**Contact:**

- Email: <info@fcmq.qc.ca>
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

**After confirming submission:** Check `SNOW-01` in `qc-snowmobile-club.md`.

---

### SNOW-02 `[SECTOR-SPECIFIC]` — FCMQ membership approved

**What to do:**
Wait for FCMQ board approval of the membership application.

Follow up with FCMQ if you have not heard back within the expected timeframe
given their next board meeting date.

**Cost:** Included in SNOW-01
**Delay:** Depends on FCMQ board meeting schedule

**After confirming approval:** Check `SNOW-02` in `qc-snowmobile-club.md`.

---

### SNOW-03 `[SECTOR-SPECIFIC]` — Apply for MTQ/PACM financial assistance

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

- Must be an active FCMQ member (SNOW-02 must be complete)
- Demonstrated snowmobile trail maintenance mission
- Must submit within the call-for-projects period

**Cost:** Free to apply
**Delay:** Annual application; funding allocated by fiscal year

**After confirming submission:** Check `SNOW-03` in `qc-snowmobile-club.md` and
record the application year (E2_next_window).

---

### SNOW-04 `[SECTOR-SPECIFIC]` — Obtain liability insurance

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

**After confirming completion:** Check `SNOW-04` in `qc-snowmobile-club.md`.

---

### SNOW-05 `[SECTOR-SPECIFIC]` — VHR Act trail designation (Loi sur les VHR)

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

**After confirming designation:** Check `SNOW-05` in `qc-snowmobile-club.md`.

---

### SNOW-06 `[SECTOR-SPECIFIC]` — Annual FCMQ renewal and reporting (recurring)

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

**After confirming completion:** Check `SNOW-06` and record next renewal date.

---

## Completion

When all SNOW steps are checked, update `qc-status.md`:
`- [x] quebec-snowmobile-club — completed [YYYY-MM-DD]`

Then prompt:
"Your snowmobile club is now fully operational! Here's a summary of your ongoing
annual obligations:

**Provincial:**

- INC-05: REQ annual update declaration ($41)
- OBNL-08: Annual general assembly
- OBNL-09: Annual financial statements
- SNOW-06: FCMQ renewal + PACM application (June–August window)

**Federal:**

- See `/quebec-legal-entity:quebec-income-tax` for CO-17.SP + T2 filing deadlines

**Tip:** Set calendar reminders for the June PACM window and your REQ update
notice — these are the two easiest obligations to miss."
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-snowmobile-club/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-snowmobile-club/
git commit -m "feat(quebec-legal-entity): add quebec-snowmobile-club skill (renamed from snowmobile-club-qc, SNOW-xx step IDs)"
```

---

## Chunk 2: New compliance skills — GST/QST, payroll, income tax

### Task 5: New `quebec-gst-qst` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-gst-qst/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-gst-qst/instructions.md`

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-gst-qst
description: |
  Interactive guide for GST/QST registration and ongoing return filing in Quebec.
  Covers mandatory and voluntary registration, filing frequency selection, ITC/RTI
  tracking, instalment obligations, and recurring return reminders.

  In Quebec, Revenu Québec administers both GST and QST — one registration covers both.

  Reads and writes qc-gst-qst.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-gst-qst
  - User asks about GST, QST, TPS, TVQ registration or filing
  - User needs to register for or file sales tax returns in Quebec

  DO NOT activate when:
  - User is asking about income taxes (use quebec-income-tax)
  - User is asking about payroll deductions (use quebec-payroll)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-gst-qst.md), Edit(qc-gst-qst.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
# Quebec GST/QST — Registration and Ongoing Filing

This skill guides you through GST and QST obligations for your Quebec entity.

**Key fact:** In Quebec, Revenu Québec administers both the federal GST (5%) and
provincial QST (9.975%) — one registration covers both taxes. This differs from
other provinces where CRA handles GST directly.

---

## On Start

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
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-gst-qst/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-gst-qst/
git commit -m "feat(quebec-legal-entity): add quebec-gst-qst skill (new)"
```

---

### Task 6: New `quebec-payroll` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-payroll/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-payroll/instructions.md`

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-payroll
description: |
  Interactive guide for payroll setup and compliance for Quebec entities.
  Covers source deduction registration, DAS remittance schedule, first payroll
  run, year-end T4/RL-1 filing, and vacation pay rules.

  Marks itself N/A in qc-status.md if the entity has no employees.
  Reads and writes qc-payroll.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-payroll
  - User is hiring employees or has payroll obligations in Quebec
  - User asks about source deductions, DAS, T4, RL-1, or payroll remittances

  DO NOT activate when:
  - User is asking about GST/QST (use quebec-gst-qst)
  - User is asking about corporate income taxes (use quebec-income-tax)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-payroll.md), Edit(qc-payroll.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
# Quebec Payroll — Source Deductions and Compliance

This skill guides you through payroll setup and ongoing compliance for a Quebec entity
that employs paid staff.

---

## On Start

1. Read `qc-status.md`. If `quebec-payroll` is already `[n/a]`, ask:
   "Payroll was previously marked not applicable. Do you now have employees?"
   If yes, reset to `- [ ] quebec-payroll — not started` in `qc-status.md`.

2. If not N/A, ask: "Does your organization have or plan to hire paid employees?"
   - If **no:** Write `- [n/a] quebec-payroll — not applicable (no employees)` to
     `qc-status.md` and tell the user: "Payroll marked as not applicable. Return
     to this skill if you hire employees in the future." Exit.
   - If **yes:** Continue.

3. Read `qc-payroll.md` if present; create it from the template below if absent.

4. Show current payroll status; jump to first unchecked step.

**`qc-payroll.md` template (create if absent):**

```markdown
# Payroll Status — [organization name]
schema_version: 1
RQ_employer_account: pending
CRA_RP_account: pending
Remittance_frequency: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] PAY-01 — RQ employer account registered
- [ ] PAY-02 — CRA RP account registered
- [ ] PAY-03 — Remittance frequency determined
- [ ] PAY-04 — Employee TD1/TP-1015 forms collected
- [ ] PAY-05 — First payroll run complete
- [ ] PAY-06 — DAS remittance to RQ (recurring, next due: [date])
- [ ] PAY-07 — CRA remittance (recurring, next due: [date])
- [ ] PAY-08 — Year-end T4/RL-1 filed (recurring, next due: Feb 28)
- [ ] PAY-09 — Vacation pay compliance confirmed
```

---

## NEVER / ALWAYS

### NEVER

- Skip the employee question at start — proceed to steps only if user confirms employees
- Ignore director liability warning before PAY-01

### ALWAYS

- Warn about director personal liability for unremitted deductions before PAY-01
- Remind the user to set up ClicSÉQUR before year-end (before PAY-08 becomes relevant)
- Track next due dates for PAY-06, PAY-07, PAY-08 after each completion

---

## ⚠️ CRITICAL WARNING — Show before PAY-01

> **Director personal liability:** Quebec directors are jointly and severally liable
> for unremitted source deductions (QPP, QPIP, EI, income tax withheld). This is
> not a corporate debt that can be shielded by incorporation — it is a personal
> obligation. Set up remittance reminders and never skip a remittance period.

---

## Steps

---

### PAY-01 `[GENERIC][PROV]` — Register employer account with Revenu Québec

**What to do:**
Register a Quebec employer account with Revenu Québec. This account is used for:

- Quebec Pension Plan (QPP) contributions
- Quebec Parental Insurance Plan (QPIP) premiums
- Quebec income tax withholdings (QIT)
- DAS (Déclaration des acomptes provisionnels) remittances

**Where:** revenuquebec.ca → "Inscription employeur" or call 1-800-567-4692

**Information required:**

- NEQ
- Start date of first payroll
- Estimated number of employees
- Estimated annual payroll

**Cost:** Free
**Delay:** Registration before first payroll — allow 1–2 weeks

**After confirming registration:** Record the RQ employer account number in
`qc-payroll.md`. Check `PAY-01`.

---

### PAY-02 `[GENERIC][FED]` — Register RP payroll account with CRA

**What to do:**
Register a federal payroll deductions account (RP account) with CRA. This account
is used for:

- Employment Insurance (EI) premiums
- Federal income tax withholdings (FIT)
- Canada Pension Plan — note: Quebec employees pay **QPP** (not CPP), so CPP
  does not apply, but EI and FIT still require the RP account

**Where:** canada.ca/en/revenue-agency → "Business Registration Online (BRO)"
or call 1-800-959-5525

**Your CRA Business Number (BN) will have been assigned** when you registered for
GST/QST (GST-02). The RP account is a sub-account of your BN (e.g., 123456789 RP 0001).

**Cost:** Free
**Delay:** Before first payroll

**After confirming registration:** Record the CRA RP account number in
`qc-payroll.md`. Check `PAY-02`.

---

### PAY-03 `[GENERIC][PROV][FED]` — Determine remittance frequency

**What to do:**
Determine how often you must remit source deductions to both Revenu Québec and CRA.

**Revenu Québec remittance frequencies:**

| Frequency | Trigger |
| --- | --- |
| Quarterly | Average monthly withholdings ≤ $1,000 |
| Monthly | Average monthly withholdings $1,000–$25,000 |
| Accelerated | Average monthly withholdings > $25,000 |

**CRA remittance frequencies:** Similar thresholds apply.

**New employers:** Typically assigned monthly frequency in the first year.

**Cost:** Free
**Delay:** At registration

**After confirming frequency:** Record in `qc-payroll.md` (Remittance_frequency).
Check `PAY-03`.

---

### PAY-04 `[GENERIC][PROV][FED]` — Collect employee tax forms

**What to do:**
Collect completed forms from each new employee before their first pay:

- **Federal:** TD1 (Personal Tax Credits Return) — employee claims federal credits
- **Provincial:** TP-1015.3-V (Source Deductions Return) — employee claims Quebec credits

These forms determine how much income tax to withhold. Keep originals on file.

**Cost:** Free
**Delay:** Before first pay

**After confirming collection:** Check `PAY-04` in `qc-payroll.md`.

---

### PAY-05 `[GENERIC][PROV][FED]` — Run first payroll

**What to do:**
Calculate and process the first payroll. For each employee, withhold:

- **QPP:** 5.40% of pensionable earnings (employee share; employer matches)
- **QPIP:** 0.494% of insurable earnings (employee share; employer pays 0.692%)
- **EI:** 1.66% of insurable earnings (employee share; employer pays 1.4×)
- **QIT:** Per TP-1015.3 tables
- **FIT:** Per TD1 and federal tables

Use Revenu Québec's "Guide for Employers" (TP-1015.G-V) or payroll software
(Payworks, Ceridian, QuickBooks Payroll, etc.) to calculate correctly.

**Cost:** Payroll software or accountant fee (variable)
**Delay:** Per pay cycle

**After first payroll:** Check `PAY-05` in `qc-payroll.md`.

---

### PAY-06 `[GENERIC][PROV]` — DAS remittance to Revenu Québec (recurring)

**What to do:**
Remit source deductions to Revenu Québec via DAS (Déclaration des acomptes
provisionnels) on your assigned schedule.

**Due dates:**

- Monthly: 15th of the following month
- Quarterly: 15th of the month following the quarter-end
- Accelerated: varies (contact RQ for schedule)

**Where:** revenuquebec.ca → "Mon dossier pour les entreprises" → "Remittances"

**Cost:** Free
**Delay:** Per frequency

**After each remittance:** Update the `next due` date in `qc-payroll.md`. Check `PAY-06`.

---

### PAY-07 `[GENERIC][FED]` — CRA payroll remittance (recurring)

**What to do:**
Remit EI and federal income tax deductions to CRA on your assigned schedule.

**Due dates:** Same general thresholds as Revenu Québec.

**Where:** canada.ca → "My Business Account" → "Payroll"

**Cost:** Free
**Delay:** Per frequency

**After each remittance:** Update the `next due` date in `qc-payroll.md`. Check `PAY-07`.

---

### PAY-08 `[GENERIC][PROV][FED]` — Year-end: issue T4 and RL-1 (recurring)

**What to do:**
By February 28 each year, issue year-end slips to all employees:

- **T4** (Statement of Remuneration Paid): file with CRA and give copy to employee
- **RL-1** (Relevé 1): file with Revenu Québec and give copy to employee

**⚠️ ClicSÉQUR setup:** RL-1 slips must be filed electronically via Revenu Québec's
ClicSÉQUR system (mandatory for employers with 5+ employees; recommended for all).
Set up your ClicSÉQUR account well before year-end — the process takes time.

**Deadline:** February 28 (or last business day of February)

**Cost:** Free to file
**Delay:** Annual recurring

**After confirming filing:** Update the next due date in `qc-payroll.md`. Check `PAY-08`.

---

### PAY-09 `[GENERIC][PROV]` — Vacation pay compliance

**What to do:**
Ensure vacation pay is calculated and paid per the Act respecting labour standards
(Loi sur les normes du travail):

- **Minimum:** 4% of gross wages (less than 3 years of service)
  or 6% (3 years of service or more)
- Can be paid with each paycheque or accumulated and paid at vacation time

**Cost:** Ongoing
**Delay:** Per employee, per pay cycle

**After confirming compliance setup:** Check `PAY-09` in `qc-payroll.md`.

---

## Completion

When all applicable PAY steps are checked, update `qc-status.md`:
`- [x] quebec-payroll — completed [YYYY-MM-DD]`

Then prompt: "Payroll is set up. Ensure these other compliance skills are also complete:

- `/quebec-legal-entity:quebec-gst-qst` — GST/QST filing
- `/quebec-legal-entity:quebec-income-tax` — corporate income tax"
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-payroll/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-payroll/
git commit -m "feat(quebec-legal-entity): add quebec-payroll skill (new)"
```

---

### Task 7: New `quebec-income-tax` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-income-tax/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-income-tax/instructions.md`

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-income-tax
description: |
  Interactive guide for corporate income tax obligations in Quebec.
  Branches on entity type: T2 (for-profit) or CO-17.SP + T2 + T1044 (OBNL).
  Covers fiscal year-end, instalment obligations, filing deadlines, and
  annual recurring reminders.

  Reads Entity type from qc-status.md to determine the correct branch.
  Reads and writes qc-income-tax.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-income-tax
  - User asks about corporate income tax, T2, CO-17.SP, or T1044

  DO NOT activate when:
  - User is asking about GST/QST (use quebec-gst-qst)
  - User is asking about payroll deductions (use quebec-payroll)
  - User is asking about personal income taxes (out of scope)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-income-tax.md), Edit(qc-income-tax.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
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

### TAX-06 — Annual recurring

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

### TAX-06 — Annual recurring

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
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-income-tax/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-income-tax/
git commit -m "feat(quebec-legal-entity): add quebec-income-tax skill (new, branches on entity type)"
```

---

## Chunk 3: Advisory skills + cleanup

### Task 8: New `quebec-insurance` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-insurance/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-insurance/instructions.md`

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-insurance
description: |
  Advisory insurance coverage guide for Quebec entities. Walks through coverage
  types (general liability, D&O, property, E&O, event liability, sector-specific)
  and records decisions in a coverage log (qc-insurance.md).

  This is an advisory skill — it guides decisions rather than filing steps.
  No prerequisites. Run at any time after entity formation.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-insurance
  - User asks what insurance their Quebec entity needs
  - User wants to review or update their insurance coverage

  DO NOT activate when:
  - User is asking about snowmobile-specific insurance coverage
    (use quebec-snowmobile-club for FCMQ-related insurance)
  - User is asking about employee benefits or group insurance programs
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-insurance.md), Edit(qc-insurance.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
# Quebec Entity Insurance — Coverage Guide

This skill guides you through selecting appropriate insurance coverage for your
Quebec entity. It is advisory — it helps you decide what you need and records
those decisions, but does not file anything with a government body.

---

## On Start

1. Read `qc-status.md` for entity type (for-profit or OBNL) and Organization name.
2. Read `qc-insurance.md` if present; create it from the template below if absent.
3. Show current coverage log.
4. Ask: "Would you like to review all insurance sections, or jump to a specific one?"

**`qc-insurance.md` template (create if absent):**

```markdown
# Insurance Coverage Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Coverage

| Type | Required | Insurer | Policy # | Annual Premium | Renewal Date |
| --- | --- | --- | --- | --- | --- |
| General liability | pending | — | — | — | — |
| Directors & officers (D&O) | pending | — | — | — | — |
| Property | pending | — | — | — | — |
| Errors & omissions (E&O) | pending | — | — | — | — |
| Event liability | pending | — | — | — | — |
| Sector-specific | see snowmobile-club | — | — | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user that a specific insurer is the only option — present as examples
- Recommend skipping D&O coverage for any organization with a board of directors

### ALWAYS

- Note that snowmobile club trail operations insurance is handled in
  `quebec-snowmobile-club`, not here
- After each section, record the decision (obtained or explicitly declined)
  in `qc-insurance.md`

---

## Advisory Sections

For each section: explain what it covers, who needs it, typical cost range,
and how to obtain it. Ask whether the entity needs this coverage, then record
the decision in `qc-insurance.md`.

---

### INS-01 — General Liability

**What it covers:** Third-party bodily injury and property damage arising from
your organization's operations, premises, or products.

**Who needs it:** Any entity that interacts with the public, rents premises,
or has members attending events. This is the minimum baseline coverage.

**Why it matters:** Without it, a single incident (slip and fall at an event,
damage to a third party's property) could expose the organization to a lawsuit
that exceeds its assets.

**Typical cost:** $500–$2,000/year for a small OBNL, depending on activities
and revenue.

**How to obtain:** Any commercial insurer. For OBNLs, check if your sector
association (e.g., FCMQ) offers group rates.

---

### INS-02 — Directors & Officers (D&O)

**What it covers:** Personal liability of board members and officers for decisions
made in their capacity as directors. Covers legal defence costs and settlements
arising from claims of mismanagement, breach of duty, or wrongful acts.

**Who needs it:** Any organization with a board of directors. **Strongly recommended.**
Note that corporate structure does not fully shield directors from personal liability
(especially for source deductions — see payroll skill).

**Typical cost:** $1,000–$3,000/year for a small OBNL board.

**How to obtain:** Most commercial insurers; ask your general liability insurer
for a combined package.

---

### INS-03 — Property Insurance

**What it covers:** Physical assets owned by the organization: equipment,
vehicles, tools, buildings (if owned).

**Who needs it:** Any entity owning significant physical assets. For snowmobile
clubs: snowgroomers, trailers, storage facilities.

**Typical cost:** Varies by asset value — typically 1–2% of insured value per year.

**How to obtain:** Commercial property insurer; often bundled with general liability.

---

### INS-04 — Errors & Omissions (E&O) / Professional Liability

**What it covers:** Claims arising from professional advice, services, or work
products provided to clients or members.

**Who needs it:** Organizations providing professional services (consulting,
technical advice, certification). Typically not required for recreational OBNLs
or snowmobile clubs.

**Typical cost:** $1,500–$5,000/year depending on the nature of services.

**How to obtain:** Specialty insurers or professional association group policies.

---

### INS-05 — Event Liability

**What it covers:** Liability arising from specific events open to the public
(races, fundraisers, public trail openings).

**Who needs it:** Any organization holding public events not covered by their
general liability policy. Check your GL policy for event exclusions.

**Typical cost:** $200–$1,000 per event, or included in annual GL policy up to
a certain number of events.

**How to obtain:** Your existing insurer or specialist event insurers.

---

### INS-06 — Sector-Specific Coverage

For snowmobile club trail operations insurance (including groomer operators,
trail maintenance crews, and droits d'accès liability), refer to:
`/quebec-legal-entity:quebec-snowmobile-club` (step SNOW-04).

FCMQ provides base civil liability coverage ($1,000,000) with membership.
Supplemental D&O and property coverage should be arranged separately.

---

## Completion

When all sections have been reviewed and recorded, update `qc-status.md`:
`- [x] quebec-insurance — completed [YYYY-MM-DD]`

Then prompt: "Insurance review complete. Review annually before each renewal date
and after any significant change in activities, assets, or number of employees."
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-insurance/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-insurance/
git commit -m "feat(quebec-legal-entity): add quebec-insurance skill (new, advisory)"
```

---

### Task 9: New `quebec-accounting` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-accounting/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-accounting/instructions.md`

- [ ] **Step 1: Create SKILL.md**

```markdown
---
name: quebec-accounting
description: |
  Advisory bookkeeping setup guide for Quebec entities. Covers fiscal year-end
  choice, accounting software selection, chart of accounts, bookkeeper vs CPA
  decision, and record retention requirements.

  This is an advisory skill — run once at entity formation. Records decisions
  in qc-accounting.md. No prerequisites and no recurring steps.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-accounting
  - User asks about bookkeeping setup, accounting software, or fiscal year choice
  - User wants guidance on accounting for their Quebec entity

  DO NOT activate when:
  - User is asking about tax return filing (use quebec-income-tax)
  - User is asking about payroll records (use quebec-payroll)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-accounting.md), Edit(qc-accounting.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

````markdown
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
````

- [ ] **Step 3: Verify**

Run: `npx markdownlint-cli2 "quebec-legal-entity/skills/quebec-accounting/**/*.md"`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/skills/quebec-accounting/
git commit -m "feat(quebec-legal-entity): add quebec-accounting skill (new, advisory)"
```

---

### Task 10: Delete old plugin, final lint, and validate

**Files:**

- Delete: `legal-entity-incorporation/` (entire directory)

- [ ] **Step 1: Run full lint on new plugin**

Run: `npx markdownlint-cli2 "quebec-legal-entity/**/*.md"`
Expected: 0 errors

Fix any errors before proceeding.

- [ ] **Step 2: Delete old plugin directory**

```bash
rm -rf legal-entity-incorporation/
```

- [ ] **Step 3: Verify old plugin is gone**

Run: `ls`
Expected: `legal-entity-incorporation/` is no longer listed.

- [ ] **Step 4: Run plugin validator**

Use the `plugin-dev:plugin-validator` agent to validate `quebec-legal-entity/`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: remove old legal-entity-incorporation plugin (replaced by quebec-legal-entity)"
```

- [ ] **Step 6: Final commit message summary**

```bash
git log --oneline -12
```

Expected: 10 commits visible for this feature (Tasks 1–10).

# Batch B — Snowmobile Operations Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three snowmobile-specific operational skills to the `quebec-legal-entity` plugin.

**Architecture:** Each skill is a directory under `quebec-legal-entity/skills/<name>/` containing `SKILL.md` (bare YAML front-matter with `---` delimiters) and `instructions.md` (full procedural markdown). Pattern mirrors existing skills in the plugin (e.g., `quebec-payroll`, `quebec-insurance`). README.md gets three new entries before `## Progress Tracking`. No code, no tests — content files only.

**Tech Stack:** Markdown, YAML front-matter. Plugin framework expects bare `---`-delimited YAML in SKILL.md (no code fence wrappers).

**Spec:** `docs/superpowers/specs/2026-03-12-quebec-legal-entity-batch-b-snowmobile-design.md`

---

## Chunk 1: Three Skill Files

### Task 1: `quebec-land-access` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-land-access/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-land-access/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-land-access/SKILL.md` with exact content:

```
---
name: quebec-land-access
description: |
  Interactive guide for negotiating and recording droits de passage (land access
  agreements) with private landowners for Quebec snowmobile trail networks.

  Covers landowner inventory, FCMQ standard agreement templates, negotiation
  approach, compensation structures, and annual renewal tracking.

  Without signed access agreements, trails cross private land without legal
  basis. This skill is critical before any trail opens to the public.

  Reads and writes qc-land-access.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-land-access
  - User is a Quebec snowmobile club needing land access agreements for trails
  - User asks about droits de passage or landowner permission for trail networks

  DO NOT activate when:
  - User has not yet obtained FCMQ membership (complete quebec-snowmobile-club first)
  - User is asking about MRC or municipal permits (use quebec-mrc-permits)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-land-access.md), Edit(qc-land-access.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-land-access/instructions.md` with exact content:

````markdown
# Quebec Land Access — Droits de Passage Agreements

This skill guides you through negotiating and recording droits de passage (land
access agreements) with private landowners for Quebec snowmobile trail networks.

---

## On Start

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   tell the user: "Complete `/quebec-legal-entity:quebec-snowmobile-club` first
   — FCMQ membership (SNOW-01) must be submitted before negotiating land access."
   Exit.

2. Read `qc-land-access.md` if present; create it from the template below if absent.

3. Present current status; jump to first unchecked step.

**`qc-land-access.md` template (create if absent):**

```markdown
# Land Access Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps
- [ ] LND-01 — Trail inventory completed (all segments mapped)
- [ ] LND-02 — Landowner list compiled
- [ ] LND-03 — FCMQ agreement template obtained
- [ ] LND-04 — Priority agreements signed (segments blocking trail opening)
- [ ] LND-05 — Remaining agreements signed or alternate routes planned
- [ ] LND-06 — Annual renewal process established

## Agreements Log

| Segment | Landowner | Status | Signed | Renewal date | Notes |
| --- | --- | --- | --- | --- | --- |
| — | — | pending | — | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Suggest the club can open trails on private land without signed agreements —
  trespassing exposes the club and FCMQ to civil liability
- Mark LND-04 complete without recording each agreement in the Agreements Log

### ALWAYS

- At LND-02: recommend working with the local MRC cadastral office for landowner
  identification — they have the authoritative records
- At LND-04: remind the user that FCMQ regional representatives often have
  relationships with repeat landowners and can facilitate introductions
- After each agreement signed: record it in the Agreements Log in `qc-land-access.md`

---

## CRITICAL WARNINGS

> **Trail cannot open without access agreements:** Opening a trail on private
> land without a signed agreement is civil trespass. FCMQ's liability insurance
> does not cover incidents on unsanctioned trail segments.
>
> **Compensation varies widely:** Some landowners request nothing; others ask
> for cash (typically $50–$500/year per parcel), a grooming pass, or fuel
> assistance. Establish a consistent policy to avoid disputes.
>
> **Annual renewal:** Most agreements run year-to-year or multi-year. Track
> expiry dates — a lapsed agreement means the trail legally cannot open for
> that season.

---

## Steps

---

### LND-01 `[SECTOR-SPECIFIC]` — Trail inventory: map all segments

**What to do:**
Map all planned trail segments and identify which cross private land versus
public land (Crown land, municipal road allowances, hydro corridors).

- Use available topographic maps and the club's proposed trail route
- For each segment, record whether it is on private or public land
- Note segments that cross railway corridors or utility rights-of-way —
  these require separate authorizations (railway: Transport Canada; hydro:
  Hydro-Québec; pipeline: operator)

**Cost:** Free
**Delay:** 1–4 weeks

**After completing inventory:** Record trail segments in the Agreements Log
with landowner status `pending` for all private parcels. Check `LND-01` in
`qc-land-access.md`.

---

### LND-02 `[SECTOR-SPECIFIC]` — Compile landowner list

**What to do:**
Compile a list of all private landowners whose parcels the trail crosses.

- **Primary source:** MRC cadastral maps (rôle d'évaluation foncière) —
  available at the MRC planning office or via the MRC's online portal
- **Secondary source:** MRNF (Ministère des Ressources naturelles et des
  Forêts) for Crown land boundaries
- For each parcel, record: owner name, civic address or contact info, and
  which trail segment(s) cross their land

**Cost:** Free (public records)
**Delay:** 1–2 weeks

**After completing list:** Update the Agreements Log in `qc-land-access.md`
with landowner names. Check `LND-02`.

---

### LND-03 `[SECTOR-SPECIFIC]` — Obtain FCMQ standard agreement template

**What to do:**
Contact your FCMQ regional representative to obtain the standard droits de
passage agreement template. FCMQ maintains a standard form that is familiar
to repeat landowners throughout Quebec.

- The template specifies permitted use, liability, compensation (if any),
  duration, and renewal terms
- Do not draft your own agreement from scratch — the FCMQ template is the
  standard accepted by landowners across Quebec

**Cost:** Free
**Delay:** Immediate (contact regional rep)

**After obtaining template:** Note the template version and date received in
`qc-land-access.md`. Check `LND-03`.

---

### LND-04 `[SECTOR-SPECIFIC]` — Sign priority agreements

**What to do:**
Contact and negotiate with landowners whose parcels block trail opening.
Prioritize parcels where no alternate route exists.

**Negotiation approach:**
- Lead with the community benefit and the club's FCMQ affiliation
- Present the FCMQ standard template — do not improvise terms
- Compensation varies: some landowners request nothing; others ask for cash
  ($50–$500/year per parcel), a seasonal grooming pass, or fuel assistance
- Establish a consistent compensation policy to avoid disputes between
  landowners who compare notes

**FCMQ regional representative assistance:**
- FCMQ representatives often have established relationships with repeat
  landowners and can facilitate introductions — contact them before
  approaching landowners directly in a new territory

**Cost:** Variable (compensation per agreement)
**Delay:** Weeks to months (depends on landowner responsiveness)

**After each agreement signed:** Record in the Agreements Log:
- Segment name
- Landowner name
- Status: `signed`
- Signed date
- Renewal date (typically one year from signing, or as agreed)
- Notes (compensation terms, special conditions)

Check `LND-04` only after all priority-segment agreements are recorded.

---

### LND-05 `[SECTOR-SPECIFIC]` — Resolve remaining segments

**What to do:**
For trail segments not resolved in LND-04, either:

1. **Complete remaining agreements:** Continue negotiations with remaining
   landowners; apply the same approach as LND-04
2. **Plan alternate routes:** For segments where access cannot be obtained,
   identify alternate routes that avoid the uncooperative parcel

Record the resolution for each outstanding segment in the Agreements Log
(signed, or alternate route with notes explaining the rerouting).

**Cost:** Variable
**Delay:** Ongoing until all segments resolved

**After resolving all segments:** Verify every trail segment has either a
signed agreement or an alternate route documented. Check `LND-05` in
`qc-land-access.md`.

---

### LND-06 `[SECTOR-SPECIFIC]` — Establish annual renewal process

**What to do:**
Set up a systematic process to renew agreements before they expire each season.

- Review the Agreements Log for renewal dates at least 60 days before the
  earliest expiry
- Send renewal notices to all landowners; renegotiate terms if requested
- Update the Agreements Log renewal dates after each renewal
- Set calendar reminders in your club's administration calendar

**Cost:** Free
**Delay:** Annual recurring

**After establishing the process:** Document the renewal procedure (who is
responsible, what lead time to use) in a note in `qc-land-access.md`.
Check `LND-06`.

---

## Completion

When LND-04 and LND-05 are checked (all priority agreements signed and
remaining segments resolved), update `qc-status.md`:
`- [x] quebec-land-access — completed [YYYY-MM-DD]`

Then prompt: "Your trail network has legal land access coverage. Ongoing
obligations: renew agreements before expiry (LND-06) and record new segments
in the Agreements Log as the trail network expands."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-land-access/
git commit -m "feat(quebec-legal-entity): add quebec-land-access skill (droits de passage)"
```

---

### Task 2: `quebec-mrc-permits` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-mrc-permits/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-mrc-permits/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-mrc-permits/SKILL.md` with exact content:

```
---
name: quebec-mrc-permits
description: |
  Guide for obtaining MRC (Municipalité régionale de comté) and municipal
  authorizations for Quebec snowmobile trail infrastructure.

  Covers MRC trail corridor authorizations, municipal road crossing permits,
  signage permits, and grooming depot construction permits where required.

  Requirements vary significantly by MRC and municipality. This skill
  provides a framework and checklist rather than a fixed step sequence.

  Reads and writes qc-mrc-permits.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-mrc-permits
  - User is a Quebec snowmobile club needing municipal or MRC authorizations
  - User asks about permits for trail crossings, signage, or depot construction

  DO NOT activate when:
  - User is asking about land access agreements with private landowners
    (use quebec-land-access)
  - User is asking about RBQ/CCQ construction permits for larger structures
    (use quebec-construction-permits)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-mrc-permits.md), Edit(qc-mrc-permits.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-mrc-permits/instructions.md` with exact content:

````markdown
# Quebec MRC/Municipal Permits — Trail Infrastructure Authorizations

This skill guides you through obtaining MRC and municipal authorizations for
Quebec snowmobile trail infrastructure.

---

## On Start

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   tell the user: "MRC and municipal permits require active FCMQ membership
   context. Complete `/quebec-legal-entity:quebec-snowmobile-club` first."
   Exit.

2. Read `qc-mrc-permits.md` if present; create it from the template below if absent.

3. Present current permit status; jump to first unchecked step.

**`qc-mrc-permits.md` template (create if absent):**

```markdown
# MRC/Municipal Permits Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps
- [ ] MRC-01 — MRC trail network authorization contacted
- [ ] MRC-02 — Municipal road crossing permits identified and applied for
- [ ] MRC-03 — Signage permits obtained (where required)
- [ ] MRC-04 — Grooming depot permits confirmed (if applicable)

## Permit Log

| Permit type | Authority | Status | Issued | Expiry | Notes |
| --- | --- | --- | --- | --- | --- |
| — | — | pending | — | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user MRC permits are uniform across Quebec — requirements vary
  significantly by region; always direct to the local MRC planning department
- Mark MRC-02 complete without recording each crossing permit in the Permit Log

### ALWAYS

- At MRC-01: recommend consulting the FCMQ regional representative first —
  they know the MRC-specific requirements in the territory and can make
  introductions to MRC planning staff
- After each permit obtained: record it in the Permit Log with expiry date

---

## CRITICAL WARNING

> **MRC requirements vary by region:** Some MRCs require formal trail corridor
> inclusion in the schéma d'aménagement before trails can be designated under
> the VHR Act. Consult your FCMQ regional representative — they know the
> requirements in your territory.

---

## Steps

---

### MRC-01 `[SECTOR-SPECIFIC]` — MRC trail network authorization

**What to do:**
Contact the MRC planning department (service de l'aménagement du territoire)
to understand trail corridor requirements in the regional land use plan
(schéma d'aménagement et de développement).

Key questions to ask the MRC:
- Is snowmobile trail designation explicitly included in the schéma?
- Does the MRC require formal authorization or designation before trails can
  open to the public under the VHR Act?
- Are there specific setbacks or conditions for trails near agricultural zones,
  waterways, or residential areas?

**FCMQ regional representative:** Contact them before approaching the MRC —
they have experience with the process in your territory and may already have
an established relationship with MRC staff.

**Cost:** Free
**Delay:** 1–4 weeks (to obtain meeting and initial response)

**After initial MRC contact:** Record the MRC contact name, date of contact,
and any authorization requirements identified in the Permit Log. Check `MRC-01`
in `qc-mrc-permits.md`.

---

### MRC-02 `[SECTOR-SPECIFIC]` — Municipal road crossing permits

**What to do:**
Identify all points where the trail crosses a municipal road and apply for
crossing permits from the relevant municipality.

**For each crossing:**
- Identify the municipality responsible for the road
- Contact the municipality's public works or engineering department
- Apply for a crossing permit (typically annual)
- Record the permit in the Permit Log with expiry date

**Typical requirements:**
- Crossing location (civic address or GPS coordinates)
- Crossing design (groomed trail crossing, signage plan)
- Club liability insurance certificate (FCMQ membership provides base coverage)

**Cost:** $0–$500 per crossing (varies by municipality)
**Delay:** 2–8 weeks per permit

**After each permit received:** Record in the Permit Log:
- Permit type: `road crossing`
- Authority: municipality name
- Status: `issued`
- Issued date and expiry date (most are annual)

Check `MRC-02` after all crossing permit applications are submitted and at
least priority crossings are issued.

---

### MRC-03 `[SECTOR-SPECIFIC]` — Signage permits

**What to do:**
Obtain signage permits from the municipality where trails pass through urban
or semi-urban zones, if required.

**When this applies:**
- Trail signs installed within municipal road allowances or public property
- Trail directional signs or warning signs within urban perimeters

**Not all municipalities require a permit for trail signs on private land.**
Confirm with the municipality's building or public works department.

**Cost:** Variable (typically $0–$200 per sign location)
**Delay:** 2–6 weeks

**If not applicable (trail does not pass through urban zones or municipality
does not require signage permits):** Record `MRC-03 — N/A` in the Permit Log
and check the step.

**After obtaining permits:** Record each in the Permit Log. Check `MRC-03`.

---

### MRC-04 `[SECTOR-SPECIFIC]` — Grooming depot and shelter permits

**What to do:**
If the club is constructing or has constructed a grooming equipment depot,
storage building, or trail shelter, confirm building permit requirements from
the municipality where the structure is located.

**Applicable permits may include:**
- Municipal building permit (permis de construction) from the municipality
- Quebec RBQ (Régie du bâtiment du Québec) permits for electrical or plumbing
  work within the building
- Environmental authorization if the site involves wetlands or watercourse setbacks

**If not applicable (no permanent structures being built):** Record
`MRC-04 — N/A` in the Permit Log and check the step.

**Cost:** Variable ($200–$2,000+ depending on structure size and municipality)
**Delay:** 4–12 weeks

**After permits confirmed:** Record each in the Permit Log. Check `MRC-04`.

---

## Completion

When MRC-01 through MRC-04 are checked (or marked N/A where not applicable),
update `qc-status.md`:
`- [x] quebec-mrc-permits — completed [YYYY-MM-DD]`

Then prompt: "MRC and municipal permit coverage is established. Renew
road-crossing permits annually (check Permit Log for expiry dates)."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-mrc-permits/
git commit -m "feat(quebec-legal-entity): add quebec-mrc-permits skill (MRC and municipal permits)"
```

---

### Task 3: `quebec-grants` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-grants/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-grants/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-grants/SKILL.md` with exact content:

```
---
name: quebec-grants
description: |
  Advisory guide for grant programs available to Quebec snowmobile clubs
  beyond the MTQ/PACM program (already covered in quebec-snowmobile-club).

  Covers provincial programs (Tourisme Québec PAIR, MRC fonds locaux),
  federal programs (Canada Summer Jobs, Sport Canada), and foundation programs.
  Helps identify applicable programs, track application windows, and
  record outcomes.

  This is an advisory skill — it maps available funding and tracks applications.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-grants
  - User is a Quebec snowmobile club looking for grant funding beyond PACM
  - User asks about government funding programs for recreational organizations

  DO NOT activate when:
  - User is asking specifically about MTQ/PACM (covered in quebec-snowmobile-club
    step SNOW-03)
  - User is asking about FCMQ membership funding (covered in quebec-snowmobile-club)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-grants.md), Edit(qc-grants.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-grants/instructions.md` with exact content:

````markdown
# Quebec Grants — Funding Programs Beyond PACM

This skill is an advisory guide for grant programs available to Quebec snowmobile
clubs beyond the MTQ/PACM program (already covered in `quebec-snowmobile-club`).

---

## On Start

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   warn: "Most grant programs require active FCMQ membership. Consider completing
   `/quebec-legal-entity:quebec-snowmobile-club` first. You may still review
   programs, but eligibility for most requires membership."

2. Read `qc-grants.md` if present; create it from the template below if absent.

3. Show current Program Tracker; ask which sections the user wants to review.

**`qc-grants.md` template (create if absent):**

```markdown
# Grants Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Program Tracker

| Program | Funder | Window | Status | Amount | Notes |
| --- | --- | --- | --- | --- | --- |
| MTQ/PACM Volet 1 | MTQ | June–Aug | see SNOW-03 | — | — |
| MTQ/PACM Volet 2 | FCMQ/MTQ | June–Aug | see SNOW-03 | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Present MTQ/PACM in this skill — redirect to `quebec-snowmobile-club` SNOW-03
- Mark a program as `applied` without recording the application date and
  requested amount in the Program Tracker

### ALWAYS

- After each program section: add the program to the Program Tracker with
  its window and current status
- At the end of each session: surface any programs with approaching windows
  based on the current date

---

## CRITICAL WARNING

> **Application windows are program-specific:** Unlike PACM's fixed June–August
> window, other programs have varying deadlines. Some require 6–12 months lead
> time for major infrastructure grants. Add each discovered program to the
> Program Tracker with its window.

---

## Advisory Sections

For each section: explain the program, its eligibility requirements, application
window, and typical funding amounts. Ask whether the club wants to track this
program, then record it in the Program Tracker in `qc-grants.md`.

---

### GRT-01 — Tourisme Québec PAIR

**Program:** Programme d'aide pour les infrastructures récréotouristiques (PAIR)
**Funder:** Tourisme Québec (Ministère du Tourisme)

**What it funds:**
Grooming equipment purchases, trail infrastructure improvements, and
recreational tourism infrastructure with a demonstrable tourism benefit.

**Eligibility:**
- Incorporated non-profit organization (OBNL)
- Active FCMQ membership typically strengthens the application
- Demonstrated recreational tourism benefit in the region

**Application window:** Call for projects typically in spring (March–May).
Verify the current cycle at tourisme.gouv.qc.ca — windows vary by year.

**Typical funding:** Variable; major equipment purchases (grooming machines)
can attract significant grants. Check current maximums in the program guide.

**How to apply:** tourisme.gouv.qc.ca → Programs and financial assistance.
Contact your regional Tourisme Québec office for pre-application guidance.

**After reviewing:** Add to Program Tracker with current window status.

---

### GRT-02 — MRC Fonds de développement des territoires (FDT)

**Program:** Fonds de développement des territoires (FDT)
**Funder:** MRC (via provincial transfer funds)

**What it funds:**
Local discretionary development projects determined by each MRC. Scope and
eligibility vary significantly by MRC — some prioritize recreational
infrastructure; others focus on economic development or community services.

**Eligibility:**
- Must be operating in the MRC's territory
- Typically requires a demonstrable local economic or community benefit
- Contact your CLD (Centre local de développement) or MRC economic development
  office for current priorities and availability

**Application window:** Varies by MRC — no fixed provincial window. Contact
the MRC directly to ask about current call for projects.

**Typical funding:** $5,000–$50,000 depending on MRC budget and project scope.

**How to apply:** Contact the MRC's economic development office or CLD directly.

**After reviewing:** Add to Program Tracker with MRC name and contact noted.

---

### GRT-03 — Canada Summer Jobs

**Program:** Canada Summer Jobs
**Funder:** Employment and Social Development Canada (ESDC)

**What it funds:**
Subsidized summer student wages (15–30 years old; full-time; 6–16 weeks).
Covers 50–100% of minimum wage for non-profit organizations.

**Eligibility:**
- Non-profit organization (OBNL status required)
- Position must be for a Canadian citizen, permanent resident, or person
  with work authorization
- Positions must be full-time and align with an organizational mandate

**Application window:** Opens in **November** for the following summer.
Deadline is typically in January. Applications through the Government of Canada
Jobs Portal (canada.ca/en/employment-social-development/services/funding/canada-summer-jobs).

**Typical funding:** 100% of applicable minimum wage for non-profits (up to
the maximum insurable earnings threshold for the hours worked).

**How to apply:** canada.ca/en/employment-social-development/services/funding/canada-summer-jobs

**After reviewing:** Add to Program Tracker. Note the November application
opening — clubs must plan trail maintenance or administrative positions ahead
of each cycle.

---

### GRT-04 — Sport Canada / Canadian Heritage

**Program:** Community Sport for All Initiative (or successor program)
**Funder:** Canadian Heritage / Sport Canada

**What it funds:**
Projects increasing participation in organized sport, with a focus on
underrepresented populations.

**Eligibility:**
- Requires a demonstrated sport mandate (snowmobile clubs with organized racing
  or youth sport programs may qualify)
- Federal not-for-profit incorporation or equivalent status
- **Verify program availability annually** — federal sport funding streams
  change between federal budget cycles; the program name and eligibility
  criteria may have changed since this guide was written

**Application window:** Varies; check canadianheritage.gc.ca for current
open calls.

**Typical funding:** Variable — check current program guide for maximums.

**How to apply:** canadianheritage.gc.ca → Funding → Sport

**After reviewing:** Add to Program Tracker with a note to verify program
availability before applying.

---

### GRT-05 — Foundation and corporate programs

**Programs:** Fondation Hydro-Québec, Fondation McConnell, regional
community foundations, and corporate social responsibility programs.

**What they fund:**
Community and environmental projects; varies by foundation mandate. Hydro-Québec
programs often support community recreation infrastructure in regions where
Hydro-Québec has significant operations.

**Eligibility:**
- Non-profit status typically required
- Projects must align with the foundation's mandate (community, environment,
  sport, tourism)
- Some foundations restrict funding to specific regions or demographics

**Application window:** Varies by foundation — check annually for current
calls for projects. Most foundations publish their call for projects on their
websites in the fall or spring.

**How to identify relevant foundations:**
- Fondation Hydro-Québec: hydroquebec.com/fondation
- Fondation McConnell: mcconnellfoundation.ca
- Portail des fondations du Québec: fondationsquebec.ca (directory of regional
  foundations)
- Ask the MRC economic development office for locally active foundations

**After reviewing:** Add any identified programs to the Program Tracker with
the foundation name, approximate window, and status.

---

## Completion

When all applicable programs have been reviewed and added to the Program
Tracker, update `qc-status.md`:
`- [x] quebec-grants — completed [YYYY-MM-DD]`

Then prompt: "Grant programs documented. Return to update the Program Tracker
after each application cycle and when new programs are discovered."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-grants/
git commit -m "feat(quebec-legal-entity): add quebec-grants skill (grant advisory)"
```

---

## Chunk 2: README Update and Validation

### Task 4: Update README.md

**Files:**

- Modify: `quebec-legal-entity/README.md`

- [ ] **Step 1: Append three skill entries to README.md**

Append the following content to `quebec-legal-entity/README.md` immediately
before the `## Progress Tracking` section:

```markdown
### `/quebec-legal-entity:quebec-land-access`

**Purpose:** Interactive guide for negotiating and recording droits de passage
(land access agreements) with private landowners for Quebec snowmobile trail
networks. Covers trail inventory, cadastral landowner identification, FCMQ
standard agreement templates, priority agreement negotiation, and annual
renewal tracking. Without signed agreements, trails cross private land without
legal basis.

**Tags used:** `[SECTOR-SPECIFIC]`

**Creates:** `qc-land-access.md`

**Depends on:** `quebec-snowmobile-club` (SNOW-01 must be submitted)

---

### `/quebec-legal-entity:quebec-mrc-permits`

**Purpose:** Guide for obtaining MRC and municipal authorizations for Quebec
snowmobile trail infrastructure. Covers MRC trail corridor authorization
(schéma d'aménagement), municipal road crossing permits, signage permits, and
grooming depot construction permits where required. Requirements vary
significantly by MRC — always consult the FCMQ regional representative first.

**Tags used:** `[SECTOR-SPECIFIC]`

**Creates:** `qc-mrc-permits.md`

**Depends on:** `quebec-snowmobile-club` (SNOW-01 must be submitted)

---

### `/quebec-legal-entity:quebec-grants`

**Purpose:** Advisory guide for grant programs available to Quebec snowmobile
clubs beyond MTQ/PACM (which is covered in `quebec-snowmobile-club` SNOW-03).
Covers Tourisme Québec PAIR (spring window), MRC Fonds de développement des
territoires (FDT), Canada Summer Jobs (November application), Sport Canada /
Canadian Heritage programs, and foundation programs. Tracks application windows
and outcomes in a Program Tracker.

**Tags used:** `[SECTOR-SPECIFIC]`

**Creates:** `qc-grants.md`

**Depends on:** `quebec-snowmobile-club` (FCMQ membership required for most programs)

---
```

- [ ] **Step 2: Validate file format**

Run markdownlint on the updated README:

```bash
npx markdownlint-cli2 "quebec-legal-entity/README.md"
```

Expected: no errors. If errors appear, fix indentation or heading levels.

- [ ] **Step 3: Run plugin validator**

Invoke the `plugin-dev:plugin-validator` agent to verify the plugin structure
is correct after adding the three new skills.

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/README.md
git commit -m "docs(quebec-legal-entity): add batch B skills to README (land-access, mrc-permits, grants)"
```

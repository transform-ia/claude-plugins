# Batch C — Cross-Cutting Compliance Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three cross-cutting compliance skills to the `quebec-legal-entity` plugin: `quebec-privacy` (Law 25 privacy compliance), `quebec-trademark` (trademark advisory), and `quebec-construction-permits` (RBQ/CCQ permits). These skills apply to any Quebec entity regardless of sector or structure and have no dependencies on other skills.

**Architecture:** Each skill is a directory under `quebec-legal-entity/skills/<name>/` containing `SKILL.md` (bare YAML front-matter with `---` delimiters, no code fence wrappers) and `instructions.md` (full procedural markdown). Pattern mirrors existing skills (e.g., `quebec-payroll`, `quebec-insurance`). README.md gets three new entries. No code, no tests — content files only.

**Tech Stack:** Markdown, YAML front-matter. Plugin framework expects bare `---`-delimited YAML in SKILL.md (no code fence wrappers).

**Spec:** `docs/superpowers/specs/2026-03-12-quebec-legal-entity-batch-c-compliance-design.md`

---

## Chunk 1: Three Skill Files

### Task 1: `quebec-privacy` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-privacy/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-privacy/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-privacy/SKILL.md` with exact content:

```
---
name: quebec-privacy
description: |
  Interactive guide for Quebec Law 25 (Act respecting the protection of
  personal information in the private sector) compliance.

  Covers privacy officer designation, privacy policy publication, personal
  information inventory, Privacy Impact Assessments (PIAs), breach response
  procedures, and individual rights management.

  Applies to any organization that collects, uses, or communicates personal
  information — including membership lists, employee records, and website
  analytics. All three Law 25 phases (Sept 2022, Sept 2023, Sept 2024)
  are now in effect.

  Reads and writes qc-privacy.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-privacy
  - User asks about Law 25, privacy compliance, or personal data obligations
    in Quebec
  - User is setting up a membership database, website, or any system
    collecting personal information

  DO NOT activate when:
  - User is asking about employee payroll records (covered in quebec-payroll)
  - User is asking about federal PIPEDA only (this skill covers Quebec Law 25)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-privacy.md), Edit(qc-privacy.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-privacy/instructions.md` with exact content:

````markdown
# Quebec Privacy — Law 25 Compliance Guide

This skill guides you through Law 25 (Act respecting the protection of personal
information in the private sector) compliance for a Quebec organization.

---

## On Start

1. Read `qc-status.md` for Organization name and entity type.
2. Read `qc-privacy.md` if present; create it from the template below if absent.
3. Present current status; jump to first unchecked step.

**`qc-privacy.md` template (create if absent):**

```markdown
# Privacy Compliance Status — [organization name]
schema_version: 1
Privacy_officer: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] PRV-01 — Privacy officer designated
- [ ] PRV-02 — Personal information inventory completed
- [ ] PRV-03 — Privacy policy published
- [ ] PRV-04 — Consent mechanisms implemented
- [ ] PRV-05 — PIA process established for new projects
- [ ] PRV-06 — Breach response procedure documented
- [ ] PRV-07 — Individual rights request procedure established
```

---

## NEVER / ALWAYS

### NEVER

- Tell an organization with a membership list or employee records that Law 25
  does not apply — it applies to virtually all organizations operating in Quebec
  that collect personal information, including OBNLs and recreational clubs
- Skip PRV-06 — breach notification to the CAI is mandatory and time-limited
  (72 hours for serious risk)

### ALWAYS

- At PRV-01: note that for a small OBNL, any board member can be designated
  privacy officer (personne responsable de la protection des renseignements
  personnels); it does not require a dedicated position
- At PRV-05: explain that a PIA (évaluation des facteurs relatifs à la vie
  privée) is required before implementing any new system that collects or
  processes personal information in a new way
- After PRV-01: record the privacy officer's title and contact in `qc-privacy.md`
  (Privacy_officer field)

---

## CRITICAL WARNINGS

> **Law 25 applies to OBNLs:** The law covers all organizations operating in
> Quebec that collect personal information. A snowmobile club's membership list,
> event registration, and website analytics all involve personal information.
> All three phases are now in effect (Sept 2022, Sept 2023, Sept 2024).
>
> **72-hour breach notification:** If a security incident involving personal
> information poses a serious risk of injury, notify the Commission d'accès à
> l'information (CAI) within 72 hours and notify affected individuals as soon
> as possible.
>
> **Penalties:** The CAI can impose fines up to $25,000,000 or 4% of worldwide
> turnover for serious violations.

---

## Steps

---

### PRV-01 `[GENERIC][PROV]` — Designate a privacy officer

**What to do:**
Designate a privacy officer (personne responsable de la protection des
renseignements personnels). For a small OBNL, any board member (e.g., the
Secretary or President) can take this role — it does not require a dedicated
employee.

Publish the privacy officer's title and contact information on your website.
This is a public disclosure requirement under Law 25.

**Cost:** Free
**Delay:** Immediate

**After designating:** Record the officer's name (or title) and contact in
`qc-privacy.md` (Privacy_officer field). Check `PRV-01`.

---

### PRV-02 `[GENERIC][PROV]` — Complete personal information inventory

**What to do:**
Inventory all personal information collected by your organization. For each
category, document:

- Who is the information about (members, employees, donors, website visitors)
- What information is collected (name, address, email, payment info, IP address)
- Why it is collected (purpose)
- Where it is stored (software, server location, paper files)
- How long it is retained (retention schedule)
- Who has access (staff, board members, service providers)

This inventory is the foundation for your privacy policy (PRV-03) and PIA
process (PRV-05).

**Cost:** Free (internal effort)
**Delay:** 1–4 weeks

**After completing inventory:** Check `PRV-02` in `qc-privacy.md`.

---

### PRV-03 `[GENERIC][PROV]` — Publish a privacy policy

**What to do:**
Publish a privacy policy on your website describing:

- What personal information is collected and why
- How it is used and to whom it may be disclosed
- How long it is retained
- How individuals can access or correct their information
- The privacy officer's contact information

The policy must be written in plain language and accessible to anyone who
interacts with your organization.

**Cost:** Free (internal effort); $0–$500 for legal review
**Delay:** 1–2 weeks

**After publishing:** Record the URL or location in `qc-privacy.md`. Check `PRV-03`.

---

### PRV-04 `[GENERIC][PROV]` — Implement consent mechanisms

**What to do:**
Implement appropriate consent mechanisms based on the sensitivity of the
information and how it is used:

- **Explicit consent:** Required for sensitive personal information (health,
  financial, biometric data) and for secondary uses beyond the original purpose
- **Opt-out:** Acceptable for cookies, analytics, and non-sensitive marketing
  communications — but an opt-out mechanism must be clearly provided
- **Parental consent:** Required for collecting personal information from
  minors under 14

Review your website, registration forms, and member onboarding for gaps.

**Cost:** Free–$500 (depending on website update complexity)
**Delay:** 1–4 weeks

**After implementing:** Check `PRV-04` in `qc-privacy.md`.

---

### PRV-05 `[GENERIC][PROV]` — Establish PIA process for new projects

**What to do:**
Establish a process to conduct a Privacy Impact Assessment (évaluation des
facteurs relatifs à la vie privée / EFVP) before implementing any new project
that involves collecting or processing personal information in a new way.

A PIA must be completed before:

- Launching a new website feature that collects personal information
- Adopting new software that stores or processes member data
- Partnering with a third party that will have access to personal information
- Communicating personal information outside Quebec

The PIA identifies risks and required safeguards before the project begins —
not after.

**Cost:** Free (internal effort)
**Delay:** Before next project

**After establishing process:** Document the PIA checklist or procedure.
Check `PRV-05` in `qc-privacy.md`.

---

### PRV-06 `[GENERIC][PROV]` — Document breach response procedure

**What to do:**
Document a security incident response procedure that addresses the mandatory
breach notification obligations under Law 25:

1. **Detection and containment:** Who is responsible for identifying a breach
   and taking immediate containment steps
2. **Risk assessment:** Determine whether the incident poses a serious risk of
   injury to the affected individuals (identity theft, discrimination, loss,
   damage, distress)
3. **CAI notification:** If serious risk is identified, notify the Commission
   d'accès à l'information (CAI) **within 72 hours** via cai.gouv.qc.ca
4. **Individual notification:** Notify affected individuals as soon as
   feasible when serious risk is confirmed
5. **Incident register:** All incidents involving personal information must be
   logged in an incident register (registre des incidents), regardless of
   whether they trigger notification

**Cost:** Free (internal effort)
**Delay:** 1 week

**After documenting procedure:** Check `PRV-06` in `qc-privacy.md`.

---

### PRV-07 `[GENERIC][PROV]` — Establish individual rights request procedure

**What to do:**
Establish a procedure for handling requests from individuals exercising their
rights under Law 25:

- **Right of access:** An individual may request access to their personal
  information held by your organization
- **Right of rectification:** An individual may request correction of inaccurate
  information
- **Right to withdrawal of consent:** An individual may withdraw consent for
  collection or use of their information
- **Response deadline:** You must respond within **30 days** of receiving a
  request

Document who handles requests, how requests are submitted (form, email, in
writing), how identity is verified, and how responses are issued.

**Cost:** Free (internal effort)
**Delay:** 1 week

**After establishing procedure:** Check `PRV-07` in `qc-privacy.md`.

---

## Completion

When all PRV steps are checked, update `qc-status.md`:
`- [x] quebec-privacy — completed [YYYY-MM-DD]`

Then prompt: "Law 25 compliance framework is in place. Revisit annually:
re-run the PIA for any new systems (PRV-05) and update the privacy policy
when data practices change (PRV-03). If a security incident occurs, follow
the breach response procedure (PRV-06) — the 72-hour CAI notification window
is mandatory."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-privacy/
git commit -m "feat(quebec-legal-entity): add quebec-privacy skill (Law 25 compliance)"
```

---

### Task 2: `quebec-trademark` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-trademark/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-trademark/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-trademark/SKILL.md` with exact content:

```
---
name: quebec-trademark
description: |
  Advisory guide for trademark registration to protect your organization's
  name and logo beyond REQ name registration.

  REQ registration reserves a name in Quebec's corporate registry but does
  not give trademark rights. Trademark registration with CIPO (Canadian
  Intellectual Property Office) provides nationwide protection.

  This is an advisory skill — it guides the decision and documents choices
  in qc-trademark.md.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-trademark
  - User asks about protecting their organization's name or logo
  - User wants to understand trademark vs REQ name registration

  DO NOT activate when:
  - User is asking about REQ name reservation (use quebec-incorporation)
  - User already has trademark counsel handling this
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-trademark.md), Edit(qc-trademark.md), AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-trademark/instructions.md` with exact content:

````markdown
# Quebec Trademark — Advisory Guide

This skill guides you through trademark registration decisions to protect your
organization's name and logo. It is advisory — it helps you decide whether and
how to file, and records those decisions.

---

## On Start

1. Read `qc-status.md` for Organization name.
2. Read `qc-trademark.md` if present; create it from the template below if absent.
3. Show current decisions; walk through any undecided sections.
4. Ask: "Walk through all sections, or jump to a specific one?"

**`qc-trademark.md` template (create if absent):**

```markdown
# Trademark Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| TM-01 Need assessment | pending | — |
| TM-02 CIPO search | pending | — |
| TM-03 Application filed | pending | — |
| TM-04 Registration confirmed | pending | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user that REQ name registration provides trademark protection — it
  does not; REQ prevents another corporation from incorporating under the same
  name in Quebec only, and gives no trademark rights whatsoever
- Recommend filing a trademark application before completing the CIPO search
  (TM-02) — a conflicting prior mark discovered after filing wastes the
  application fee and may require abandonment

### ALWAYS

- At TM-01: explain that most small local OBNLs and recreational clubs do not
  need trademark registration; it is warranted for distinctive brands with
  commercial value or regional/national expansion plans
- At TM-02: direct the user to trademarks.ic.gc.ca for the free public
  trademark search before deciding to file

---

## CRITICAL WARNING

> **REQ registration is not trademark protection:** Registering a name at the
> REQ prevents another corporation from incorporating under the same name in
> Quebec, but gives no trademark rights. A competitor can use your name as a
> common law mark or domain name without infringing your REQ registration. Only
> a registered trademark with CIPO gives nationwide enforceable brand protection.

---

## Advisory Sections

For each section: explain the topic, discuss the decision, and record it in
`qc-trademark.md`.

---

### TM-01 — Need assessment

**Question to address:** Is trademark registration warranted for this organization?

**Factors that favour registration:**

- The name or logo is distinctive and not purely descriptive
- The organization plans to expand beyond a single local area
- There is commercial value in the brand (merchandise, licensing, franchising)
- There is a risk of competitors using a similar name nationally

**Factors that suggest registration is not needed:**

- The organization is a small local OBNL with no expansion plans
- The name is purely descriptive of the activity (e.g., "Club de motoneige de
  Sainte-Marie") — these are difficult to register anyway
- The organization has no budget for the application fee and maintenance

**Typical outcome for small recreational clubs:** Registration is not required.
Document the decision and rationale in `qc-trademark.md`.

---

### TM-02 — CIPO trademark search

**Complete this before filing any application.**

Search the Canadian Trademarks Database for conflicting marks:

- **Where:** trademarks.ic.gc.ca — free public search
- **What to search:** Your organization's name, logo descriptors, and close
  variants
- **What to look for:** Identical or confusingly similar marks in overlapping
  goods/services classes

If a conflicting mark is found, reassess whether to proceed (different name,
different class, or abandon the trademark plan) before spending money on an
application.

**Cost:** Free
**Delay:** 1–2 hours

Record the search result (conflict found / no conflict found) in `qc-trademark.md`.

---

### TM-03 — CIPO application

**Only proceed after TM-02 confirms no blocking conflict.**

**Application details:**

- **Where to file:** trademarks.ic.gc.ca (online filing recommended)
- **Fee:** ~$458 for the first class online; ~$125 per additional class
- **Processing time:** 18–36 months (examination, publication, opposition period)
- **Basis:** Use in Canada, proposed use, or foreign registration (Paris
  Convention / Madrid Protocol)
- **Madrid Protocol:** Available if you want to extend the mark internationally
  in one application; consult a trademark agent for multi-country strategies

**Recommendation:** For organizations new to trademark filing, engaging a
registered trademark agent (agent de marques de commerce) reduces the risk of
procedural errors that delay or void the application.

Record the application number and filing date in `qc-trademark.md` once filed.

---

### TM-04 — Registration confirmed

**Once the application clears examination, publication, and the opposition
period, CIPO issues a Certificate of Registration.**

**After registration:**

- Use the ® symbol with the mark (use ™ before registration)
- The registration is valid for **10 years** and renewable indefinitely
- Enforce against infringers — a registered trademark gives you the right to
  sue for infringement in Federal Court
- Update `qc-trademark.md` with the registration number and expiry date

Record registration number and renewal date in `qc-trademark.md`.

---

## Completion

When all TM sections have been decided (including explicit "not applicable"
decisions for sections where registration was declined), update `qc-status.md`:
`- [x] quebec-trademark — completed [YYYY-MM-DD]`

Then prompt: "Trademark decisions are logged. If you filed an application
(TM-03), set a reminder to follow up with CIPO in 18 months and to renew
the registration before the 10-year expiry (TM-04)."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-trademark/
git commit -m "feat(quebec-legal-entity): add quebec-trademark skill (advisory)"
```

---

### Task 3: `quebec-construction-permits` skill

**Files:**

- Create: `quebec-legal-entity/skills/quebec-construction-permits/SKILL.md`
- Create: `quebec-legal-entity/skills/quebec-construction-permits/instructions.md`

- [ ] **Step 1: Create SKILL.md**

Create `quebec-legal-entity/skills/quebec-construction-permits/SKILL.md` with exact content:

```
---
name: quebec-construction-permits
description: |
  Guide for RBQ (Régie du bâtiment du Québec) and CCQ (Commission de la
  construction du Québec) permit and compliance requirements when a Quebec
  entity undertakes construction work.

  Covers RBQ building permit verification, contractor license requirements,
  CCQ construction work classification, and municipal building permits for
  club infrastructure (grooming depots, chalets, storage buildings).

  Reads and writes qc-construction-permits.md to track progress and log
  permits obtained.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-construction-permits
  - User is planning to build, renovate, or install fixed infrastructure
    (buildings, electrical, plumbing)
  - User is hiring contractors for construction work in Quebec

  DO NOT activate when:
  - User is asking about trail permits and MRC authorizations (use
    quebec-mrc-permits)
  - User is doing routine trail maintenance without fixed structures
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-construction-permits.md), Edit(qc-construction-permits.md),
  AskUserQuestion
---
```

- [ ] **Step 2: Create instructions.md**

Create `quebec-legal-entity/skills/quebec-construction-permits/instructions.md` with exact content:

````markdown
# Quebec Construction Permits — RBQ and CCQ Compliance

This skill guides you through building permit and contractor compliance
requirements for a Quebec entity undertaking construction work.

---

## On Start

1. Read `qc-status.md` for Organization name.
2. Read `qc-construction-permits.md` if present; create it from the template
   below if absent.
3. Ask: "What type of construction project are you planning?" to scope the
   applicable steps (new building, renovation, electrical/plumbing, storage
   structure, etc.).
4. Present current status; jump to first unchecked step.

**`qc-construction-permits.md` template (create if absent):**

```markdown
# Construction Permits Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps
- [ ] CON-01 — Scope of work defined (building type, size, location)
- [ ] CON-02 — Municipal building permit applied for
- [ ] CON-03 — RBQ contractor license verified for all contractors
- [ ] CON-04 — CCQ jurisdiction confirmed

## Permit Log

| Project | Permit type | Authority | Status | Issued | Expiry |
| --- | --- | --- | --- | --- | --- |
| — | — | — | pending | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user that hiring a non-union contractor exempts them from CCQ
  requirements — CCQ jurisdiction is based on the *type of work* (covered
  construction trades: electrical, plumbing, carpentry, masonry, etc.),
  not on the union status of the contractor
- Allow the user to skip CON-03 (RBQ license verification) — hiring an
  unlicensed contractor creates owner liability regardless of contract terms
  or what the contractor claims

### ALWAYS

- At CON-03: direct the user to rbq.gouv.qc.ca for the free public contractor
  license search before any contractor begins work; the search takes minutes
  and is the owner's responsibility
- At CON-04: confirm whether the work type falls under covered construction
  trades (electrical, plumbing, carpentry, masonry, roofing, etc.) — if yes,
  CCQ obligations apply regardless of contractor union status; direct user to
  ccq.org for sector-specific determination

---

## CRITICAL WARNINGS

> **RBQ license is mandatory:** All contractors performing work covered by the
> Building Act (Loi sur le bâtiment) — including electrical, plumbing,
> structural, and mechanical work — must hold a valid RBQ license. As the owner,
> you can face fines and insurance voidance if you hire an unlicensed contractor,
> even if you did not know the contractor was unlicensed. Verify at rbq.gouv.qc.ca
> before signing any contract.
>
> **CCQ applies by work type, not union status:** If a contractor performs work
> covered by a CCQ construction collective agreement (electrical, plumbing,
> carpentry, masonry, roofing, etc.), CCQ obligations apply even if the
> contractor is not unionized. This includes wage rates, working hours, and
> worker classifications. Verify at ccq.org.
>
> **Small and temporary structures:** Temporary or small structures may be exempt
> from municipal building permits but still must comply with the National Building
> Code of Canada. Check with your municipality before assuming an exemption applies.

---

## Steps

---

### CON-01 `[GENERIC][PROV]` — Define scope of work

**What to do:**
Define the full scope of the construction project before engaging contractors
or applying for permits:

- Type of structure (new building, addition, renovation, storage shed, electrical
  upgrade, plumbing installation)
- Gross floor area (m²) — determines permit class and fee tier
- Location (municipal address or lot description; proximity to wetlands,
  agricultural zones, or protected areas may trigger additional authorizations)
- Whether the structure will be permanent or temporary
- Whether the work involves regulated trades (electrical, plumbing, structural)

This scoping determines which of CON-02 through CON-04 apply to your project.

**Cost:** Free
**Delay:** 1 week (internal planning)

**After scoping:** Check `CON-01` in `qc-construction-permits.md`.

---

### CON-02 `[GENERIC][MUNIC]` — Apply for municipal building permit

**What to do:**
Apply for a permis de construction from the local municipality. A municipal
building permit is required for most fixed structures — new buildings,
additions, significant renovations, and changes of use.

**Process:**

1. Contact your municipality's service d'urbanisme to confirm whether a permit
   is required for your specific project
2. Submit plans (site plan, floor plans, elevations) as required
3. Pay the municipal permit fee
4. Wait for approval before beginning work

**Fee:** Typically $500–$5,000 depending on project size and municipality —
fees are usually calculated per $1,000 of construction value or per m²

**Delay:** 4–12 weeks for review and approval; larger projects may take longer

**After permit is issued:** Add to the Permit Log in `qc-construction-permits.md`
(Project, Permit type: "Municipal building permit", Authority: municipality name,
Status: issued, Issued date, Expiry date). Check `CON-02`.

---

### CON-03 `[GENERIC][PROV]` — Verify RBQ contractor license

**What to do:**
Before signing any contract with a contractor for covered construction work,
verify that the contractor holds a valid RBQ (Régie du bâtiment du Québec) license.

**Where:** rbq.gouv.qc.ca → "Vérifier une licence" — free public search

**What to verify:**

- The contractor's license number matches the license on the RBQ registry
- The license is currently active (not expired, suspended, or cancelled)
- The license class covers the type of work to be performed
  (e.g., general contractor, electrical subcontractor, plumbing subcontractor)

**Owner liability:** As the owner, you are responsible for ensuring your
contractors are licensed. Hiring an unlicensed contractor can void your
property insurance and expose you to fines under the Building Act.

**Cost:** Free (verification only)
**Delay:** Before hiring (takes minutes)

**After verifying all contractors:** Record each contractor's name, license
number, and license class in `qc-construction-permits.md`. Check `CON-03`.

---

### CON-04 `[GENERIC][PROV]` — Confirm CCQ jurisdiction

**What to do:**
Determine whether the construction work falls under the jurisdiction of the
Commission de la construction du Québec (CCQ).

CCQ jurisdiction applies based on the **type of work**, not the union status
of the contractor. Covered construction trades include:

- Electrical work
- Plumbing and mechanical
- Carpentry and joinery
- Masonry and concrete work
- Roofing
- Ironwork and structural steel
- Painting and finishing in a construction context

**If the work is covered:**

- Contractors must comply with the applicable CCQ collective agreement for
  that trade sector
- Workers must be registered with the CCQ and hold a CCQ competency card
- Wage rates, working hours, and worker classifications are governed by the
  CCQ collective agreement — not by the individual employment contract

**If the work is not covered** (e.g., owner-performed work, landscaping,
minor maintenance below thresholds): document the determination.

**Where to confirm:** ccq.org → sector determination tool, or call
CCQ at 1-888-842-8282

**Cost:** Free (determination only)
**Delay:** Before work starts

**After confirming:** Record the CCQ determination in `qc-construction-permits.md`.
Check `CON-04`.

---

## Completion

When CON-01 through CON-04 are checked (or explicitly marked N/A with reason
where not applicable), update `qc-status.md`:
`- [x] quebec-construction-permits — completed [YYYY-MM-DD]`

Then prompt: "Construction permit compliance is documented. Update the Permit
Log when new permits are obtained and when expiry or renewal dates approach.
If additional projects arise, re-run this skill starting from CON-01 to scope
the new work."
````

- [ ] **Step 3: Commit**

```bash
git add quebec-legal-entity/skills/quebec-construction-permits/
git commit -m "feat(quebec-legal-entity): add quebec-construction-permits skill (RBQ/CCQ)"
```

---

## Chunk 2: README Update and Validation

### Task 4: Update README.md

**Files:**

- Modify: `quebec-legal-entity/README.md`

- [ ] **Step 1: Insert three skill entries before the `## Progress Tracking` section**

Insert the following content in `quebec-legal-entity/README.md` immediately
before the `## Progress Tracking` section:

```markdown
### `/quebec-legal-entity:quebec-privacy`

**Purpose:** Law 25 (Act respecting the protection of personal information in
the private sector) compliance guide. Covers privacy officer designation,
personal information inventory, privacy policy publication, consent mechanisms,
Privacy Impact Assessments (PIAs), breach response (72-hour CAI notification),
and individual rights procedures. Applies to any organization that collects
personal information — including membership lists, website analytics, and
employee records. All three Law 25 phases (Sept 2022, Sept 2023, Sept 2024)
are in effect.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-privacy.md`

---

### `/quebec-legal-entity:quebec-trademark`

**Purpose:** Advisory trademark registration guide. Explains the distinction
between REQ name registration (corporate registry only, no trademark rights)
and CIPO trademark registration (nationwide brand protection). Covers need
assessment, CIPO database search, application (~$458 first class online),
and post-registration maintenance. Most small local OBNLs do not need
trademark registration; the skill helps assess and document the decision.

**Tags used:** `[GENERIC]`

**Creates:** `qc-trademark.md`

---

### `/quebec-legal-entity:quebec-construction-permits`

**Purpose:** RBQ and CCQ compliance guide for Quebec entities undertaking
construction work. Covers scope definition, municipal building permit
application, RBQ contractor license verification (mandatory; owner liability
for unlicensed contractors), and CCQ jurisdiction confirmation (applies by
type of work, not union status). Includes a Permit Log for tracking issued
permits and expiry dates.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-construction-permits.md`

---
```

- [ ] **Step 2: Validate file format**

Run markdownlint on the updated README:

```bash
npx markdownlint-cli2 "quebec-legal-entity/README.md"
```

Expected: no errors. If errors appear, fix indentation or heading levels before proceeding.

- [ ] **Step 3: Run plugin validator**

Invoke the `plugin-dev:plugin-validator` agent to verify the plugin structure
is correct after adding the three new skills.

- [ ] **Step 4: Commit**

```bash
git add quebec-legal-entity/README.md
git commit -m "docs(quebec-legal-entity): add batch C skills to README (privacy, trademark, construction-permits)"
```

---

## File Summary

| File | Action |
| --- | --- |
| `quebec-legal-entity/skills/quebec-privacy/SKILL.md` | Create |
| `quebec-legal-entity/skills/quebec-privacy/instructions.md` | Create |
| `quebec-legal-entity/skills/quebec-trademark/SKILL.md` | Create |
| `quebec-legal-entity/skills/quebec-trademark/instructions.md` | Create |
| `quebec-legal-entity/skills/quebec-construction-permits/SKILL.md` | Create |
| `quebec-legal-entity/skills/quebec-construction-permits/instructions.md` | Create |
| `quebec-legal-entity/README.md` | Modify (insert 3 entries before `## Progress Tracking`) |

Total: 6 new files, 1 modified file.

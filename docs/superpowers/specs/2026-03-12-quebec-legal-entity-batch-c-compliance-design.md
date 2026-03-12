# Batch C — Cross-Cutting Compliance Design Spec

## Overview

Three new skills covering compliance obligations that apply to any Quebec entity
regardless of sector or structure.

**Skills:**

1. `quebec-privacy` — Quebec Law 25 privacy compliance
2. `quebec-trademark` — Trademark registration beyond REQ name protection
3. `quebec-construction-permits` — RBQ/CCQ permits for infrastructure work

**Dependencies:** None. Each skill can be run independently at any time after
entity formation.

---

## File structure per skill

Each skill is a directory under `quebec-legal-entity/skills/<name>/` containing:

- **SKILL.md** — YAML front-matter activation header with `---` delimiters.
- **instructions.md** — Procedural content: On Start, state file template,
  NEVER/ALWAYS, steps/sections, key warnings, completion block.

---

## State Files

| Skill | State file | Type |
| --- | --- | --- |
| `quebec-privacy` | `qc-privacy.md` | Sequential steps |
| `quebec-trademark` | `qc-trademark.md` | Advisory decisions log |
| `quebec-construction-permits` | `qc-construction-permits.md` | Sequential steps + permit log |

---

## Skill 1: `quebec-privacy`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md` for Organization name and entity type.
2. Read `qc-privacy.md`; create from template if absent.
3. Present current status; jump to first unchecked step.

**State file template (`qc-privacy.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell an organization with a membership list or employee records that Law 25
  does not apply — it applies to virtually all organizations operating in Quebec
- Skip PRV-06 — breach notification to the CAI is mandatory and time-limited
  (72 hours for serious risk)

ALWAYS:
- At PRV-01: note that for a small OBNL, any board member can be designated
  privacy officer; it does not require a dedicated position
- At PRV-05: explain that a PIA is required before implementing any new system
  that collects or processes personal information in a new way
- After PRV-01: record the privacy officer's title and contact in `qc-privacy.md`

**Steps:**

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| PRV-01 | Designate a privacy officer (personne responsable de la protection des renseignements personnels); publish their title and contact on website | Free | Immediate |
| PRV-02 | Inventory all personal information collected: who, what, why, where stored, how long retained, who has access | Free | 1–4 weeks |
| PRV-03 | Publish a privacy policy on website describing collection, use, disclosure, retention, and rights | Free ($0–$500 legal review) | 1–2 weeks |
| PRV-04 | Implement consent mechanisms: explicit consent for sensitive data; opt-out for cookies/analytics; parental consent for minors | Free–$500 | 1–4 weeks |
| PRV-05 | Establish PIA (évaluation des facteurs relatifs à la vie privée) process for any new project involving personal data | Free | Before next project |
| PRV-06 | Document breach response: detection, containment, notification to Commission d'accès à l'information (CAI) within 72 hours if serious | Free | 1 week |
| PRV-07 | Establish procedure for individual access and rectification requests; must respond within 30 days | Free | 1 week |

**Key Warnings:**

> **Law 25 applies to OBNLs:** The law covers all organizations operating in
> Quebec that collect personal information. A snowmobile club's membership list,
> event registration, and website analytics all involve personal information.
>
> **72-hour breach notification:** If a security incident involving personal
> information poses a serious risk of injury, notify the CAI within 72 hours
> and notify affected individuals as soon as possible.
>
> **Penalties:** The Commission d'accès à l'information (CAI) can impose fines
> up to $25,000,000 or 4% of worldwide turnover for serious violations.

**Completion:**

When all PRV steps are checked, update `qc-status.md`:
`- [x] quebec-privacy — completed [YYYY-MM-DD]`

Then prompt: "Law 25 compliance framework is in place. Revisit annually:
re-run the PIA for any new systems (PRV-05) and update the privacy policy
when data practices change."

---

## Skill 2: `quebec-trademark`

### SKILL.md

```markdown
---
name: quebec-trademark
description: |
  Advisory guide for trademark registration to protect your organization's
  name and logo beyond REQ name registration.

  REQ registration reserves a name in Quebec's corporate registry but does
  not give trademark rights. Trademark registration with CIPO (Canadian
  Intellectual Property Office) provides nationwide protection.

  This is an advisory skill — it guides the decision and documents choices.

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

### instructions.md content

**On Start:**

1. Read `qc-status.md` for Organization name.
2. Read `qc-trademark.md`; create from template if absent.
3. Show current decisions; walk through any undecided sections.
4. Ask: "Walk through all sections, or jump to a specific one?"

**State file template (`qc-trademark.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell the user that REQ name registration provides trademark protection — it
  does not; REQ prevents duplicate corporate names only
- Recommend filing a trademark application before completing the CIPO search
  (TM-02) — a conflicting prior mark discovered after filing wastes the fee

ALWAYS:
- At TM-01: explain that most small local OBNLs and recreational clubs do not
  need trademark registration; it is warranted for distinctive brands with
  commercial value or regional expansion plans
- At TM-02: direct user to trademarks.ic.gc.ca for the free public search

**Advisory Sections:**

| Section | Content |
| --- | --- |
| TM-01 | Assess need: is the name distinctive? Is there commercial value in protecting it nationally? Local-only OBNLs typically do not need trademark registration |
| TM-02 | CIPO trademark search (trademarks.ic.gc.ca — free public search) to check for conflicting marks before filing |
| TM-03 | CIPO application: ~$458 (online, first class) + ~$125/additional class; 18–36 month processing; Madrid Protocol available for international extension |
| TM-04 | Once registered: 10-year term renewable; use ® symbol; enforce against infringers |

**Key Warning:**

> **REQ ≠ trademark:** Registering a name at the REQ prevents another corporation
> from incorporating under the same name in Quebec, but gives no trademark rights.
> A competitor can use your name as a common law mark or domain without infringing
> your REQ registration.

**Completion:**

When all TM sections have been decided, update `qc-status.md`:
`- [x] quebec-trademark — completed [YYYY-MM-DD]`

Then prompt: "Trademark decisions are logged. If you filed an application
(TM-03), set a reminder to follow up with CIPO in 18 months."

---

## Skill 3: `quebec-construction-permits`

### SKILL.md

```markdown
---
name: quebec-construction-permits
description: |
  Guide for RBQ (Régie du bâtiment du Québec) and CCQ (Commission de la
  construction du Québec) permit and compliance requirements when a Quebec
  entity undertakes construction work.

  Covers RBQ building permit verification, contractor license requirements,
  CCQ construction work classification, and municipal building permits for
  club infrastructure (grooming depots, chalets, storage buildings).

  Reads and writes qc-construction-permits.md to track progress.

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

### instructions.md content

**On Start:**

1. Read `qc-status.md` for Organization name.
2. Read `qc-construction-permits.md`; create from template if absent.
3. Ask: "What type of construction project are you planning?" to scope the
   applicable steps.
4. Present current status; jump to first unchecked step.

**State file template (`qc-construction-permits.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell the user that hiring a non-union contractor exempts them from CCQ
  requirements — CCQ jurisdiction is based on the *type of work* (covered
  construction trades), not on the union status of the contractor
- Allow the user to skip CON-03 (RBQ license verification) — hiring an
  unlicensed contractor creates owner liability regardless of contract terms

ALWAYS:
- At CON-03: direct user to rbq.gouv.qc.ca for the free public contractor
  license search before any contractor begins work
- At CON-04: confirm whether the work type falls under covered construction
  trades (electrical, plumbing, carpentry, masonry) — if yes, CCQ obligations
  apply regardless of contractor union status

**Steps:**

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| CON-01 | Define scope: type of structure, gross floor area, location; determine if subject to RBQ | Free | 1 week |
| CON-02 | Apply for municipal building permit (permis de construction) from local municipality; required for most fixed structures | $500–$5,000 depending on project size | 4–12 weeks |
| CON-03 | Verify all contractors hold a valid RBQ license (rbq.gouv.qc.ca — free public search); unlicensed contractors create owner liability | Free (verification) | Before hiring |
| CON-04 | Determine whether the work falls under CCQ jurisdiction (covered construction trades: electrical, plumbing, carpentry, masonry, etc.); if yes, applicable collective agreement and worker classifications apply regardless of contractor union status | Free | Before work starts |

**Key Warnings:**

> **RBQ license is mandatory:** All contractors performing work covered by the
> Building Act (electrical, plumbing, structural) must hold a valid RBQ license.
> As the owner, you can face fines and insurance voidance if you hire unlicensed
> contractors.
>
> **CCQ applies by work type, not union status:** If a contractor performs
> work covered by a CCQ construction collective agreement (electrical, plumbing,
> carpentry, etc.), CCQ obligations apply even if the contractor is not unionized.
> Verify at ccq.org.
>
> **Small and temporary structures:** Temporary or small structures may be exempt
> from municipal building permits but still must comply with the National Building
> Code. Check with your municipality.

**Completion:**

When CON-01 through CON-04 are checked (or N/A where not applicable),
update `qc-status.md`:
`- [x] quebec-construction-permits — completed [YYYY-MM-DD]`

Then prompt: "Construction permit compliance is documented. Update the Permit
Log when new permits are obtained and when expiry renewals are due."

---

## `qc-status.md` additions

```markdown
- [ ] quebec-privacy — not started
- [x] quebec-privacy — completed [YYYY-MM-DD]

- [ ] quebec-trademark — not started
- [x] quebec-trademark — completed [YYYY-MM-DD]

- [ ] quebec-construction-permits — not started
- [x] quebec-construction-permits — completed [YYYY-MM-DD]
```

Initial state on first run: `not started`.

---

## File Structure

```text
quebec-legal-entity/
└── skills/
    ├── quebec-privacy/
    │   ├── SKILL.md
    │   └── instructions.md
    ├── quebec-trademark/
    │   ├── SKILL.md
    │   └── instructions.md
    └── quebec-construction-permits/
        ├── SKILL.md
        └── instructions.md
```

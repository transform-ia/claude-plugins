# Batch B — Snowmobile-Specific Additions Design Spec

## Overview

Three new skills extending the snowmobile club use case beyond the existing
`quebec-snowmobile-club` skill. These cover the operational infrastructure
that a club needs after FCMQ membership is obtained.

**Skills:**

1. `quebec-land-access` — Droits de passage agreements with private landowners
2. `quebec-mrc-permits` — MRC and municipal trail permits and authorizations
3. `quebec-grants` — Grant programs beyond MTQ/PACM

**Dependency:** All three require `quebec-snowmobile-club` to be in progress
(at minimum SNOW-01 submitted). `quebec-land-access` is the highest priority —
without signed agreements the trail network has no legal basis.

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
| `quebec-land-access` | `qc-land-access.md` | Sequential steps + agreement log |
| `quebec-mrc-permits` | `qc-mrc-permits.md` | Sequential steps + permit log |
| `quebec-grants` | `qc-grants.md` | Advisory decisions log |

---

## Skill 1: `quebec-land-access`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   tell the user: "Complete `/quebec-legal-entity:quebec-snowmobile-club` first
   — FCMQ membership (SNOW-01) must be submitted before negotiating land access."
2. Read `qc-land-access.md`; create from template if absent.
3. Present current status; jump to first unchecked step.

**State file template (`qc-land-access.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Suggest the club can open trails on private land without signed agreements —
  trespassing exposes the club and FCMQ to civil liability
- Mark LND-04 complete without recording each agreement in the Agreements Log

ALWAYS:
- At LND-02: recommend working with the local MRC cadastral office for landowner
  identification — they have the authoritative records
- At LND-04: remind the user that FCMQ regional representatives often have
  relationships with repeat landowners and can facilitate introductions
- After each agreement signed: record it in the Agreements Log in `qc-land-access.md`

**Steps:**

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| LND-01 | Map all planned trail segments; identify which cross private vs public land | Free | 1–4 weeks |
| LND-02 | Compile list of all private landowners using cadastral maps (available at MRC or MRNF); record contact info | Free | 1–2 weeks |
| LND-03 | Obtain FCMQ standard agreement template from regional FCMQ representative | Free | Immediate |
| LND-04 | Contact and negotiate with priority landowners (segments that block trail opening); sign agreements | Variable (cash, fuel, passes) | Weeks to months |
| LND-05 | Complete remaining agreements or plan alternate routes for unsigned segments | Variable | Ongoing |
| LND-06 | Establish annual renewal process; set calendar reminders for expiry dates | Free | Annual |

**Key Warnings:**

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

**Completion:**

When LND-04 and LND-05 are checked (all priority agreements signed and
remaining segments resolved), update `qc-status.md`:
`- [x] quebec-land-access — completed [YYYY-MM-DD]`

Then prompt: "Your trail network has legal land access coverage. Ongoing
obligations: renew agreements before expiry (LND-06) and record new segments
in the Agreements Log as the trail network expands."

---

## Skill 2: `quebec-mrc-permits`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   tell the user: "MRC and municipal permits require active FCMQ membership
   context. Complete `/quebec-legal-entity:quebec-snowmobile-club` first."
2. Read `qc-mrc-permits.md`; create from template if absent.
3. Present current permit status; jump to first unchecked step.

**State file template (`qc-mrc-permits.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Tell the user MRC permits are uniform across Quebec — requirements vary
  significantly by region; always direct to the local MRC planning department
- Mark MRC-02 complete without recording each crossing permit in the Permit Log

ALWAYS:
- At MRC-01: recommend consulting the FCMQ regional representative first —
  they know the MRC-specific requirements in the territory and can make
  introductions to MRC planning staff
- After each permit obtained: record it in the Permit Log with expiry date

**Steps:**

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| MRC-01 | Contact MRC planning department to understand trail corridor requirements in the regional land use plan (schéma d'aménagement); some MRCs require formal trail corridor inclusion before VHR designation | Free | 1–4 weeks |
| MRC-02 | Identify all municipal road crossings; apply for crossing permits (typically annual) | $0–$500/crossing | 2–8 weeks |
| MRC-03 | Obtain signage permits from municipality where trails pass through urban zones | Variable | 2–6 weeks |
| MRC-04 | If building a grooming depot or shelter: confirm building permit requirements from municipality | Variable | 4–12 weeks |

**Key Warning:**

> **MRC requirements vary by region:** Some MRCs require formal trail corridor
> inclusion in the schéma d'aménagement before trails can be designated under
> the VHR Act. Consult your FCMQ regional representative — they know the
> requirements in your territory.

**Completion:**

When MRC-01 through MRC-04 are checked (or marked N/A where not applicable),
update `qc-status.md`:
`- [x] quebec-mrc-permits — completed [YYYY-MM-DD]`

Then prompt: "MRC and municipal permit coverage is established. Renew
road-crossing permits annually (check Permit Log for expiry dates)."

---

## Skill 3: `quebec-grants`

### SKILL.md

```markdown
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

### instructions.md content

**On Start:**

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   warn: "Most grant programs require active FCMQ membership. Consider completing
   `/quebec-legal-entity:quebec-snowmobile-club` first. You may still review
   programs, but eligibility for most requires membership."
2. Read `qc-grants.md`; create from template if absent.
3. Show current Program Tracker; ask which sections the user wants to review.

**State file template (`qc-grants.md`):**

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

**NEVER / ALWAYS:**

NEVER:
- Present MTQ/PACM in this skill — redirect to `quebec-snowmobile-club` SNOW-03
- Mark a program as "applied" without recording the application date and
  requested amount in the Program Tracker

ALWAYS:
- After each program section: add the program to the Program Tracker with
  its window and current status
- At the end of each session: surface any programs with approaching windows
  based on the current date

**Advisory Sections:**

| Section | Content |
| --- | --- |
| GRT-01 | Tourisme Québec PAIR (Programme d'aide pour les infrastructures récréotouristiques) — grooming equipment and trail infrastructure; call for projects typically in spring (March–May) |
| GRT-02 | MRC Fonds de développement des territoires (FDT) — local discretionary funds; contact your CLD or MRC for current availability and deadlines |
| GRT-03 | Canada Summer Jobs — subsidized summer student wages; applications open in November for the following summer (federal, annual) |
| GRT-04 | Sport Canada / Canadian Heritage — Community Sport for All Initiative; eligibility requires demonstrated sport mandate; **verify program availability annually** — federal sport funding streams change between budget cycles |
| GRT-05 | Fondation Hydro-Québec, Fondation McConnell, and regional foundations — check annually for relevant calls for projects |

**Key Warning:**

> **Application windows are program-specific:** Unlike PACM's fixed June–August
> window, other programs have varying deadlines. Some require 6–12 months lead
> time for major infrastructure grants. Add each discovered program to the
> Program Tracker with its window.

**Completion:**

When all applicable programs have been reviewed and added to the Program
Tracker, update `qc-status.md`:
`- [x] quebec-grants — completed [YYYY-MM-DD]`

Then prompt: "Grant programs documented. Return to update the Program Tracker
after each application cycle and when new programs are discovered."

---

## `qc-status.md` additions

```markdown
- [ ] quebec-land-access — not started (snowmobile clubs)
- [x] quebec-land-access — completed [YYYY-MM-DD]

- [ ] quebec-mrc-permits — not started (snowmobile clubs)
- [x] quebec-mrc-permits — completed [YYYY-MM-DD]

- [ ] quebec-grants — not started (snowmobile clubs)
- [x] quebec-grants — completed [YYYY-MM-DD]
```

Initial state on first run: `not started`.

---

## File Structure

```text
quebec-legal-entity/
└── skills/
    ├── quebec-land-access/
    │   ├── SKILL.md
    │   └── instructions.md
    ├── quebec-mrc-permits/
    │   ├── SKILL.md
    │   └── instructions.md
    └── quebec-grants/
        ├── SKILL.md
        └── instructions.md
```

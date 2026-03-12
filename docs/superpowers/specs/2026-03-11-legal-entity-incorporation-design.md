# Design: legal-entity-incorporation Plugin

**Date:** 2026-03-11
**Status:** Draft

## Context

The user is registering a Quebec snowmobile trail maintenance non-profit (OBNL — Organisme à but non lucratif) in the north-west Lac Saint-Jean area between various snowmobile lodges. The organization's purpose is to build and maintain a non-federated snowmobile trail and raise funds for maintenance costs.

Two parallel goals:
1. Guide the actual Quebec OBNL registration process end-to-end
2. Build a reusable Claude Code skill capturing the process for future use

## Plugin: `legal-entity-incorporation`

**Location:** `legal-entity-incorporation/` in the claude-plugins repository.

```
legal-entity-incorporation/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── quebec-incorporation/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   ├── quebec-obnl/
│   │   ├── SKILL.md
│   │   └── instructions.md
│   └── snowmobile-club-qc/
│       ├── SKILL.md
│       └── instructions.md
└── README.md
```

## Architecture: 3-Skill Dependency Chain

Three skills form a dependency chain — each builds on the previous:

```
quebec-incorporation  →  quebec-obnl  →  snowmobile-club-qc
     [GENERIC]            [OBNL]         [SECTOR-SPECIFIC]
```

Each skill is an interactive step-by-step guide. Progress is tracked in an `obnl-status.md` state file in the user's working directory. Claude reads this file at skill start to resume where the user left off.

**Out-of-order invocation guard:** If `obnl-status.md` is absent when invoking any skill, Claude displays an onboarding message explaining the 3-skill chain and directs the user to start with `quebec-incorporation`. If required prerequisite steps are incomplete (e.g., invoking `snowmobile-club-qc` without B2 complete), Claude lists the blocking steps before proceeding.

### Step Tagging Convention

Every step is tagged to make the generic/specific separation explicit:

| Tag | Meaning |
|-----|---------|
| `[GENERIC]` | Required for any Quebec legal entity (for-profit or non-profit) |
| `[OBNL]` | Required only for non-profit organizations |
| `[SECTOR-SPECIFIC]` | Required only for snowmobile clubs |
| `[PROV]` | Provincial requirement (REQ, Revenu Québec) |
| `[FED]` | Federal requirement (CRA, Corporations Canada) |

### Step ID Convention

Steps are numbered sequentially within each skill using a `S<skill#>-<seq>` scheme to avoid implying cross-skill ordering. The letters-based aliases (A1, B1, etc.) are kept as human-readable labels alongside the canonical IDs for traceability to the research source.

---

## Skill 1: `quebec-incorporation`

**Invocation:** `/legal-entity-incorporation:quebec-incorporation`

**Purpose:** Guide through generic Quebec legal entity formation steps — applicable to any organization type.

**Prerequisite:** None. Creates `obnl-status.md` if it doesn't exist.

### SKILL.md content

```yaml
---
name: quebec-incorporation
description: |
  Interactive guide for generic Quebec legal entity formation steps.
  Applicable to any organization type (for-profit or non-profit).
  Tracks progress in obnl-status.md in the working directory.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:quebec-incorporation
  - User asks to start registering a Quebec legal entity / business / organization

  DO NOT activate when:
  - User is already past the generic steps and asking only about OBNL-specific steps
    (use quebec-obnl instead)
  - User is asking about federal incorporation (CNCA / Corporations Canada)
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---
```

### instructions.md outline

The `instructions.md` file for this skill must include:

1. **On-start logic:** Read `obnl-status.md` if present; if absent, create it with schema_version and all checkboxes unchecked. Present the current status to the user.
2. **Step-by-step prompts:** For each step below, present what to do, what documents/forms are needed, cost, and delay. Ask the user to confirm completion before marking the checkbox.
3. **Resumption logic:** If some steps are already checked, skip directly to the first unchecked step.
4. **Post-incorporation gate:** Steps S1-03 through S1-08 require letters patent and NEQ from Skill 2 step S2-05 (B2). The skill must detect if S2-05 is not yet complete and hold these steps, informing the user that they must complete `quebec-obnl` steps through S2-05 first.

### Steps

**Phase: Pre-incorporation (can be done before letters patent)**

| Step ID | Alias | Action | Tags | Cost (2025) | Delay |
|---------|-------|--------|------|-------------|-------|
| S1-01 | A2a (name search) | Name search at REQ (registreentreprises.gouv.qc.ca) | `[GENERIC][PROV]` | Free | Immediate |
| S1-02 | A2b (name reservation) | Name reservation — optional, 90-day hold | `[GENERIC][PROV]` | $27 regular / $40.50 priority | 2–5 bus. days |

**Phase: Post-incorporation (requires letters patent + NEQ from Skill 2 step B2)**

| Step ID | Alias | Action | Tags | Cost (2025) | Delay |
|---------|-------|--------|------|-------------|-------|
| S1-03 | D1 | Initial declaration to REQ within 60 days of letters patent | `[GENERIC][PROV]` | Free | Immediate online |
| S1-04 | D2 | GST/QST registration with Revenu Québec (if taxable supplies >$30K/year) | `[GENERIC][PROV][FED]` | Free | 2–4 weeks |
| S1-05 | D6 | CRA Business Number (BN) — obtained concurrently with D2 | `[GENERIC][FED]` | Free | Concurrent with S1-04 |
| S1-06 | D3 | Source deduction registration (if hiring employees) | `[GENERIC][PROV][FED]` | Free | Before first payroll |
| S1-07 | F1 | Open business bank account | `[GENERIC]` | $0–$25/month | 1–2 weeks |
| S1-08 | G1 | Annual REQ update declaration — recurring obligation from year 1 | `[GENERIC][PROV]` | $41 / $61.50 priority | Annual (REQ sends notice) |

### Notes

- S1-01/S1-02: Name must comply with Charter of the French Language (French-first)
- S1-02 is optional but recommended to protect the name during drafting
- S1-03 is mandatory; penalty for late filing (50% surcharge + interest)
- S1-04 threshold: mandatory if worldwide taxable supplies exceed $30,000 in one quarter or four consecutive quarters
- S1-07 requires: letters patent, NEQ, by-laws, constitutive assembly minutes, ID of signatories
- S1-08 is a recurring annual obligation; Claude should record the registration date and remind the user each year

---

## Skill 2: `quebec-obnl`

**Invocation:** `/legal-entity-incorporation:quebec-obnl`

**Purpose:** Guide through OBNL-specific incorporation steps under Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

**Prerequisite:** Skill 1 steps S1-01 complete (name confirmed available). Skill checks `obnl-status.md` at start and lists blocking steps if prerequisites are missing.

### Why Quebec Part III (not federal CNCA)?

| Criterion | Quebec Part III | Federal CNCA |
|-----------|----------------|--------------|
| Scope | Quebec only | Multi-provincial |
| Processing | ~10 bus. days | 1–5 bus. days |
| Cost | $199 regular | ~$200–250 |
| Annual fee | ~$41 | ~$20–40 |
| Minimum founders | 3 | 1 |
| Extra REQ registration | No (included) | Yes (+cost) |
| Quebec civil law | Fully compatible | Common law with adaptations |

**Decision: Quebec Part III** — all activities are Quebec-based, single registration gives both incorporation and NEQ simultaneously, used by ~197 FCMQ-member clubs.

### SKILL.md content

```yaml
---
name: quebec-obnl
description: |
  Interactive guide for incorporating a Quebec non-profit (OBNL) under
  the Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

  Assumes quebec-incorporation skill has been started (name search done).
  Reads and updates obnl-status.md to track progress.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:quebec-obnl
  - User is specifically registering a Quebec non-profit/OBNL/organisme
    sans but lucratif and has completed the name search step

  DO NOT activate when:
  - User wants generic Quebec entity registration (use quebec-incorporation)
  - User wants federal non-profit registration (Canada CNCA / Corporations Canada)
  - User is asking only about snowmobile sector steps (use snowmobile-club-qc)
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---
```

### instructions.md outline

1. **On-start logic:** Read `obnl-status.md`; check schema_version. Verify S1-01 is complete. If not, block and list prerequisite. Present current OBNL phase status.
2. **Step-by-step prompts:** Present each step with action, required documents, cost, delay, and warnings. Ask the user to confirm before marking complete.
3. **Resumption:** Skip to first unchecked step.
4. **Critical warning placement:** Dissolution clause and director liability warnings must be shown before step S2-03 (by-laws drafting).
5. **Milestone notification:** When S2-05 (letters patent + NEQ) is marked complete, instruct the user to update `obnl-status.md` with the NEQ number and B2_date, and to proceed with Skill 1 post-incorporation steps S1-03 through S1-07. S1-08 (annual REQ update) is a recurring obligation that becomes relevant only after the first full year; defer its prompt to then.

### Steps

| Step ID | Alias | Action | Tags | Cost (2025) | Delay |
|---------|-------|--------|------|-------------|-------|
| S2-01 | A1 | Confirm 3+ founding members (natural persons); define organization name, mission, territory | `[OBNL][PROV]` | Free | 1–4 weeks |
| S2-02 | A3 | Draft RE-303 form ("Demande de constitution en personne morale sans but lucratif") + sworn declaration (déclaration sous serment) before commissioner of oaths or notary | `[OBNL][PROV]` | $0–$100 (notarization) | 1–3 weeks |
| S2-03 | A4 | Draft by-laws (règlements administratifs) — MUST include dissolution clause (assets to another OBNL on dissolution, not to members) | `[OBNL][PROV]` | $0 DIY / $500–2,000 lawyer | 1–4 weeks |
| S2-04 | B1 | File RE-303 with REQ by mail or in person (online not available for Part III OBNL as of 2025) | `[OBNL][PROV]` | $199 regular / $298.50 priority | 10 / 5 bus. days |
| S2-05 | B2 | Receive letters patent (Lettres patentes) and NEQ (10-digit Numéro d'entreprise du Québec) — record B2_date and NEQ in state file | `[OBNL][PROV]` | Included in S2-04 | Same as S2-04 |
| S2-06 | C1 | Hold constitutive general assembly: adopt by-laws, elect board, authorize bank account, designate signatories | `[OBNL][PROV]` | Free | Within weeks of S2-05 |
| S2-07 | C2 | Set up corporate minute book (registre): letters patent, by-laws, minutes, director register, member register | `[OBNL][PROV]` | $0–$200 | Concurrent with S2-06 |
| S2-08 | D4 | Annual CO-17.SP (Revenu Québec non-profit income tax return) — most OBNLs exempt from tax but must file | `[OBNL][PROV]` | Free to file; $500–2,000 accounting | Within 6 months of FY end |
| S2-09 | D5 | Annual T2 + T1044 NPO Information Return (CRA) — exempt under ITA 149(1)(l); T1044 if assets >$200K or revenues >$100K | `[OBNL][FED]` | Free to file; included in accounting | Within 6 months of FY end |
| S2-10 | G2 | Annual general assembly (AGA) — minimum 10 days' notice to members; approve financials, elect directors | `[OBNL][PROV]` | Free | Annual |
| S2-11 | G3 | Annual financial statements | `[OBNL]` | $500–3,000/year | Annual |
| S2-12 | G4 | Annual tax returns (CO-17.SP + T2/T1044) | `[OBNL][PROV][FED]` | Included in S2-11 | Annual |

### Critical Warnings

- **Dissolution clause is legally required:** By-laws MUST specify that remaining assets go to another OBNL with similar objectives upon dissolution — NOT to members.
- **Directors are personally liable** for unremitted source deductions and tax obligations. Proper accounting from day one.
- **All government filings must be in French.** Organization name must be French or French-first.
- **149(1)(l) NPO ≠ registered charity.** Cannot issue tax-deductible donation receipts. Normal for FCMQ-member clubs.
- **Paper submission only:** RE-303 must be filed by mail or in person (no online option as of 2025).

---

## Skill 3: `snowmobile-club-qc`

**Invocation:** `/legal-entity-incorporation:snowmobile-club-qc`

**Purpose:** Guide through snowmobile-sector-specific registrations, affiliations, and funding applications for a Quebec snowmobile club.

**Prerequisite:** Skill 2 steps S2-05 and S2-06 complete (letters patent received + constitutive assembly held). Skill checks `obnl-status.md` at start and lists blocking steps if prerequisites are missing.

### SKILL.md content

```yaml
---
name: snowmobile-club-qc
description: |
  Interactive guide for snowmobile-sector-specific steps after a Quebec
  OBNL has been incorporated: FCMQ membership, MTQ/PACM grants, VHR trail
  designation, and insurance.

  Requires quebec-obnl steps through B2/C1 to be complete (letters patent
  received, constitutive assembly held). Reads obnl-status.md.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:snowmobile-club-qc
  - User is operating a Quebec snowmobile club and has completed OBNL incorporation

  DO NOT activate when:
  - User has not yet incorporated their OBNL (use quebec-obnl first)
  - User is asking about generic incorporation (use quebec-incorporation)
  - User is asking about a different type of trail organization (ATV, cycling, etc.)
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---
```

### instructions.md outline

1. **On-start logic:** Read `obnl-status.md`; verify S2-05 and S2-06 are complete. If not, list blocking steps. Confirm NEQ is recorded.
2. **PACM calendar warning:** Prominently display the annual PACM application window (June–August) at skill start. Calculate whether the current date is inside or outside the window.
3. **Step-by-step prompts:** For each step, present action, contacts/forms, cost estimate, delay, and warnings.
4. **Resumption:** Skip to first unchecked step.

### Steps

| Step ID | Alias | Action | Tags | Cost (2025) | Delay |
|---------|-------|--------|------|-------------|-------|
| S3-01 | E1 | Apply for FCMQ membership — requires letters patent and demonstration of operating a trail network. Contact: info@fcmq.qc.ca, 418-847-0898 | `[SECTOR-SPECIFIC]` | Annual fee (confirm with FCMQ) | Application: immediate; approval: board-dependent (weeks–months) |
| S3-02 | E1b | Receive FCMQ membership approval (board decision) | `[SECTOR-SPECIFIC]` | Included in S3-01 | Concurrent with S3-01 |
| S3-03 | E2 | Apply for MTQ/PACM financial assistance — Volet 1 (trail maintenance) and Volet 2 (safety/club support via FCMQ). CRITICAL: annual window June–August | `[SECTOR-SPECIFIC]` | Free to apply | Annual window: June–August |
| S3-04 | E3 | Obtain liability insurance — FCMQ base coverage ($1M civil liability) included with membership; add D&O and equipment coverage | `[SECTOR-SPECIFIC]` | $1,500–$4,000/year estimated (contact FCMQ insurer: La Capitale / Intact for exact rates) | Concurrent with S3-01 |
| S3-05 | E4 | Obtain VHR Act trail designation from MTQ (required to legally issue droits d'accès / trail access fees) — coordinate with FCMQ | `[SECTOR-SPECIFIC]` | Variable | Variable |
| S3-06 | G5 | Annual FCMQ renewal, trail maintenance reporting, regional assembly participation (2–4 votes per club depending on size) | `[SECTOR-SPECIFIC]` | Annual membership fee | Annual |

### FCMQ Membership Details

- ~197 member clubs across Quebec; 30,000+ km trail network
- Active member clubs (membres actifs) must be legally constituted OBNLs operating a snowmobile trail network
- Membership provides: trail network access, droits d'accès revenue distribution, PACM eligibility, group insurance ($1M civil liability), technical support, grooming equipment programs

### MTQ/PACM Funding Details

- Total program budget: ~$8.2M for 2025–2026; runs through March 31, 2027
- **Volet 1** (trail maintenance): Largest component; distributed by trail-km and regional factors
- **Volet 2** (safety and club support): Administered through FCMQ
- Example: ~$545,000 distributed to Abitibi-Témiscamingue clubs in one cycle
- **CRITICAL:** Application window is June–August annually. Missing this window means waiting a full year.

### Critical Warnings

- **149(1)(l) NPO status:** Cannot issue charitable tax receipts. Expected and normal for snowmobile clubs.
- **FCMQ early contact:** Contact FCMQ before or immediately after incorporation — board meeting schedule determines admission timeline.
- **PACM calendar is fixed:** Plan first application for June–August window following FCMQ admission.
- **Trail designation before droits d'accès:** Cannot legally collect trail access fees until VHR Act designation is obtained from MTQ.

---

## State File: `obnl-status.md`

Created in the user's working directory when Skill 1 is first invoked. Updated by Claude after each confirmed step. Includes a `schema_version` for future migration handling.

```markdown
# OBNL Incorporation Status
schema_version: 1
Organization: [organization name]
NEQ: pending | [10-digit NEQ]
B2_date: [YYYY-MM-DD]            # Date letters patent received; starts 60-day D1 clock
D1_deadline: [YYYY-MM-DD]        # B2_date + 60 calendar days
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

## Total Cost Estimate

| Category | Minimum (DIY) | Recommended |
|----------|--------------|-------------|
| Startup (incorporation) | ~$200–$250 | ~$800–$2,500 |
| Annual (ongoing) | ~$540/year | ~$2,500–$5,500/year |

**Startup breakdown (recommended):**
- RE-303 filing: $199–$298.50
- Name reservation: $27–$40.50
- Notarization: $0–$100
- By-laws drafting (lawyer review): $500–$2,000
- Minute book: $0–$200
- Bank account: $0 setup

**Annual breakdown:**
- REQ update: $41
- Accounting/tax returns: $500–$3,000
- FCMQ membership: TBD (contact FCMQ)
- Additional insurance (D&O + equipment): $1,500–$4,000 estimated

*Cost estimates based on 2025 government fee schedules.*

---

## Total Timeline Estimate

| Milestone | Time from start |
|-----------|----------------|
| Name search done | Day 1 |
| RE-303 + by-laws drafted | Weeks 2–6 |
| Letters patent + NEQ received | Weeks 4–8 |
| Bank account open | Weeks 6–10 |
| Initial REQ declaration filed | Within 60 days of letters patent |
| GST/QST registration complete | Weeks 8–12 |
| FCMQ application submitted | Concurrent with or after B2 |
| FCMQ membership approved | Weeks 10–26 (board schedule) |
| First PACM application eligible | June–August following FCMQ admission |
| **Minimum to be legally operational** | **4–8 weeks** |
| **Fully operational (FCMQ + grants)** | **2–6 months** |

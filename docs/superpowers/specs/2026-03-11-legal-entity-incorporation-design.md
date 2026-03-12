# Design: legal-entity-incorporation Plugin

**Date:** 2026-03-11
**Status:** Approved

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

### Step Tagging Convention

Every step is tagged to make the generic/specific separation explicit:

| Tag | Meaning |
|-----|---------|
| `[GENERIC]` | Required for any Quebec legal entity (for-profit or non-profit) |
| `[OBNL]` | Required only for non-profit organizations |
| `[SECTOR-SPECIFIC]` | Required only for snowmobile clubs |
| `[PROV]` | Provincial requirement (REQ, Revenu Québec) |
| `[FED]` | Federal requirement (CRA, Corporations Canada) |

---

## Skill 1: `quebec-incorporation`

**Invocation:** `/legal-entity-incorporation:quebec-incorporation`

**Purpose:** Guide through generic Quebec legal entity formation steps — applicable to any organization type.

**Prerequisite:** None.

### Steps

| Step ID | Action | Tags | Cost (2025) | Delay |
|---------|--------|------|-------------|-------|
| A2 | Name search at REQ (registreentreprises.gouv.qc.ca) | `[GENERIC][PROV]` | Free | Immediate |
| A2b | Name reservation (optional, 90 days) | `[GENERIC][PROV]` | $27 regular / $40.50 priority | 2–5 bus. days |
| D1 | Initial declaration to REQ (within 60 days of constitution) | `[GENERIC][PROV]` | Free | Immediate online |
| D2 | GST/QST registration with Revenu Québec (if taxable supplies >$30,000/year) | `[GENERIC][PROV][FED]` | Free | 2–4 weeks |
| D6 | CRA Business Number (BN) | `[GENERIC][FED]` | Free | Concurrent with D2 |
| D3 | Source deduction registration with Revenu Québec (if hiring employees) | `[GENERIC][PROV][FED]` | Free | Before first payroll |
| F1 | Open business bank account (requires NEQ + letters patent + by-laws + assembly minutes) | `[GENERIC]` | $0–$25/month | 1–2 weeks |

### Notes
- Name must comply with the Charter of the French Language (primarily French, French-first)
- A2b is optional but recommended to reserve the name during the drafting/filing period
- D1 is mandatory for all registered entities; penalty for late filing
- D2 threshold: mandatory if worldwide taxable supplies exceed $30,000 in a single quarter or over four consecutive quarters
- F1 requires: letters patent, NEQ, by-laws, minutes of constitutive assembly, ID of authorized signatories — cannot open before Step B2 of `quebec-obnl`

---

## Skill 2: `quebec-obnl`

**Invocation:** `/legal-entity-incorporation:quebec-obnl`

**Purpose:** Guide through OBNL-specific incorporation steps under Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

**Prerequisite:** `quebec-incorporation` skill started (skill checks `obnl-status.md` at start).

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

### Steps

| Step ID | Action | Tags | Cost (2025) | Delay |
|---------|--------|------|-------------|-------|
| A1 | Confirm minimum 3 founding members (natural persons); define organization name, mission, territory | `[OBNL][PROV]` | Free | 1–4 weeks |
| A3 | Draft RE-303 form ("Demande de constitution en personne morale sans but lucratif") + sworn declaration (déclaration sous serment) before commissioner of oaths or notary | `[OBNL][PROV]` | $0–$100 (notarization) | 1–3 weeks |
| A4 | Draft by-laws (règlements administratifs) — must include dissolution clause (assets to another OBNL on dissolution, not to members) | `[OBNL][PROV]` | $0 DIY / $500–2,000 lawyer | 1–4 weeks |
| B1 | File RE-303 with REQ by mail or in person (online not available for Part III OBNL as of 2025) | `[OBNL][PROV]` | $199 regular / $298.50 priority | 10 / 5 bus. days |
| B2 | Receive letters patent (Lettres patentes) and NEQ (10-digit Numéro d'entreprise du Québec) | `[OBNL][PROV]` | Included in B1 | Same as B1 |
| C1 | Hold constitutive general assembly (assemblée générale constitutive): adopt by-laws, elect board, authorize bank account, designate signatories | `[OBNL][PROV]` | Free | Within weeks of B2 |
| C2 | Set up corporate minute book (registre de l'organisme): letters patent, by-laws, minutes, director register, member register | `[OBNL][PROV]` | $0–$200 | Concurrent with C1 |
| D4 | Annual CO-17.SP (Revenu Québec non-profit income tax return) — most OBNLs exempt from tax but must file | `[OBNL][PROV]` | Free to file; $500–2,000 accounting | Within 6 months of FY end |
| D5 | Annual T2 + T1044 NPO Information Return (CRA) — exempt under ITA 149(1)(l); T1044 if assets >$200K or revenues >$100K | `[OBNL][FED]` | Free to file; included in accounting | Within 6 months of FY end |
| G1 | Annual REQ update declaration (déclaration de mise à jour annuelle) | `[GENERIC][PROV]` | $41 / $61.50 priority | Annual (REQ sends notice) |
| G2 | Annual general assembly (AGA) — minimum 10 days' notice to members; approve financials, elect directors | `[OBNL][PROV]` | Free | Annual |
| G3 | Annual financial statements | `[OBNL]` | $500–3,000/year | Annual |
| G4 | Annual tax returns (CO-17.SP + T2/T1044) | `[OBNL][PROV][FED]` | Included in G3 | Annual |

### Critical Warnings

- **Dissolution clause is legally required:** By-laws MUST specify that remaining assets go to another OBNL with similar objectives upon dissolution — NOT to members. Without this, non-profit status can be challenged.
- **Directors are personally liable** for unremitted source deductions and tax obligations. Proper accounting from day one.
- **All government filings must be in French.** Organization name must be French or French-first.
- **149(1)(l) NPO ≠ registered charity.** Cannot issue tax-deductible donation receipts. This is normal for FCMQ-member clubs.
- **Paper submission only:** RE-303 must be filed by mail or in person (no online option as of 2025).

---

## Skill 3: `snowmobile-club-qc`

**Invocation:** `/legal-entity-incorporation:snowmobile-club-qc`

**Purpose:** Guide through snowmobile-sector-specific registrations, affiliations, and funding applications for a Quebec snowmobile club.

**Prerequisite:** `quebec-obnl` steps B1–C1 complete (letters patent and NEQ received, constitutive assembly held). Skill checks `obnl-status.md` at start.

### Steps

| Step ID | Action | Tags | Cost (2025) | Delay |
|---------|--------|------|-------------|-------|
| E1 | Apply for FCMQ membership (Fédération des clubs de motoneigistes du Québec) — requires letters patent, operating a trail network | `[SECTOR-SPECIFIC]` | Annual fee (contact FCMQ: info@fcmq.qc.ca, 418-847-0898) | Board-dependent (weeks–months) |
| E2 | Apply for MTQ/PACM financial assistance — Volet 1 (trail maintenance) and Volet 2 (safety/club support) | `[SECTOR-SPECIFIC]` | Free to apply | Annual window: June–August |
| E3 | Obtain liability insurance — FCMQ base coverage ($1M civil liability) included with membership; add D&O and equipment coverage | `[SECTOR-SPECIFIC]` | Variable (FCMQ preferred rates for members) | Concurrent with E1 |
| E4 | Obtain VHR Act trail designation from MTQ (required to issue droits d'accès / trail access rights) | `[SECTOR-SPECIFIC]` | Variable | Variable (coordinate with FCMQ) |
| G5 | Annual FCMQ renewal, maintenance reporting, regional assembly participation (2–4 votes per club) | `[SECTOR-SPECIFIC]` | Annual membership fee | Annual |

### FCMQ Membership Details

- ~197 member clubs across Quebec; 30,000+ km trail network
- Active member clubs (membres actifs) must be legally constituted OBNLs operating a snowmobile trail network
- Membership provides: trail network access, droits d'accès revenue distribution, PACM eligibility, group insurance, technical support, grooming equipment programs

### MTQ/PACM Funding Details

- Total program budget: ~$8.2M for 2025–2026; runs through March 31, 2027
- **Volet 1** (trail maintenance): Largest funding component; distributed by trail kilometers and regional factors
- **Volet 2** (safety and club support): Administered through FCMQ
- Example: ~$545,000 distributed to Abitibi-Témiscamingue clubs in one cycle
- **CRITICAL:** Application window is June–August annually. Missing this window means waiting a full year.
- Eligibility: Must be active FCMQ member + demonstrated trail maintenance mission

### Critical Warnings

- **149(1)(l) NPO status:** The club cannot issue charitable tax receipts. This is expected and normal for snowmobile clubs.
- **FCMQ early contact:** Contact FCMQ before or immediately after incorporation — their board meeting schedule determines admission timeline.
- **PACM calendar is fixed:** Plan the first application for the June–August window following FCMQ admission.
- **Trail designation before droits d'accès:** Cannot legally collect trail access fees until VHR Act designation is obtained from MTQ.

---

## State File: `obnl-status.md`

Created in the user's working directory when the first skill is invoked. Updated by Claude after each completed step.

```markdown
# OBNL Incorporation Status
Organization: [organization name]
NEQ: pending | [10-digit NEQ]
Last updated: YYYY-MM-DD

## Skill: quebec-incorporation
- [ ] A2 - Name search completed
- [ ] A2b - Name reservation (optional)
- [ ] D1 - Initial REQ declaration filed (within 60 days of letters patent)
- [ ] D2 - GST/QST registration (if applicable)
- [ ] D6 - CRA Business Number obtained
- [ ] D3 - Source deductions registered (if hiring employees)
- [ ] F1 - Bank account opened

## Skill: quebec-obnl
- [ ] A1 - Founding members confirmed (min. 3)
- [ ] A3 - RE-303 drafted + sworn declaration notarized
- [ ] A4 - By-laws drafted (dissolution clause included)
- [ ] B1 - RE-303 filed with REQ
- [ ] B2 - Letters patent received + NEQ assigned
- [ ] C1 - Constitutive general assembly held
- [ ] C2 - Minute book set up
- [ ] D4 - CO-17.SP filed (annual, first due: [date])
- [ ] D5 - T2 + T1044 filed (annual, first due: [date])
- [ ] G1 - REQ annual update (annual, due: [date])
- [ ] G2 - AGA held (annual)
- [ ] G3 - Financial statements prepared (annual)
- [ ] G4 - Tax returns filed (annual)

## Skill: snowmobile-club-qc
- [ ] E1 - FCMQ membership application submitted
- [ ] E1b - FCMQ membership approved
- [ ] E2 - MTQ/PACM application submitted (window: June–August)
- [ ] E3 - Insurance obtained (FCMQ + additional)
- [ ] E4 - VHR trail designation obtained from MTQ
- [ ] G5 - FCMQ annual renewal (annual)
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
- Additional insurance: Variable

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

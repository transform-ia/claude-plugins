# Batch E — For-Profit Corporate Governance Design Spec

## Overview

One new skill covering corporate governance for for-profit corporations
incorporated in Quebec. Complements the existing `quebec-incorporation` skill,
which handles REQ registration but explicitly scopes out for-profit articles
of incorporation and governance structure.

**Skills:**

1. `quebec-forprofit-governance` — Shareholders' agreement, share structure,
   for-profit minute book, and annual governance resolutions

**Dependencies:** Requires entity type = `for-profit` in `qc-status.md` and
`INC-03` checked (initial REQ declaration filed, meaning the corporation exists
and has a NEQ).

**Out of scope:** Actual articles of incorporation filing (users are directed to
do this themselves via the REQ before using this skill, as established in the
`quebec-incorporation` resumption logic).

---

## Skill: `quebec-forprofit-governance`

### SKILL.md

```yaml
name: quebec-forprofit-governance
description: |
  Interactive guide for for-profit Quebec corporation governance: shareholders'
  agreement, share structure setup, for-profit minute book, and annual
  governance resolutions.

  Applies to Quebec business corporations incorporated under the Quebec
  Business Corporations Act (LSAQ — Loi sur les sociétés par actions) or
  federally under the CBCA.

  Reads and writes qc-forprofit-governance.md to track progress.
  Requires entity type = for-profit in qc-status.md.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-forprofit-governance
  - User has a for-profit corporation and needs to set up governance structure
  - User asks about shareholders' agreements, share issuance, or corporate
    resolutions in Quebec

  DO NOT activate when:
  - Entity type is OBNL (use quebec-obnl for OBNL governance)
  - User has not yet incorporated (complete quebec-incorporation first)
  - User is asking about OBNL minute book (covered in quebec-obnl step OBNL-07)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-forprofit-governance.md), Edit(qc-forprofit-governance.md),
  AskUserQuestion
```

### State file template

```markdown
# For-Profit Governance Status — [organization name]
schema_version: 1
Incorporation_jurisdiction: LSAQ | CBCA
Share_classes: pending
Last updated: YYYY-MM-DD

## Steps
- [ ] GOV-01 — Share structure defined
- [ ] GOV-02 — Initial shares issued (organizational resolution)
- [ ] GOV-03 — Shareholders' agreement signed (if 2+ shareholders)
- [ ] GOV-04 — For-profit minute book set up
- [ ] GOV-05 — First annual shareholder meeting held
- [ ] GOV-06 — Annual governance resolutions (recurring, next: [date])
```

### On Start

1. Read `qc-status.md`. If entity type is not `for-profit`, tell user:
   > "This skill is for for-profit corporations only. For OBNL governance,
   > use `/quebec-legal-entity:quebec-obnl`."
2. Verify INC-03 is checked in `qc-incorporation.md`. If not, tell user to
   complete the initial REQ declaration first.
3. Ask: "Was your corporation incorporated under the Quebec LSAQ or
   federally under the CBCA?" Record in `qc-forprofit-governance.md`.
4. Read `qc-forprofit-governance.md`; create from template if absent.
5. Present status; jump to first unchecked step.

### Steps

| Step | Action | Cost | Delay |
| --- | --- | --- | --- |
| GOV-01 | Define share structure: number of classes, rights of each class (voting, dividend, liquidation), authorized share count | Free ($500–$2,000 with lawyer) | 1–2 weeks |
| GOV-02 | Pass organizational resolution to issue initial shares; record in minute book; update share register | Free | Immediate after articles |
| GOV-03 | If 2+ shareholders: negotiate and sign shareholders' agreement covering share transfer restrictions, right of first refusal, shotgun clause, valuation method, voting arrangements | $1,500–$5,000 with lawyer | 2–6 weeks |
| GOV-04 | Set up for-profit minute book: articles of incorporation, bylaws, share register, register of directors, organizational resolutions | $0–$200 | Concurrent with GOV-02 |
| GOV-05 | Hold first annual shareholders' meeting: elect directors, appoint auditor (if required), approve financial statements, declare dividends (if any) | Free | Within 15 months of incorporation (LSAQ) |
| GOV-06 | Annual governance resolutions (recurring): re-elect directors, approve financial statements; update minute book | Free ($500–$1,500/year with lawyer) | Annual |

### NEVER / ALWAYS

**NEVER:**

- Skip GOV-03 for corporations with 2+ shareholders — a shareholders' agreement
  is critical to prevent deadlock and forced buyout disputes
- Mark GOV-02 complete without recording share issuance in the share register

**ALWAYS:**

- At GOV-01: explain the difference between authorized and issued shares;
  recommend a simple structure for small corporations (one class of common shares)
  unless there is a specific reason for complexity
- At GOV-03: strongly recommend a lawyer — shareholders' agreements are the
  most litigated corporate document in small business disputes
- At GOV-05: note the 15-month deadline under LSAQ for first AGM

### Key Warnings

> **Shareholders' agreement ≠ articles of incorporation:** The articles (filed
> with REQ or Corporations Canada) govern the corporation publicly. The
> shareholders' agreement is a private contract between shareholders that
> supplements the articles and is NOT filed with any registry.
>
> **LSAQ vs CBCA:** Key differences include director residency requirements
> (CBCA requires 25% Canadian residents; LSAQ has no residency requirement),
> and the jurisdiction of courts for disputes. A Quebec-only business should
> generally use LSAQ.
>
> **Unanimous Shareholder Agreement (USA):** Under the CBCA and LSAQ, a USA
> (accord unanime des actionnaires) can transfer director powers to shareholders.
> This has significant liability implications — get legal advice before using one.

---

## `qc-status.md` addition

```markdown
- [ ] quebec-forprofit-governance — not started (for-profit only)
```

---

## File Structure

```text
quebec-legal-entity/
└── skills/
    └── quebec-forprofit-governance/
        ├── SKILL.md
        └── instructions.md
```

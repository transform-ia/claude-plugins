---
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
  AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-forprofit-governance/learnings.md),
  Write(skills/quebec-forprofit-governance/learnings.md),
  Edit(skills/quebec-forprofit-governance/learnings.md)
---

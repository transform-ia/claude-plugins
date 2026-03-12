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

---
name: snowmobile-club-qc
description: |
  Interactive step-by-step guide for snowmobile-sector-specific steps after a
  Quebec OBNL has been incorporated: FCMQ membership, MTQ/PACM grants,
  VHR Act trail designation, and insurance.

  Reads and writes obnl-status.md to track progress.
  Requires letters patent and constitutive assembly (Skill 2 steps S2-05, S2-06).

  ONLY activate when:
  - User invokes /legal-entity-incorporation:snowmobile-club-qc
  - User is operating a Quebec snowmobile club and has completed OBNL incorporation
  - User asks about FCMQ membership, MTQ/PACM grants, or VHR trail designation

  DO NOT activate when:
  - User has not yet incorporated their OBNL (use quebec-obnl first)
  - User is asking about generic incorporation (use quebec-incorporation)
  - User is asking about other trail organizations (ATV, cycling, hiking — this
    skill is specific to snowmobile clubs affiliated with FCMQ)
allowed-tools:
  Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---

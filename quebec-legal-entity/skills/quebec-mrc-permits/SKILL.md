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

---
name: quebec-sst
description: |
  Advisory guide for workplace health and safety (SST — santé et sécurité au
  travail) compliance in Quebec under the Act respecting occupational health
  and safety (LSST).

  Covers prevention program requirements (mandatory thresholds vary by risk
  group under the 2021 LSST modernization), safety committee obligations,
  hazard identification, and sector-specific obligations for organizations
  operating heavy equipment (snowgroomers, vehicles).

  This is an advisory skill — it guides decisions and documents choices.
  Run once at setup; revisit when activities or workforce change.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-sst
  - User asks about workplace safety obligations, prevention programs, or
    SST compliance in Quebec
  - User operates heavy equipment or has workers in hazardous conditions

  DO NOT activate when:
  - User is asking about CNESST premium registration (use quebec-cnesst)
  - User has no employees or workers
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-sst.md), Edit(qc-sst.md), AskUserQuestion
---

---
name: quebec-construction-permits
description: |
  Guide for RBQ (Régie du bâtiment du Québec) and CCQ (Commission de la
  construction du Québec) permit and compliance requirements when a Quebec
  entity undertakes construction work.

  Covers RBQ building permit verification, contractor license requirements,
  CCQ construction work classification, and municipal building permits for
  club infrastructure (grooming depots, chalets, storage buildings).

  Reads and writes qc-construction-permits.md to track progress and log
  permits obtained.

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
  AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-construction-permits/learnings.md),
  Write(skills/quebec-construction-permits/learnings.md),
  Edit(skills/quebec-construction-permits/learnings.md)
---

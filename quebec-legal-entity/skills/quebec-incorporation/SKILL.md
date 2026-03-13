---
name: quebec-incorporation
description: |
  Interactive step-by-step guide for generic Quebec legal entity formation.
  Applicable to any organization type (for-profit or non-profit).

  Creates qc-status.md (master overview) and qc-incorporation.md (step detail)
  in the working directory on first run. Detects and rejects legacy obnl-status.md.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-incorporation
  - User asks to start registering a Quebec business, organization, or legal entity
  - User needs to do a name search at the REQ
  - User is beginning the Quebec incorporation process

  DO NOT activate when:
  - User is specifically asking about OBNL/non-profit steps (use quebec-obnl)
  - User is asking about federal incorporation via Corporations Canada / CNCA
  - User is asking about snowmobile club sector steps (use quebec-snowmobile-club)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-incorporation.md), Edit(qc-incorporation.md), AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-incorporation/learnings.md),
  Write(skills/quebec-incorporation/learnings.md),
  Edit(skills/quebec-incorporation/learnings.md)
---

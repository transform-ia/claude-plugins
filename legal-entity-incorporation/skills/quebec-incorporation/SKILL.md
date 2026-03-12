---
name: quebec-incorporation
description: |
  Interactive step-by-step guide for generic Quebec legal entity formation.
  Applicable to any organization type (for-profit or non-profit).
  Reads and writes obnl-status.md in the working directory to track progress.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:quebec-incorporation
  - User asks to start registering a Quebec business, organization, or legal entity
  - User needs to do a name search at the REQ
  - User is beginning the Quebec incorporation process

  DO NOT activate when:
  - User is specifically asking about OBNL/non-profit steps (use quebec-obnl)
  - User is asking about federal incorporation via Corporations Canada / CNCA
allowed-tools: Read, Write(obnl-status.md), Edit(obnl-status.md), AskUserQuestion
---

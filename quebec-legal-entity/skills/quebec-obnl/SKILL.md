---
name: quebec-obnl
description: |
  Interactive step-by-step guide for incorporating a Quebec non-profit (OBNL)
  under the Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

  Reads and writes qc-obnl.md to track progress across sessions.
  Requires the name search step from quebec-incorporation to be complete (INC-01).

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-obnl
  - User is specifically registering a Quebec non-profit / OBNL / organisme
    sans but lucratif
  - User needs to file Form RE-303 with the Registraire des entreprises

  DO NOT activate when:
  - User wants generic Quebec entity registration only (use quebec-incorporation)
  - User wants federal non-profit via Corporations Canada / CNCA
  - User is asking only about snowmobile sector steps (use quebec-snowmobile-club)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-obnl.md), Edit(qc-obnl.md), AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-obnl/learnings.md),
  Write(skills/quebec-obnl/learnings.md),
  Edit(skills/quebec-obnl/learnings.md)
---

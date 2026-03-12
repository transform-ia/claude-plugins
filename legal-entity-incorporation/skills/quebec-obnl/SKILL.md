---
name: quebec-obnl
description: |
  Interactive step-by-step guide for incorporating a Quebec non-profit (OBNL)
  under the Quebec Companies Act Part III (Loi sur les compagnies, Partie III).

  Reads and writes obnl-status.md to track progress across sessions.
  Requires the name search step from quebec-incorporation to be complete.

  ONLY activate when:
  - User invokes /legal-entity-incorporation:quebec-obnl
  - User is specifically registering a Quebec non-profit / OBNL / organisme
    sans but lucratif
  - User needs to file Form RE-303 with the Registraire des entreprises

  DO NOT activate when:
  - User wants generic Quebec entity registration only (use quebec-incorporation)
  - User wants federal non-profit via Corporations Canada / CNCA
  - User is asking only about snowmobile sector steps (use snowmobile-club-qc)
allowed-tools:
  Read, Write(obnl-status.md), Edit(obnl-status.md)
---

---
name: quebec-cnesst
description: |
  Interactive guide for CNESST workers' compensation registration and ongoing
  compliance in Quebec. Covers employer account registration, activity unit
  classification, annual salary declaration (DPA), and workplace accident
  reporting procedures.

  Mandatory for any Quebec employer with at least one worker. Separate from
  payroll source deductions — CNESST is employer-funded workers' compensation.

  Reads and writes qc-cnesst.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-cnesst
  - User asks about CNESST registration, workers' compensation, or workplace
    accident reporting in Quebec
  - User has employees and is setting up their Quebec employer obligations

  DO NOT activate when:
  - User is asking about payroll source deductions (use quebec-payroll)
  - User is asking about workplace safety programs (use quebec-sst)
  - User has no employees
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-cnesst.md), Edit(qc-cnesst.md), AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-cnesst/learnings.md),
  Write(skills/quebec-cnesst/learnings.md),
  Edit(skills/quebec-cnesst/learnings.md)
---

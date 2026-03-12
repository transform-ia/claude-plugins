---
name: quebec-payroll
description: |
  Interactive guide for payroll setup and compliance for Quebec entities.
  Covers source deduction registration, DAS remittance schedule, first payroll
  run, year-end T4/RL-1 filing, and vacation pay rules.

  Marks itself N/A in qc-status.md if the entity has no employees.
  Reads and writes qc-payroll.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-payroll
  - User is hiring employees or has payroll obligations in Quebec
  - User asks about source deductions, DAS, T4, RL-1, or payroll remittances

  DO NOT activate when:
  - User is asking about GST/QST (use quebec-gst-qst)
  - User is asking about corporate income taxes (use quebec-income-tax)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-payroll.md), Edit(qc-payroll.md), AskUserQuestion
---

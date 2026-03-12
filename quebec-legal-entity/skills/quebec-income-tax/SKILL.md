---
name: quebec-income-tax
description: |
  Interactive guide for corporate income tax obligations in Quebec.
  Branches on entity type: T2 (for-profit) or CO-17.SP + T2 + T1044 (OBNL).
  Covers fiscal year-end, instalment obligations, filing deadlines, and
  annual recurring reminders.

  Reads Entity type from qc-status.md to determine the correct branch.
  Reads and writes qc-income-tax.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-income-tax
  - User asks about corporate income tax, T2, CO-17.SP, or T1044

  DO NOT activate when:
  - User is asking about GST/QST (use quebec-gst-qst)
  - User is asking about payroll deductions (use quebec-payroll)
  - User is asking about personal income taxes (out of scope)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-income-tax.md), Edit(qc-income-tax.md), AskUserQuestion
---

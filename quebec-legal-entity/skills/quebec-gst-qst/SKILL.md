---
name: quebec-gst-qst
description: |
  Interactive guide for GST/QST registration and ongoing return filing in Quebec.
  Covers mandatory and voluntary registration, filing frequency selection, ITC/RTI
  tracking, instalment obligations, and recurring return reminders.

  In Quebec, Revenu Québec administers both GST and QST — one registration covers both.

  Reads and writes qc-gst-qst.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-gst-qst
  - User asks about GST, QST, TPS, TVQ registration or filing
  - User needs to register for or file sales tax returns in Quebec

  DO NOT activate when:
  - User is asking about income taxes (use quebec-income-tax)
  - User is asking about payroll deductions (use quebec-payroll)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-gst-qst.md), Edit(qc-gst-qst.md), AskUserQuestion
---

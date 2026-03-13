---
name: quebec-banking
description: |
  Interactive guide for business banking setup and ongoing operations for a
  Quebec entity. Covers bank product selection, authorized signatories policy,
  online banking setup, and banking hygiene for OBNLs and for-profits.

  Complements INC-04 (bank account opening step) with deeper operational
  guidance. Run after INC-04 to establish banking policies and controls.

  Reads and writes qc-banking.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-banking
  - User is choosing a bank or banking product for their Quebec entity
  - User asks about authorized signatories, signing authority policy, or
    online banking setup for a Quebec business or OBNL

  DO NOT activate when:
  - User is asking about opening the bank account itself (that is INC-04 in
    quebec-incorporation)
  - User is asking about GST/QST filing (use quebec-gst-qst)
  - User is asking about payroll remittances (use quebec-payroll)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-banking.md), Edit(qc-banking.md), AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-banking/learnings.md),
  Write(skills/quebec-banking/learnings.md),
  Edit(skills/quebec-banking/learnings.md)
---

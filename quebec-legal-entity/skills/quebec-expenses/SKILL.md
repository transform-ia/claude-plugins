---
name: quebec-expenses
description: |
  Advisory guide for expense management for Quebec entities. Covers expense
  policy setup, receipt requirements for GST/QST input tax credit (ITC) claims,
  CRA automobile allowance rates, board member and volunteer expense
  reimbursement procedures, and per diem policies.

  This is an advisory skill — it helps establish expense policies and
  documents decisions.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-expenses
  - User asks about expense reimbursement policies or procedures
  - User wants to set up an expense claim process for employees, board
    members, or volunteers
  - User asks about what receipts are required for tax purposes

  DO NOT activate when:
  - User is asking about payroll source deductions (use quebec-payroll)
  - User is asking about GST/QST return filing (use quebec-gst-qst)
  - User is asking about accounting software setup (use quebec-accounting)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-expenses.md), Edit(qc-expenses.md), AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-expenses/learnings.md),
  Write(skills/quebec-expenses/learnings.md),
  Edit(skills/quebec-expenses/learnings.md)
---

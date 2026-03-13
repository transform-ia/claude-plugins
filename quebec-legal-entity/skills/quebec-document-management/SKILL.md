---
name: quebec-document-management
description: |
  Advisory guide for document management and archiving for Quebec entities.
  Covers digital record validity under Quebec's LCCJTI and CRA electronic
  record rules, what must stay as paper originals, scanning workflow,
  file naming conventions, backup strategy, and retention calendar.

  Short answer: scanned documents are legally valid in Quebec under the LCCJTI
  (Loi concernant le cadre juridique des technologies de l'information) and
  accepted by CRA, with two hard legal exceptions that must stay as paper
  originals.

  This is an advisory skill — it guides setup decisions and documents choices.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-document-management
  - User asks whether scanned documents are legally valid in Quebec
  - User is setting up a document management or archiving system
  - User wants to know what to keep as paper vs digital

  DO NOT activate when:
  - User is asking about record retention periods (those are in ACC-05 in
    quebec-accounting — 6 years)
  - User is asking about privacy of personal data (use quebec-privacy)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-document-management.md), Edit(qc-document-management.md),
  AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-document-management/learnings.md),
  Write(skills/quebec-document-management/learnings.md),
  Edit(skills/quebec-document-management/learnings.md)
---

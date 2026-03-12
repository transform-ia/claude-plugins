---
name: quebec-privacy
description: |
  Interactive guide for Quebec Law 25 (Act respecting the protection of
  personal information in the private sector) compliance.

  Covers privacy officer designation, privacy policy publication, personal
  information inventory, Privacy Impact Assessments (PIAs), breach response
  procedures, and individual rights management.

  Applies to any organization that collects, uses, or communicates personal
  information — including membership lists, employee records, and website
  analytics. All three Law 25 phases (Sept 2022, Sept 2023, Sept 2024)
  are now in effect.

  Reads and writes qc-privacy.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-privacy
  - User asks about Law 25, privacy compliance, or personal data obligations
    in Quebec
  - User is setting up a membership database, website, or any system
    collecting personal information

  DO NOT activate when:
  - User is asking about employee payroll records (covered in quebec-payroll)
  - User is asking about federal PIPEDA only (this skill covers Quebec Law 25)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-privacy.md), Edit(qc-privacy.md), AskUserQuestion
---

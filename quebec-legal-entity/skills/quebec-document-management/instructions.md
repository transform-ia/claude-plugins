# Quebec Document Management — Digital Archiving Guide

This skill guides you through setting up a document management and archiving
system for a Quebec entity. The short answer: scanned documents are legally
valid in Quebec and accepted by CRA, with two hard legal exceptions that
must remain as paper originals.

---

## On Start

**Before proceeding:** Read `skills/_shared/learnings-protocol.md`. Then read
`skills/quebec-document-management/learnings.md` if it exists and incorporate any entries into your
working knowledge for this session.

1. Read `qc-status.md` for Organization name.
2. Read `qc-document-management.md` if present; create it from the template
   below if absent.
3. Walk through advisory sections in order, asking whether the organization
   has addressed each area, then record decisions.

**`qc-document-management.md` template (create if absent):**

````markdown
# Document Management Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| DOC-01 Digital validity confirmed | pending | — |
| DOC-02 Paper originals list | pending | — |
| DOC-03 Scanning workflow | pending | — |
| DOC-04 File naming convention | pending | — |
| DOC-05 Backup strategy | pending | — |
| DOC-06 Retention calendar | pending | — |
````

---

## NEVER / ALWAYS

### NEVER

- Tell the user that all documents can be digitized — two categories must stay
  as paper originals due to hard legal requirements (see DOC-02)
- Recommend keeping physical originals of everything — the goal is a
  sustainable digital-first system with targeted, clearly defined paper exceptions
- Classify "wet-signature contracts" as a categorical legal exception — they
  are a contractual matter that depends on what the counterparty requires, not
  a legal absolute under the LCCJTI

### ALWAYS

- Lead with the direct answer: scanned documents are legally valid in Quebec
  under the LCCJTI and CRA's electronic records policy, subject to the two
  hard exceptions in DOC-02
- At DOC-05: require at least two backup locations (one local, one cloud) —
  a single storage location is not a backup
- After each section, record the decision (implemented, in progress, or
  explicitly declined with reason) in `qc-document-management.md`

---

## Advisory Sections

For each section: explain the rule, discuss implementation options, and record
the decision in `qc-document-management.md`.

---

### DOC-01 — Digital record validity under LCCJTI and CRA

**What to know:**
Under Quebec's *Loi concernant le cadre juridique des technologies de
l'information* (LCCJTI), a digital document — including a scan of a paper
original — has the same legal force as the paper original provided:

- Its **integrity** is maintained (the document has not been altered after
  creation)
- The **technology** used is reliable and the process is documented
- The **origin** can be established (who created or received it)

CRA also accepts digital records for all tax purposes. CRA's electronic records
policy requires that digital records be:

- Legible when displayed or printed
- Complete (all pages, all attachments)
- Organized so they can be retrieved promptly on request

**Practical implication:** You can scan paper invoices, receipts, bank
statements, board minutes, contracts, and insurance policies, then discard the
paper originals — with the two exceptions listed in DOC-02.

**After confirming:** Record "LCCJTI validity confirmed — digital-first policy
adopted" in `qc-document-management.md`. Check `DOC-01`.

---

### DOC-02 — Documents that must stay as paper originals

**The two hard legal exceptions:**

1. **Notarized or sworn documents** — Any document that bears a notary's or
   commissioner of oaths's wet signature and official seal: sworn declarations
   (déclarations sous serment) such as the RE-303 OBNL declaration, notarized
   agreements, notarized powers of attorney. The notary's physical seal cannot
   be authentically reproduced digitally — a scan is useful for reference but
   the signed original must be kept.

2. **Letters patent** — The original REQ-issued letters patent bearing the
   official government seal (for OBNLs incorporated under Quebec's Companies
   Act via RE-303). Keep the original in the minute book. A certified copy is
   acceptable for most purposes (e.g., bank account opening), but the original
   must be preserved for the life of the organization.

**Everything else** — invoices, receipts, bank statements, board minutes,
insurance policies, tax returns, contracts, grant applications, payroll records
— can be scanned and the paper discarded after scanning, subject to the
scanning workflow in DOC-03.

**Watch for — wet-signature contracts:**
Some counterparties contractually require a wet-signature original (e.g., some
landowner trail access agreements, institutional grant contribution agreements,
financial institution forms). This is a **negotiated contractual requirement**,
not a legal absolute — Quebec's LCCJTI and the Act to establish a legal framework
for information technology both recognize electronic signatures as valid for
contracts unless the parties agree otherwise. When a counterparty's contract
language requires a wet-signature original, you must comply with that contract
term; but this is case-by-case, not a categorical rule across all contracts.

**After confirming exceptions list:** Record "Paper originals list established:
notarized docs + letters patent" in `qc-document-management.md`. Check `DOC-02`.

---

### DOC-03 — Scanning workflow

**Recommended workflow for sustainable digital archiving:**

1. **Scan at 300 dpi minimum** — use 600 dpi for legal documents with fine
   print, small text, or official seals
2. **Save as PDF/A** (ISO 19005 archival format) — not JPEG, not plain PDF.
   PDF/A embeds fonts and prevents future software from altering the content.
   Most modern scanners and scanner apps support PDF/A export.
3. **Name the file immediately** (see DOC-04 naming convention) before moving
   it to the archive folder
4. **Verify legibility** before discarding the paper original — open the scan
   on screen and confirm all text is readable, all pages are captured, and
   the scanner did not clip any edges
5. **For GST/QST receipts specifically:** The scan must show supplier name,
   date, total amount, the GST/QST amounts (or "taxes incluses" with the
   computed amounts), and the supplier's GST/QST registration number — all are
   required for an ITC/RTI claim. A receipt that lacks the registration number
   on the original also lacks it on the scan; the ITC will be denied regardless
   of format.

**After workflow documented:** Record the scanning tool/app chosen and dpi
setting in `qc-document-management.md`. Check `DOC-03`.

---

### DOC-04 — File naming convention

**Recommended convention:** `YYYY-MM-DD_category_description.pdf`

**Examples:**

- `2026-03-01_facture_hydro-quebec-mars.pdf`
- `2026-02-28_DAS_remittance-fevrier.pdf`
- `2026-01-15_contrat_acces-terrain-dupont.pdf`
- `2026-03-12_resolution_signataires-banque.pdf`
- `2025-12-31_etats-financiers_annuels.pdf`

**Folder structure — organize by fiscal year, then category:**

```text
[YYYY] Exercice financier/
├── Factures/
├── Contrats/
├── Gouvernement/       (tax filings, RQ correspondence, CRA)
├── Paie/               (payroll records)
├── Assurances/
├── Subventions/        (PACM, grant applications and reports)
└── Résolutions/        (board resolutions, AGM minutes)
```

**Date rule:** Use the document date (invoice date, contract date, resolution
date), not the scan date.

**After convention adopted:** Record the chosen convention in
`qc-document-management.md`. Check `DOC-04`.

---

### DOC-05 — Backup strategy

**Minimum requirement:** Two backup locations — one local and one cloud.
A single storage location (even cloud) is not a backup: if the account is
compromised, suspended, or the provider fails, documents are lost.

**Recommended configuration:**

| Location | Tool | Notes |
| --- | --- | --- |
| Local | External hard drive or NAS | Keep at a different physical location from the primary computer (e.g., a board member's home) |
| Cloud (primary) | Google Drive, OneDrive, or Dropbox | Enable automatic sync; share folder with at least two authorized users |

**Recommended for eligible OBNLs:**
Google Workspace for Nonprofits (free for registered Canadian charities and
eligible non-profits) includes Google Drive with pooled storage. Apply at
google.com/nonprofits.

**Backup schedule:** Cloud backup should be automatic and continuous (sync
tool). Local backup: at minimum monthly, or after any significant document batch.

**After backup configured:** Record the two backup locations in
`qc-document-management.md`. Check `DOC-05`.

---

### DOC-06 — Retention calendar

**Minimum retention periods:**

| Document type | Retention period | Authority |
| --- | --- | --- |
| Tax records (invoices, receipts, returns) | 6 years from end of fiscal year | Revenu Québec / CRA |
| Payroll records | 6 years | Revenu Québec / CRA |
| Employment records | 6 years from end of employment | ANT |
| Corporate minute book | Indefinitely | Corporate law |
| Letters patent / articles | Indefinitely | Corporate law |
| By-laws | Indefinitely | Corporate law |
| Land access agreements (in force) | Duration + 6 years | Contractual + tax |

**Annual action:** Set a recurring calendar reminder each year to purge
documents that have passed their retention period. Typical purge: each
January, delete documents from 7 years prior (e.g., January 2027: purge
documents dated before December 31, 2020).

**After calendar set:** Record the purge schedule in `qc-document-management.md`.
Check `DOC-06`.

---

## KEY WARNING

> **Integrity requirement:** A digital document's legal validity under the
> LCCJTI depends on its integrity — the document must not have been altered
> after it was created or received. Do not edit PDFs after they are filed.
> Store archived documents in a read-only or locked folder where ordinary
> users cannot modify files. If a document must be corrected, create a new
> version, name it clearly (e.g., `2026-03-01_facture_hydro-v2-corrigee.pdf`),
> and retain both the original and the corrected version.

---

## Completion

When all DOC sections have been decided (implemented or explicitly declined
with documented reason), update `qc-status.md`:
`- [x] quebec-document-management — completed [YYYY-MM-DD]`

Then prompt: "Document management system is established. Review annually:
confirm backup is functioning (DOC-05), run the retention purge (DOC-06),
and update the paper-originals list (DOC-02) if new notarized documents have
been created."

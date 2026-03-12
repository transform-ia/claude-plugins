# Quebec Legal Entity Plugin

Interactive step-by-step guides for the full lifecycle of a Quebec legal entity —
from name search through ongoing compliance obligations. Each skill reads and writes
state files in the working directory to persist progress across sessions.

## Skills

### `/quebec-legal-entity:quebec-incorporation`

**Purpose:** Generic Quebec legal entity formation guide, applicable to any organization
type (for-profit or non-profit). Walks through name search at the Registre des
entreprises du Québec (REQ), initial registration, and post-incorporation steps.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-status.md` (master overview), `qc-incorporation.md` (step detail)

---

### `/quebec-legal-entity:quebec-obnl`

**Purpose:** Quebec OBNL (Organisme à but non lucratif) non-profit registration guide.
Covers letters patent via RE-303, by-laws, board structure, and annual obligations.

**Tags used:** `[OBNL]`, `[PROV]`, `[FED]`

**Creates:** `qc-obnl.md`

**Depends on:** `quebec-incorporation` (INC-01 must be complete)

---

### `/quebec-legal-entity:quebec-snowmobile-club`

**Purpose:** Snowmobile club operations guide for Quebec clubs affiliated with the
Fédération des clubs de motoneigistes du Québec (FCMQ). Covers FCMQ membership,
MTQ/PACM grants, VHR trail designation, and insurance.

**Tags used:** `[SECTOR-SPECIFIC]`

**Creates:** `qc-snowmobile-club.md`

**Depends on:** `quebec-obnl` (OBNL-05 + OBNL-06 must be complete)

---

### `/quebec-legal-entity:quebec-gst-qst`

**Purpose:** GST/QST registration and ongoing return filing guide. Covers mandatory
and voluntary registration, filing frequency selection, ITC/RTI tracking, and
instalment obligations.

**Tags used:** `[GENERIC]`, `[PROV]`, `[FED]`

**Creates:** `qc-gst-qst.md`

---

### `/quebec-legal-entity:quebec-payroll`

**Purpose:** Payroll setup and compliance guide. Covers source deduction registration,
DAS remittance schedule, first payroll run, year-end T4/RL-1 filing, and vacation pay.
Marks itself N/A if the entity has no employees.

**Tags used:** `[GENERIC]`, `[PROV]`, `[FED]`

**Creates:** `qc-payroll.md`

---

### `/quebec-legal-entity:quebec-income-tax`

**Purpose:** Corporate income tax guide. Branches on entity type: T2 for for-profit
corporations, CO-17.SP + T2 + T1044 for OBNLs. Covers fiscal year-end, instalments,
and annual filing deadlines.

**Tags used:** `[GENERIC]`, `[PROV]`, `[FED]` (for-profit) or `[OBNL]`, `[PROV]`, `[FED]` (OBNL)

**Creates:** `qc-income-tax.md`

---

### `/quebec-legal-entity:quebec-insurance`

**Purpose:** Advisory insurance coverage guide. Walks through coverage types
(general liability, D&O, property, E&O, event) and records decisions in a coverage log.

**Tags used:** `[GENERIC]`

**Creates:** `qc-insurance.md`

---

### `/quebec-legal-entity:quebec-accounting`

**Purpose:** Advisory accounting setup guide. Covers fiscal year-end choice, software
selection, chart of accounts, bookkeeper vs CPA, and record retention. Run once at
entity formation.

**Tags used:** `[GENERIC]`

**Creates:** `qc-accounting.md`

---

### `/quebec-legal-entity:quebec-cnesst`

**Purpose:** CNESST workers' compensation registration and ongoing compliance.
Covers employer account registration, activity unit classification, annual salary
declaration (DPA), and accident reporting procedures. Mandatory for any Quebec
employer with at least one worker.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-cnesst.md`

**Depends on:** `quebec-payroll` (presence of employees)

---

### `/quebec-legal-entity:quebec-sst`

**Purpose:** Advisory workplace health and safety (SST) compliance guide under
the LSST. Covers prevention program requirements (LSST Bill 59 risk groups),
safety committee obligations, hazard identification, and heavy-equipment
obligations for groomer/vehicle operators.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-sst.md`

**Depends on:** `quebec-payroll` (presence of employees)

---

### `/quebec-legal-entity:quebec-labour-standards`

**Purpose:** Advisory Quebec labour standards compliance guide under ANT.
Covers employment contracts, minimum wage, notice of termination, psychological
harassment prevention policy (mandatory for all employers), and overtime rules.

**Tags used:** `[GENERIC]`, `[PROV]`

**Creates:** `qc-labour-standards.md`

**Depends on:** `quebec-payroll` (presence of employees)

---

## Progress Tracking

All skills read `qc-status.md` for a master overview, plus their own per-skill file
for step-level detail. Both files are created in the current working directory on first
run and are safe to commit alongside your organization's documents.

---

## Step Tags

| Tag | Meaning |
| --- | --- |
| `[GENERIC]` | Applies to any Quebec legal entity |
| `[OBNL]` | Applies to non-profits only |
| `[SECTOR-SPECIFIC]` | Applies to snowmobile clubs only |
| `[PROV]` | Provincial requirement (REQ / Revenu Québec) |
| `[FED]` | Federal requirement (CRA / Corporations Canada) |

---

## Cost Estimates

| Phase | Minimum | Recommended |
| --- | --- | --- |
| Startup (one-time) | ~$200–$250 | ~$800–$2,500 |
| Annual (ongoing) | ~$540/year | ~$2,500–$5,500/year |

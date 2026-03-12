# Legal Entity Incorporation Plugin

Interactive step-by-step guides for incorporating a Quebec legal entity, registering an OBNL
(non-profit organization), and managing snowmobile club operations. Each skill reads and writes
`obnl-status.md` in the working directory to persist progress across sessions.

## Skills

### `/legal-entity-incorporation:quebec-incorporation`

**Purpose:** Generic Quebec legal entity formation guide, applicable to any organization type
(for-profit or non-profit). Walks through name search at the Registre des entreprises du Québec
(REQ), articles of incorporation, initial registration, and post-incorporation steps.

**Tags used:** `[GENERIC]`, `[PROV]`

**Depends on:** `obnl-status.md` (read/write) in the working directory for progress tracking.

---

### `/legal-entity-incorporation:quebec-obnl`

**Purpose:** Quebec OBNL (Organisme à but non lucratif) non-profit registration guide. Builds on
the generic Quebec incorporation steps and adds non-profit-specific requirements: letters patent,
by-laws, board structure, Revenu Québec exemption, and federal CRA charitable status (optional).

**Tags used:** `[GENERIC]`, `[OBNL]`, `[PROV]`, `[FED]`

**Depends on:** `obnl-status.md` (read/write) in the working directory for progress tracking.
Complements `quebec-incorporation` — OBNL-specific steps are layered on top of the generic flow.

---

### `/legal-entity-incorporation:snowmobile-club-qc`

**Purpose:** Snowmobile club operations guide for Quebec clubs affiliated with the Fédération des
clubs de motoneigistes du Québec (FCMQ). Covers club incorporation, FCMQ affiliation, trail
maintenance agreements, groomer insurance, seasonal operations, and member management specifics
applicable to the snowmobile sector.

**Tags used:** `[GENERIC]`, `[OBNL]`, `[SECTOR-SPECIFIC]`, `[PROV]`

**Depends on:** `obnl-status.md` (read/write) in the working directory for progress tracking.
Builds on both `quebec-incorporation` and `quebec-obnl` flows, adding sector-specific steps.

---

## Progress Tracking

All three skills read and write `obnl-status.md` in the current working directory. This file
stores which steps have been completed, skipped, or deferred, allowing you to resume a session
without repeating already-completed steps.

The file is created automatically on first run and is safe to commit to version control alongside
your organization's incorporation documents.

---

## Cost Estimates

| Phase | Minimum | Recommended |
| --- | --- | --- |
| Startup (one-time) | ~$200–$250 | ~$800–$2,500 |
| Annual (ongoing) | ~$540/year | ~$2,500–$5,500/year |

Startup costs include REQ filing fees, notary or lawyer fees (if applicable), and initial
registrations. Annual costs include renewal fees, accounting, and insurance.

---

## Step Tags

| Tag | Meaning |
| --- | --- |
| `[GENERIC]` | Applies to any Quebec legal entity |
| `[OBNL]` | Applies to non-profits only |
| `[SECTOR-SPECIFIC]` | Applies to snowmobile clubs only |
| `[PROV]` | Provincial requirement (REQ / Revenu Québec) |
| `[FED]` | Federal requirement (CRA / Corporations Canada) |

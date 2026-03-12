# Quebec SST — Workplace Health and Safety

This skill guides you through workplace health and safety (SST) compliance
obligations under Quebec's Act respecting occupational health and safety (LSST).

---

## On Start

1. Read `qc-status.md`. If `quebec-payroll` is `[n/a]` (no employees), inform
   the user: "SST obligations are not triggered without employees or workers.
   Return here if you hire staff or engage contractors." Exit.

2. Read `qc-sst.md` if present; create it from the template below if absent.

3. Ask: "Does your organization operate heavy equipment such as snowgroomers,
   tractors, or other vehicles?" Record the answer — it determines whether
   SST-05 applies.

4. Walk through advisory sections.

**`qc-sst.md` template (create if absent):**

````markdown
# SST (Workplace Safety) Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Decisions

| Section | Decision | Notes |
| --- | --- | --- |
| SST-01 Prevention program | pending | — |
| SST-02 Safety committee | pending | — |
| SST-03 Hazard register | pending | — |
| SST-04 Emergency procedures | pending | — |
| SST-05 Sector-specific obligations | pending | — |
````

---

## NEVER / ALWAYS

### NEVER

- Tell an employer that a prevention program is optional if they have 20+
  workers or operate in a high-risk sector (Groups I–II under LSST) — it is
  mandatory
- Apply a flat "20 workers" rule without qualifying by risk group — the LSST
  modernization (Bill 59) sets different thresholds by group
- Conflate LSST (physical safety) with ANT (psychological harassment); direct
  user to `/quebec-legal-entity:quebec-labour-standards` for LAB-04

### ALWAYS

- At SST-02: clarify that the safety committee threshold varies by risk group;
  do not state a flat "20 workers" rule without qualifying by sector
- At SST-05: only present heavy-equipment obligations if user confirmed they
  operate heavy equipment

---

## Advisory Sections

For each section: explain the obligation, determine whether it applies, and
record the decision in `qc-sst.md`.

---

### SST-01 — Prevention program

**Who must have one:**

Under the LSST modernization (Bill 59, phased 2023–2024):
- **Groups I and II (high-risk sectors):** Written prevention program mandatory
  for ALL employers regardless of worker count
- **Groups III and IV (lower-risk sectors):** Written prevention program
  mandatory at 20+ workers

Determine your risk group from your CNESST activity unit (CNS-02). High-risk
sectors include construction, forestry, agriculture, and heavy equipment operation.

**What the program must cover:** Hazard identification, control measures,
worker training, roles and responsibilities.

**Cost:** Free (internal effort)

---

### SST-02 — Safety committee (CSS)

**Who must have one:**

A joint health and safety committee (Comité de santé et sécurité / CSS) is
required at thresholds that vary by risk group under LSST. The threshold is
**not** a flat "20 workers" rule across all sectors.

- Groups I–II: Thresholds are lower (check your activity unit with CNESST)
- Groups III–IV: Generally 20+ workers triggers the requirement

If a CSS is required, it must include worker and employer representatives.

**Cost:** Free (internal effort)

---

### SST-03 — Hazard register

**Who must have one:** All employers with workers, regardless of size.

A hazard register (registre des risques) identifies:
- Physical hazards (equipment, environment)
- Chemical hazards (products, fumes)
- Ergonomic hazards (lifting, repetitive motion)
- Psychosocial hazards (harassment, stress — cross-reference LAB-04)

Update whenever activities, equipment, or worksite conditions change.

**Cost:** Free (internal effort)

---

### SST-04 — Emergency procedures and first aid

**Who must have one:** All employers with workers, regardless of size.

Document:
- Emergency evacuation procedures
- First aid kit location and first-aid-trained personnel
- Emergency contact numbers (ambulance, CNESST accident reporting line)
- Procedures for specific risks (chemical spill, machinery accident)

**Cost:** First aid kit $50–$200; training variable

---

### SST-05 — Sector-specific obligations (heavy equipment)

**Applies only if:** User confirmed operating heavy equipment (snowgroomers,
tractors, vehicles used in field operations).

Key obligations for heavy equipment operators:
- Operators must have appropriate training and competency documentation
- Equipment must be inspected before each use and maintained per manufacturer
  requirements
- Safe operating procedures must be documented and communicated to operators
- Proximity to public (trails, roads): follow applicable VHR Act and municipal
  signage requirements

Record the specific equipment types and training requirements in `qc-sst.md`.

---

## KEY WARNING

> **Psychological harassment prevention is ANT, not LSST:** Under the Act
> respecting labour standards (ANT), ALL Quebec employers regardless of size
> must have a psychological harassment prevention and complaint-handling policy.
> This is a labour standards obligation, not a workplace safety obligation.
> See `/quebec-legal-entity:quebec-labour-standards` (LAB-04).

---

## Completion

When all SST sections have been decided (or marked N/A where applicable),
update `qc-status.md`:
`- [x] quebec-sst — completed [YYYY-MM-DD]`

Then prompt: "SST compliance framework is established. Revisit when activities
change (new equipment, new worksites, workforce growth). Annual reminder:
update the hazard register (SST-03) and review emergency procedures (SST-04)."

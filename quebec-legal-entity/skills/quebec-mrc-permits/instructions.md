# Quebec MRC/Municipal Permits — Trail Infrastructure Authorizations

This skill guides you through obtaining MRC and municipal authorizations for
Quebec snowmobile trail infrastructure.

---

## On Start

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   tell the user: "MRC and municipal permits require active FCMQ membership
   context. Complete `/quebec-legal-entity:quebec-snowmobile-club` first."
   Exit.

2. Read `qc-mrc-permits.md` if present; create it from the template below if absent.

3. Present current permit status; jump to first unchecked step.

**`qc-mrc-permits.md` template (create if absent):**

```markdown
# MRC/Municipal Permits Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps
- [ ] MRC-01 — MRC trail network authorization contacted
- [ ] MRC-02 — Municipal road crossing permits identified and applied for
- [ ] MRC-03 — Signage permits obtained (where required)
- [ ] MRC-04 — Grooming depot permits confirmed (if applicable)

## Permit Log

| Permit type | Authority | Status | Issued | Expiry | Notes |
| --- | --- | --- | --- | --- | --- |
| — | — | pending | — | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user MRC permits are uniform across Quebec — requirements vary
  significantly by region; always direct to the local MRC planning department
- Mark MRC-02 complete without recording each crossing permit in the Permit Log

### ALWAYS

- At MRC-01: recommend consulting the FCMQ regional representative first —
  they know the MRC-specific requirements in the territory and can make
  introductions to MRC planning staff
- After each permit obtained: record it in the Permit Log with expiry date

---

## CRITICAL WARNING

> **MRC requirements vary by region:** Some MRCs require formal trail corridor
> inclusion in the schéma d'aménagement before trails can be designated under
> the VHR Act. Consult your FCMQ regional representative — they know the
> requirements in your territory.

---

## Steps

---

### MRC-01 `[SECTOR-SPECIFIC]` — MRC trail network authorization

**What to do:**
Contact the MRC planning department (service de l'aménagement du territoire)
to understand trail corridor requirements in the regional land use plan
(schéma d'aménagement et de développement).

Key questions to ask the MRC:

- Is snowmobile trail designation explicitly included in the schéma?
- Does the MRC require formal authorization or designation before trails can
  open to the public under the VHR Act?
- Are there specific setbacks or conditions for trails near agricultural zones,
  waterways, or residential areas?

**FCMQ regional representative:** Contact them before approaching the MRC —
they have experience with the process in your territory and may already have
an established relationship with MRC staff.

**Cost:** Free
**Delay:** 1–4 weeks (to obtain meeting and initial response)

**After initial MRC contact:** Record the MRC contact name, date of contact,
and any authorization requirements identified in the Permit Log. Check `MRC-01`
in `qc-mrc-permits.md`.

---

### MRC-02 `[SECTOR-SPECIFIC]` — Municipal road crossing permits

**What to do:**
Identify all points where the trail crosses a municipal road and apply for
crossing permits from the relevant municipality.

**For each crossing:**

- Identify the municipality responsible for the road
- Contact the municipality's public works or engineering department
- Apply for a crossing permit (typically annual)
- Record the permit in the Permit Log with expiry date

**Typical requirements:**

- Crossing location (civic address or GPS coordinates)
- Crossing design (groomed trail crossing, signage plan)
- Club liability insurance certificate (FCMQ membership provides base coverage)

**Cost:** $0–$500 per crossing (varies by municipality)
**Delay:** 2–8 weeks per permit

**After each permit received:** Record in the Permit Log:

- Permit type: `road crossing`
- Authority: municipality name
- Status: `issued`
- Issued date and expiry date (most are annual)

Check `MRC-02` after all crossing permit applications are submitted and at
least priority crossings are issued.

---

### MRC-03 `[SECTOR-SPECIFIC]` — Signage permits

**What to do:**
Obtain signage permits from the municipality where trails pass through urban
or semi-urban zones, if required.

**When this applies:**

- Trail signs installed within municipal road allowances or public property
- Trail directional signs or warning signs within urban perimeters

**Not all municipalities require a permit for trail signs on private land.**
Confirm with the municipality's building or public works department.

**Cost:** Variable (typically $0–$200 per sign location)
**Delay:** 2–6 weeks

**If not applicable (trail does not pass through urban zones or municipality
does not require signage permits):** Record `MRC-03 — N/A` in the Permit Log
and check the step.

**After obtaining permits:** Record each in the Permit Log. Check `MRC-03`.

---

### MRC-04 `[SECTOR-SPECIFIC]` — Grooming depot and shelter permits

**What to do:**
If the club is constructing or has constructed a grooming equipment depot,
storage building, or trail shelter, confirm building permit requirements from
the municipality where the structure is located.

**Applicable permits may include:**

- Municipal building permit (permis de construction) from the municipality
- Quebec RBQ (Régie du bâtiment du Québec) permits for electrical or plumbing
  work within the building
- Environmental authorization if the site involves wetlands or watercourse setbacks

**If not applicable (no permanent structures being built):** Record
`MRC-04 — N/A` in the Permit Log and check the step.

**Cost:** Variable ($200–$2,000+ depending on structure size and municipality)
**Delay:** 4–12 weeks

**After permits confirmed:** Record each in the Permit Log. Check `MRC-04`.

---

## Completion

When MRC-01 through MRC-04 are checked (or marked N/A where not applicable),
update `qc-status.md`:
`- [x] quebec-mrc-permits — completed [YYYY-MM-DD]`

Then prompt: "MRC and municipal permit coverage is established. Renew
road-crossing permits annually (check Permit Log for expiry dates)."

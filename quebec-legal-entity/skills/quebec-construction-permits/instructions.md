# Quebec Construction Permits — RBQ and CCQ Compliance

This skill guides you through building permit and contractor compliance
requirements for a Quebec entity undertaking construction work.

---

## On Start

**Before proceeding:** Read `skills/_shared/learnings-protocol.md`. Then read
`skills/quebec-construction-permits/learnings.md` if it exists and incorporate any entries into your
working knowledge for this session.

1. Read `qc-status.md` for Organization name.
2. Read `qc-construction-permits.md` if present; create it from the template
   below if absent.
3. Ask: "What type of construction project are you planning?" to scope the
   applicable steps (new building, renovation, electrical/plumbing, storage
   structure, etc.).
4. Present current status; jump to first unchecked step.

**`qc-construction-permits.md` template (create if absent):**

````markdown
# Construction Permits Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps

- [ ] CON-01 — Scope of work defined (building type, size, location)
- [ ] CON-02 — Municipal building permit applied for
- [ ] CON-03 — RBQ contractor license verified for all contractors
- [ ] CON-04 — CCQ jurisdiction confirmed

## Permit Log

| Project | Permit type | Authority | Status | Issued | Expiry |
| --- | --- | --- | --- | --- | --- |
| — | — | — | pending | — | — |
````

---

## NEVER / ALWAYS

### NEVER

- Tell the user that hiring a non-union contractor exempts them from CCQ
  requirements — CCQ jurisdiction is based on the *type of work* (covered
  construction trades: electrical, plumbing, carpentry, masonry, etc.),
  not on the union status of the contractor
- Allow the user to skip CON-03 (RBQ license verification) — hiring an
  unlicensed contractor creates owner liability regardless of contract terms
  or what the contractor claims

### ALWAYS

- At CON-03: direct the user to rbq.gouv.qc.ca for the free public contractor
  license search before any contractor begins work; the search takes minutes
  and is the owner's responsibility
- At CON-04: confirm whether the work type falls under covered construction
  trades (electrical, plumbing, carpentry, masonry, roofing, etc.) — if yes,
  CCQ obligations apply regardless of contractor union status; direct user to
  ccq.org for sector-specific determination

---

## CRITICAL WARNINGS

> **RBQ license is mandatory:** All contractors performing work covered by the
> Building Act (Loi sur le bâtiment) — including electrical, plumbing,
> structural, and mechanical work — must hold a valid RBQ license. As the owner,
> you can face fines and insurance voidance if you hire an unlicensed contractor,
> even if you did not know the contractor was unlicensed. Verify at rbq.gouv.qc.ca
> before signing any contract.
>
> **CCQ applies by work type, not union status:** If a contractor performs work
> covered by a CCQ construction collective agreement (electrical, plumbing,
> carpentry, masonry, roofing, etc.), CCQ obligations apply even if the
> contractor is not unionized. This includes wage rates, working hours, and
> worker classifications. Verify at ccq.org.
>
> **Small and temporary structures:** Temporary or small structures may be exempt
> from municipal building permits but still must comply with the National Building
> Code of Canada. Check with your municipality before assuming an exemption applies.

---

## Steps

---

### CON-01 `[GENERIC][PROV]` — Define scope of work

**What to do:**
Define the full scope of the construction project before engaging contractors
or applying for permits:

- Type of structure (new building, addition, renovation, storage shed, electrical
  upgrade, plumbing installation)
- Gross floor area (m²) — determines permit class and fee tier
- Location (municipal address or lot description; proximity to wetlands,
  agricultural zones, or protected areas may trigger additional authorizations)
- Whether the structure will be permanent or temporary
- Whether the work involves regulated trades (electrical, plumbing, structural)

This scoping determines which of CON-02 through CON-04 apply to your project.

**Cost:** Free
**Delay:** 1 week (internal planning)

**After scoping:** Check `CON-01` in `qc-construction-permits.md`.

---

### CON-02 `[GENERIC][MUNIC]` — Apply for municipal building permit

**What to do:**
Apply for a permis de construction from the local municipality. A municipal
building permit is required for most fixed structures — new buildings,
additions, significant renovations, and changes of use.

**Process:**

1. Contact your municipality's service d'urbanisme to confirm whether a permit
   is required for your specific project
2. Submit plans (site plan, floor plans, elevations) as required
3. Pay the municipal permit fee
4. Wait for approval before beginning work

**Fee:** Typically $500–$5,000 depending on project size and municipality —
fees are usually calculated per $1,000 of construction value or per m²

**Delay:** 4–12 weeks for review and approval; larger projects may take longer

**After permit is issued:** Add to the Permit Log in `qc-construction-permits.md`
(Project, Permit type: "Municipal building permit", Authority: municipality name,
Status: issued, Issued date, Expiry date). Check `CON-02`.

---

### CON-03 `[GENERIC][PROV]` — Verify RBQ contractor license

**What to do:**
Before signing any contract with a contractor for covered construction work,
verify that the contractor holds a valid RBQ (Régie du bâtiment du Québec) license.

**Where:** rbq.gouv.qc.ca → "Vérifier une licence" — free public search

**What to verify:**

- The contractor's license number matches the license on the RBQ registry
- The license is currently active (not expired, suspended, or cancelled)
- The license class covers the type of work to be performed
  (e.g., general contractor, electrical subcontractor, plumbing subcontractor)

**Owner liability:** As the owner, you are responsible for ensuring your
contractors are licensed. Hiring an unlicensed contractor can void your
property insurance and expose you to fines under the Building Act.

**Cost:** Free (verification only)
**Delay:** Before hiring (takes minutes)

**After verifying all contractors:** Record each contractor's name, license
number, and license class in `qc-construction-permits.md`. Check `CON-03`.

---

### CON-04 `[GENERIC][PROV]` — Confirm CCQ jurisdiction

**What to do:**
Determine whether the construction work falls under the jurisdiction of the
Commission de la construction du Québec (CCQ).

CCQ jurisdiction applies based on the **type of work**, not the union status
of the contractor. Covered construction trades include:

- Electrical work
- Plumbing and mechanical
- Carpentry and joinery
- Masonry and concrete work
- Roofing
- Ironwork and structural steel
- Painting and finishing in a construction context

**If the work is covered:**

- Contractors must comply with the applicable CCQ collective agreement for
  that trade sector
- Workers must be registered with the CCQ and hold a CCQ competency card
- Wage rates, working hours, and worker classifications are governed by the
  CCQ collective agreement — not by the individual employment contract

**If the work is not covered** (e.g., owner-performed work, landscaping,
minor maintenance below thresholds): document the determination.

**Where to confirm:** ccq.org → sector determination tool, or call
CCQ at 1-888-842-8282

**Cost:** Free (determination only)
**Delay:** Before work starts

**After confirming:** Record the CCQ determination in `qc-construction-permits.md`.
Check `CON-04`.

---

## Completion

When CON-01 through CON-04 are checked (or explicitly marked N/A with reason
where not applicable), update `qc-status.md`:
`- [x] quebec-construction-permits — completed [YYYY-MM-DD]`

Then prompt: "Construction permit compliance is documented. Update the Permit
Log when new permits are obtained and when expiry or renewal dates approach.
If additional projects arise, re-run this skill starting from CON-01 to scope
the new work."

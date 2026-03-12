# Quebec Land Access — Droits de Passage Agreements

This skill guides you through negotiating and recording droits de passage (land
access agreements) with private landowners for Quebec snowmobile trail networks.

---

## On Start

1. Read `qc-status.md`. If `quebec-snowmobile-club` is `not started` or absent,
   tell the user: "Complete `/quebec-legal-entity:quebec-snowmobile-club` first
   — FCMQ membership (SNOW-01) must be submitted before negotiating land access."
   Exit.

2. Read `qc-land-access.md` if present; create it from the template below if absent.

3. Present current status; jump to first unchecked step.

**`qc-land-access.md` template (create if absent):**

```markdown
# Land Access Status — [organization name]
schema_version: 1
Last updated: YYYY-MM-DD

## Steps
- [ ] LND-01 — Trail inventory completed (all segments mapped)
- [ ] LND-02 — Landowner list compiled
- [ ] LND-03 — FCMQ agreement template obtained
- [ ] LND-04 — Priority agreements signed (segments blocking trail opening)
- [ ] LND-05 — Remaining agreements signed or alternate routes planned
- [ ] LND-06 — Annual renewal process established

## Agreements Log

| Segment | Landowner | Status | Signed | Renewal date | Notes |
| --- | --- | --- | --- | --- | --- |
| — | — | pending | — | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Suggest the club can open trails on private land without signed agreements —
  trespassing exposes the club and FCMQ to civil liability
- Mark LND-04 complete without recording each agreement in the Agreements Log

### ALWAYS

- At LND-02: recommend working with the local MRC cadastral office for landowner
  identification — they have the authoritative records
- At LND-04: remind the user that FCMQ regional representatives often have
  relationships with repeat landowners and can facilitate introductions
- After each agreement signed: record it in the Agreements Log in `qc-land-access.md`

---

## CRITICAL WARNINGS

> **Trail cannot open without access agreements:** Opening a trail on private
> land without a signed agreement is civil trespass. FCMQ's liability insurance
> does not cover incidents on unsanctioned trail segments.
>
> **Compensation varies widely:** Some landowners request nothing; others ask
> for cash (typically $50–$500/year per parcel), a grooming pass, or fuel
> assistance. Establish a consistent policy to avoid disputes.
>
> **Annual renewal:** Most agreements run year-to-year or multi-year. Track
> expiry dates — a lapsed agreement means the trail legally cannot open for
> that season.

---

## Steps

---

### LND-01 `[SECTOR-SPECIFIC]` — Trail inventory: map all segments

**What to do:**
Map all planned trail segments and identify which cross private land versus
public land (Crown land, municipal road allowances, hydro corridors).

- Use available topographic maps and the club's proposed trail route
- For each segment, record whether it is on private or public land
- Note segments that cross railway corridors or utility rights-of-way —
  these require separate authorizations (railway: Transport Canada; hydro:
  Hydro-Québec; pipeline: operator)

**Cost:** Free
**Delay:** 1–4 weeks

**After completing inventory:** Record trail segments in the Agreements Log
with landowner status `pending` for all private parcels. Check `LND-01` in
`qc-land-access.md`.

---

### LND-02 `[SECTOR-SPECIFIC]` — Compile landowner list

**What to do:**
Compile a list of all private landowners whose parcels the trail crosses.

- **Primary source:** MRC cadastral maps (rôle d'évaluation foncière) —
  available at the MRC planning office or via the MRC's online portal
- **Secondary source:** MRNF (Ministère des Ressources naturelles et des
  Forêts) for Crown land boundaries
- For each parcel, record: owner name, civic address or contact info, and
  which trail segment(s) cross their land

**Cost:** Free (public records)
**Delay:** 1–2 weeks

**After completing list:** Update the Agreements Log in `qc-land-access.md`
with landowner names. Check `LND-02`.

---

### LND-03 `[SECTOR-SPECIFIC]` — Obtain FCMQ standard agreement template

**What to do:**
Contact your FCMQ regional representative to obtain the standard droits de
passage agreement template. FCMQ maintains a standard form that is familiar
to repeat landowners throughout Quebec.

- The template specifies permitted use, liability, compensation (if any),
  duration, and renewal terms
- Do not draft your own agreement from scratch — the FCMQ template is the
  standard accepted by landowners across Quebec

**Cost:** Free
**Delay:** Immediate (contact regional rep)

**After obtaining template:** Note the template version and date received in
`qc-land-access.md`. Check `LND-03`.

---

### LND-04 `[SECTOR-SPECIFIC]` — Sign priority agreements

**What to do:**
Contact and negotiate with landowners whose parcels block trail opening.
Prioritize parcels where no alternate route exists.

**Negotiation approach:**

- Lead with the community benefit and the club's FCMQ affiliation
- Present the FCMQ standard template — do not improvise terms
- Compensation varies: some landowners request nothing; others ask for cash
  ($50–$500/year per parcel), a seasonal grooming pass, or fuel assistance
- Establish a consistent compensation policy to avoid disputes between
  landowners who compare notes

**FCMQ regional representative assistance:**

- FCMQ representatives often have established relationships with repeat
  landowners and can facilitate introductions — contact them before
  approaching landowners directly in a new territory

**Cost:** Variable (compensation per agreement)
**Delay:** Weeks to months (depends on landowner responsiveness)

**After each agreement signed:** Record in the Agreements Log:

- Segment name
- Landowner name
- Status: `signed`
- Signed date
- Renewal date (typically one year from signing, or as agreed)
- Notes (compensation terms, special conditions)

Check `LND-04` only after all priority-segment agreements are recorded.

---

### LND-05 `[SECTOR-SPECIFIC]` — Resolve remaining segments

**What to do:**
For trail segments not resolved in LND-04, either:

1. **Complete remaining agreements:** Continue negotiations with remaining
   landowners; apply the same approach as LND-04
2. **Plan alternate routes:** For segments where access cannot be obtained,
   identify alternate routes that avoid the uncooperative parcel

Record the resolution for each outstanding segment in the Agreements Log
(signed, or alternate route with notes explaining the rerouting).

**Cost:** Variable
**Delay:** Ongoing until all segments resolved

**After resolving all segments:** Verify every trail segment has either a
signed agreement or an alternate route documented. Check `LND-05` in
`qc-land-access.md`.

---

### LND-06 `[SECTOR-SPECIFIC]` — Establish annual renewal process

**What to do:**
Set up a systematic process to renew agreements before they expire each season.

- Review the Agreements Log for renewal dates at least 60 days before the
  earliest expiry
- Send renewal notices to all landowners; renegotiate terms if requested
- Update the Agreements Log renewal dates after each renewal
- Set calendar reminders in your club's administration calendar

**Cost:** Free
**Delay:** Annual recurring

**After establishing the process:** Document the renewal procedure (who is
responsible, what lead time to use) in a note in `qc-land-access.md`.
Check `LND-06`.

---

## Completion

When LND-04 and LND-05 are checked (all priority agreements signed and
remaining segments resolved), update `qc-status.md`:
`- [x] quebec-land-access — completed [YYYY-MM-DD]`

Then prompt: "Your trail network has legal land access coverage. Ongoing
obligations: renew agreements before expiry (LND-06) and record new segments
in the Agreements Log as the trail network expands."

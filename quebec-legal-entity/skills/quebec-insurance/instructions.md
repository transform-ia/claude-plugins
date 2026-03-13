# Quebec Entity Insurance — Coverage Guide

This skill guides you through selecting appropriate insurance coverage for your
Quebec entity. It is advisory — it helps you decide what you need and records
those decisions, but does not file anything with a government body.

---

## On Start

**Before proceeding:** Read `skills/_shared/learnings-protocol.md`. Then read
`skills/quebec-insurance/learnings.md` if it exists and incorporate any entries into your
working knowledge for this session.

1. Read `qc-status.md` for entity type (for-profit or OBNL) and Organization name.
2. Read `qc-insurance.md` if present; create it from the template below if absent.
3. Show current coverage log.
4. Ask: "Would you like to review all insurance sections, or jump to a specific one?"

**`qc-insurance.md` template (create if absent):**

```markdown
# Insurance Coverage Log
Organization: [organization name]
Last updated: YYYY-MM-DD

## Coverage

| Type | Required | Insurer | Policy # | Annual Premium | Renewal Date |
| --- | --- | --- | --- | --- | --- |
| General liability | pending | — | — | — | — |
| Directors & officers (D&O) | pending | — | — | — | — |
| Property | pending | — | — | — | — |
| Errors & omissions (E&O) | pending | — | — | — | — |
| Event liability | pending | — | — | — | — |
| Sector-specific | see snowmobile-club | — | — | — | — |
```

---

## NEVER / ALWAYS

### NEVER

- Tell the user that a specific insurer is the only option — present as examples
- Recommend skipping D&O coverage for any organization with a board of directors

### ALWAYS

- Note that snowmobile club trail operations insurance is handled in
  `quebec-snowmobile-club`, not here
- After each section, record the decision (obtained or explicitly declined)
  in `qc-insurance.md`

---

## Advisory Sections

For each section: explain what it covers, who needs it, typical cost range,
and how to obtain it. Ask whether the entity needs this coverage, then record
the decision in `qc-insurance.md`.

---

### INS-01 — General Liability

**What it covers:** Third-party bodily injury and property damage arising from
your organization's operations, premises, or products.

**Who needs it:** Any entity that interacts with the public, rents premises,
or has members attending events. This is the minimum baseline coverage.

**Why it matters:** Without it, a single incident (slip and fall at an event,
damage to a third party's property) could expose the organization to a lawsuit
that exceeds its assets.

**Typical cost:** $500–$2,000/year for a small OBNL, depending on activities
and revenue.

**How to obtain:** Any commercial insurer. For OBNLs, check if your sector
association (e.g., FCMQ) offers group rates.

---

### INS-02 — Directors & Officers (D&O)

**What it covers:** Personal liability of board members and officers for decisions
made in their capacity as directors. Covers legal defence costs and settlements
arising from claims of mismanagement, breach of duty, or wrongful acts.

**Who needs it:** Any organization with a board of directors. **Strongly recommended.**
Note that corporate structure does not fully shield directors from personal liability
(especially for source deductions — see payroll skill).

**Typical cost:** $1,000–$3,000/year for a small OBNL board.

**How to obtain:** Most commercial insurers; ask your general liability insurer
for a combined package.

---

### INS-03 — Property Insurance

**What it covers:** Physical assets owned by the organization: equipment,
vehicles, tools, buildings (if owned).

**Who needs it:** Any entity owning significant physical assets. For snowmobile
clubs: snowgroomers, trailers, storage facilities.

**Typical cost:** Varies by asset value — typically 1–2% of insured value per year.

**How to obtain:** Commercial property insurer; often bundled with general liability.

---

### INS-04 — Errors & Omissions (E&O) / Professional Liability

**What it covers:** Claims arising from professional advice, services, or work
products provided to clients or members.

**Who needs it:** Organizations providing professional services (consulting,
technical advice, certification). Typically not required for recreational OBNLs
or snowmobile clubs.

**Typical cost:** $1,500–$5,000/year depending on the nature of services.

**How to obtain:** Specialty insurers or professional association group policies.

---

### INS-05 — Event Liability

**What it covers:** Liability arising from specific events open to the public
(races, fundraisers, public trail openings).

**Who needs it:** Any organization holding public events not covered by their
general liability policy. Check your GL policy for event exclusions.

**Typical cost:** $200–$1,000 per event, or included in annual GL policy up to
a certain number of events.

**How to obtain:** Your existing insurer or specialist event insurers.

---

### INS-06 — Sector-Specific Coverage

For snowmobile club trail operations insurance (including groomer operators,
trail maintenance crews, and droits d'accès liability), refer to:
`/quebec-legal-entity:quebec-snowmobile-club` (step SNOW-04).

FCMQ provides base civil liability coverage ($1,000,000) with membership.
Supplemental D&O and property coverage should be arranged separately.

---

## Completion

When all sections have been reviewed and recorded, update `qc-status.md`:
`- [x] quebec-insurance — completed [YYYY-MM-DD]`

Then prompt: "Insurance review complete. Review annually before each renewal date
and after any significant change in activities, assets, or number of employees."

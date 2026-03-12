# Quebec Privacy — Law 25 Compliance Guide

This skill guides you through Law 25 (Act respecting the protection of personal
information in the private sector) compliance for a Quebec organization.

---

## On Start

1. Read `qc-status.md` for Organization name and entity type.
2. Read `qc-privacy.md` if present; create it from the template below if absent.
3. Present current status; jump to first unchecked step.

**`qc-privacy.md` template (create if absent):**

````markdown
# Privacy Compliance Status — [organization name]
schema_version: 1
Privacy_officer: pending
Last updated: YYYY-MM-DD

## Steps

- [ ] PRV-01 — Privacy officer designated
- [ ] PRV-02 — Personal information inventory completed
- [ ] PRV-03 — Privacy policy published
- [ ] PRV-04 — Consent mechanisms implemented
- [ ] PRV-05 — PIA process established for new projects
- [ ] PRV-06 — Breach response procedure documented
- [ ] PRV-07 — Individual rights request procedure established
````

---

## NEVER / ALWAYS

### NEVER

- Tell an organization with a membership list or employee records that Law 25
  does not apply — it applies to virtually all organizations operating in Quebec
  that collect personal information, including OBNLs and recreational clubs
- Skip PRV-06 — breach notification to the CAI is mandatory and time-limited
  (72 hours for serious risk)

### ALWAYS

- At PRV-01: note that for a small OBNL, any board member can be designated
  privacy officer (personne responsable de la protection des renseignements
  personnels); it does not require a dedicated position
- At PRV-05: explain that a PIA (évaluation des facteurs relatifs à la vie
  privée) is required before implementing any new system that collects or
  processes personal information in a new way
- After PRV-01: record the privacy officer's title and contact in `qc-privacy.md`
  (Privacy_officer field)

---

## CRITICAL WARNINGS

> **Law 25 applies to OBNLs:** The law covers all organizations operating in
> Quebec that collect personal information. A snowmobile club's membership list,
> event registration, and website analytics all involve personal information.
> All three phases are now in effect (Sept 2022, Sept 2023, Sept 2024).
>
> **72-hour breach notification:** If a security incident involving personal
> information poses a serious risk of injury, notify the Commission d'accès à
> l'information (CAI) within 72 hours and notify affected individuals as soon
> as possible.
>
> **Penalties:** The CAI can impose fines up to $25,000,000 or 4% of worldwide
> turnover for serious violations.

---

## Steps

---

### PRV-01 `[GENERIC][PROV]` — Designate a privacy officer

**What to do:**
Designate a privacy officer (personne responsable de la protection des
renseignements personnels). For a small OBNL, any board member (e.g., the
Secretary or President) can take this role — it does not require a dedicated
employee.

Publish the privacy officer's title and contact information on your website.
This is a public disclosure requirement under Law 25.

**Cost:** Free
**Delay:** Immediate

**After designating:** Record the officer's name (or title) and contact in
`qc-privacy.md` (Privacy_officer field). Check `PRV-01`.

---

### PRV-02 `[GENERIC][PROV]` — Complete personal information inventory

**What to do:**
Inventory all personal information collected by your organization. For each
category, document:

- Who is the information about (members, employees, donors, website visitors)
- What information is collected (name, address, email, payment info, IP address)
- Why it is collected (purpose)
- Where it is stored (software, server location, paper files)
- How long it is retained (retention schedule)
- Who has access (staff, board members, service providers)

This inventory is the foundation for your privacy policy (PRV-03) and PIA
process (PRV-05).

**Cost:** Free (internal effort)
**Delay:** 1–4 weeks

**After completing inventory:** Check `PRV-02` in `qc-privacy.md`.

---

### PRV-03 `[GENERIC][PROV]` — Publish a privacy policy

**What to do:**
Publish a privacy policy on your website describing:

- What personal information is collected and why
- How it is used and to whom it may be disclosed
- How long it is retained
- How individuals can access or correct their information
- The privacy officer's contact information

The policy must be written in plain language and accessible to anyone who
interacts with your organization.

**Cost:** Free (internal effort); $0–$500 for legal review
**Delay:** 1–2 weeks

**After publishing:** Record the URL or location in `qc-privacy.md`. Check `PRV-03`.

---

### PRV-04 `[GENERIC][PROV]` — Implement consent mechanisms

**What to do:**
Implement appropriate consent mechanisms based on the sensitivity of the
information and how it is used:

- **Explicit consent:** Required for sensitive personal information (health,
  financial, biometric data) and for secondary uses beyond the original purpose
- **Opt-out:** Acceptable for cookies, analytics, and non-sensitive marketing
  communications — but an opt-out mechanism must be clearly provided
- **Parental consent:** Required for collecting personal information from
  minors under 14

Review your website, registration forms, and member onboarding for gaps.

**Cost:** Free–$500 (depending on website update complexity)
**Delay:** 1–4 weeks

**After implementing:** Check `PRV-04` in `qc-privacy.md`.

---

### PRV-05 `[GENERIC][PROV]` — Establish PIA process for new projects

**What to do:**
Establish a process to conduct a Privacy Impact Assessment (évaluation des
facteurs relatifs à la vie privée / EFVP) before implementing any new project
that involves collecting or processing personal information in a new way.

A PIA must be completed before:

- Launching a new website feature that collects personal information
- Adopting new software that stores or processes member data
- Partnering with a third party that will have access to personal information
- Communicating personal information outside Quebec

The PIA identifies risks and required safeguards before the project begins —
not after.

**Cost:** Free (internal effort)
**Delay:** Before next project

**After establishing process:** Document the PIA checklist or procedure.
Check `PRV-05` in `qc-privacy.md`.

---

### PRV-06 `[GENERIC][PROV]` — Document breach response procedure

**What to do:**
Document a security incident response procedure that addresses the mandatory
breach notification obligations under Law 25:

1. **Detection and containment:** Who is responsible for identifying a breach
   and taking immediate containment steps
2. **Risk assessment:** Determine whether the incident poses a serious risk of
   injury to the affected individuals (identity theft, discrimination, loss,
   damage, distress)
3. **CAI notification:** If serious risk is identified, notify the Commission
   d'accès à l'information (CAI) **within 72 hours** via cai.gouv.qc.ca
4. **Individual notification:** Notify affected individuals as soon as
   feasible when serious risk is confirmed
5. **Incident register:** All incidents involving personal information must be
   logged in an incident register (registre des incidents), regardless of
   whether they trigger notification

**Cost:** Free (internal effort)
**Delay:** 1 week

**After documenting procedure:** Check `PRV-06` in `qc-privacy.md`.

---

### PRV-07 `[GENERIC][PROV]` — Establish individual rights request procedure

**What to do:**
Establish a procedure for handling requests from individuals exercising their
rights under Law 25:

- **Right of access:** An individual may request access to their personal
  information held by your organization
- **Right of rectification:** An individual may request correction of inaccurate
  information
- **Right to withdrawal of consent:** An individual may withdraw consent for
  collection or use of their information
- **Response deadline:** You must respond within **30 days** of receiving a
  request

Document who handles requests, how requests are submitted (form, email, in
writing), how identity is verified, and how responses are issued.

**Cost:** Free (internal effort)
**Delay:** 1 week

**After establishing procedure:** Check `PRV-07` in `qc-privacy.md`.

---

## Completion

When all PRV steps are checked, update `qc-status.md`:
`- [x] quebec-privacy — completed [YYYY-MM-DD]`

Then prompt: "Law 25 compliance framework is in place. Revisit annually:
re-run the PIA for any new systems (PRV-05) and update the privacy policy
when data practices change (PRV-03). If a security incident occurs, follow
the breach response procedure (PRV-06) — the 72-hour CAI notification window
is mandatory."

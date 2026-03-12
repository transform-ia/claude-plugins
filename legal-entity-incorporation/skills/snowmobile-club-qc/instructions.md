# Quebec Snowmobile Club — Sector-Specific Operations

This skill guides you through sector-specific steps for a Quebec snowmobile club
after your OBNL has been incorporated (letters patent received, constitutive
assembly held).

---

## On Start: Read State File and Check Prerequisites

1. Read `obnl-status.md`. If absent, tell the user:
   > "Start with `/legal-entity-incorporation:quebec-incorporation` first."

2. Verify these prerequisite steps are checked:
   - S2-05 (letters patent + NEQ received)
   - S2-06 (constitutive general assembly held)

   If either is missing, list the blocking steps and stop.

3. Verify the NEQ field in `obnl-status.md` is populated (not "pending"). If still
   "pending", tell the user: "Your NEQ number is needed to apply for FCMQ membership.
   Update the NEQ field in obnl-status.md with the 10-digit number from your letters
   patent before continuing."

4. **PACM calendar alert:** Check the current date against the MTQ/PACM
   application window (June 1 – August 31 of each year):
   - If currently in the window: "⚠️ The MTQ/PACM application window is OPEN
     (June–August). Complete FCMQ membership (S3-01/S3-02) immediately to be
     eligible to apply this cycle."
   - If outside the window: "ℹ️ The next MTQ/PACM application window opens in
     June. You have time to complete FCMQ membership before then."

5. Present current S3-xx status and jump to first unchecked step.

---

## NEVER / ALWAYS

### NEVER

- Suggest the club can issue charitable tax receipts (it cannot — 149(1)(l) NPO)
- Skip the PACM calendar warning at skill start
- Mark E4 (trail designation) complete before the user confirms MTQ approval

### ALWAYS

- Remind the user that FCMQ contact should happen early — board meeting
  schedule affects the admission timeline
- Warn that missing the June–August PACM window means waiting a full year
- Confirm the user has their NEQ before starting S3-01

---

## Steps

---

### S3-01 `[SECTOR-SPECIFIC]` — Apply for FCMQ membership

**What to do:**
Submit a membership application to the Fédération des clubs de motoneigistes
du Québec (FCMQ).

**Contact FCMQ early** — admission requires a board decision, and board meetings
follow a schedule. The earlier you apply, the sooner you can access funding.

**Contact:**

- Email: <info@fcmq.qc.ca>
- Phone: 418-847-0898
- Website: fcmq.qc.ca

**Admission conditions:**

- Must be a legally constituted OBNL (letters patent required)
- Must operate or intend to operate a snowmobile trail network
- Application submitted to and approved by the FCMQ board of directors

**What membership gives you:**

- Access to the 30,000+ km FCMQ trail network
- Eligibility for MTQ/PACM financial assistance (Volet 1 + Volet 2)
- Group civil liability insurance ($1,000,000)
- Technical support, grooming equipment programs, signage standards
- Regional assembly participation (2–4 votes depending on club size)
- Droits d'accès revenue distribution system

**Cost:** Annual membership fee (confirm exact amount with FCMQ)
**Delay:** Application immediate; board approval weeks to months

**After confirming submission:** Check `S3-01` in `obnl-status.md`.

---

### S3-02 `[SECTOR-SPECIFIC]` — FCMQ membership approved

**What to do:**
Wait for FCMQ board approval of the membership application.

Follow up with FCMQ if you have not heard back within the expected timeframe
given their next board meeting date.

**Cost:** Included in S3-01
**Delay:** Depends on FCMQ board meeting schedule

**After confirming approval:** Check `S3-02` in `obnl-status.md`.

---

### S3-03 `[SECTOR-SPECIFIC]` — Apply for MTQ/PACM financial assistance

**What to do:**
Apply for the Programme d'aide financière aux clubs de motoneigistes du Québec
(PACM), administered by the Ministère des Transports du Québec (MTQ).

**⚠️ CRITICAL: Application window is June 1 – August 31 annually.**
Missing this window means waiting a full year for the next funding cycle.
Current program runs through March 31, 2027.

**Two funding components:**

**Volet 1 — Trail maintenance (entretien des sentiers):**

- Largest funding component
- Apply directly to MTQ during the annual call for projects
- Amount distributed based on trail kilometers, maintenance costs, regional factors
- Example: ~$545,000 distributed to Abitibi-Témiscamingue clubs in one cycle

**Volet 2 — Safety and club support (sécurité et soutien):**

- Administered through FCMQ
- Contact FCMQ directly for this component

**Eligibility:**

- Must be an active FCMQ member (S3-02 must be complete)
- Demonstrated snowmobile trail maintenance mission
- Must submit within the call-for-projects period

**Cost:** Free to apply
**Delay:** Annual application; funding allocated by fiscal year

**After confirming submission:** Check `S3-03` in `obnl-status.md` and record
the application year (E2_next_window).

---

### S3-04 `[SECTOR-SPECIFIC]` — Obtain liability insurance

**What to do:**
Ensure adequate insurance coverage for the club and its activities.

**FCMQ base coverage (included with membership):**

- $1,000,000 civil liability for the club and its activities
- Covers: trail maintenance operations, club events, member activities on trails

**Additional coverage recommended:**

- Directors and officers (D&O) liability — protects board members personally
- Property insurance for any equipment owned (snowgroomers, tools)
- Event insurance for organized races or public events

**Contact FCMQ's group insurer for member rates:**

- La Capitale / Intact (FCMQ preferred insurer — confirm current insurer with FCMQ)
- Expected range: $1,500–$4,000/year for D&O + equipment coverage on top of
  FCMQ base

**Cost:** $1,500–$4,000/year estimated for supplemental coverage
**Delay:** Concurrent with FCMQ membership process

**After confirming completion:** Check `S3-04` in `obnl-status.md`.

---

### S3-05 `[SECTOR-SPECIFIC]` — VHR Act trail designation (Loi sur les VHR)

**What to do:**
Obtain official trail network designation from the Ministère des Transports du
Québec under the Quebec Off-Highway Vehicles Act (Loi sur les véhicules hors route).

**Why this matters:** Trail designation is required to legally issue droits d'accès
(trail access fees/passes) to snowmobilers. Without designation, you cannot legally
collect trail access revenue.

**Process:**

- Work with your FCMQ regional representative — FCMQ assists clubs through this
  process
- Submit trail network map and documentation to MTQ
- MTQ reviews and approves the designated trail network

**Cost:** Variable (confirm with MTQ / FCMQ)
**Delay:** Variable — coordinate timing with FCMQ representative

**After confirming designation:** Check `S3-05` in `obnl-status.md`.

---

### S3-06 `[SECTOR-SPECIFIC]` — Annual FCMQ renewal and reporting (recurring)

**What to do:**
Renew FCMQ membership annually and fulfill annual reporting obligations.

**Annual obligations:**

- Renew membership with FCMQ (before the deadline they specify)
- Submit trail maintenance reports and activity statistics
- Provide financial data as required by FCMQ
- Participate in regional assemblies (2–4 votes depending on club size)
- Renew insurance coverage

**Cost:** Annual FCMQ membership fee + insurance renewal
**Delay:** Annual recurring obligation

**After confirming completion:** Check `S3-06` and record next renewal date.

---

## Completion

When all S3 steps are checked, prompt:
"Your snowmobile club is now fully operational! Here's a summary of your ongoing
annual obligations:

**Provincial:**

- S1-08: REQ annual update declaration ($41)
- S2-08: CO-17.SP tax return (Revenu Québec)
- S2-10: Annual general assembly
- S3-06: FCMQ renewal + PACM application (June–August window)

**Federal:**

- S2-09: T2 + T1044 (CRA)

**Tip:** Set calendar reminders for the June PACM window and your REQ update
notice — these are the two easiest obligations to miss."

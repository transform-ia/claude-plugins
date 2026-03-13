# Self-Improvement Protocol

This file is read by every skill in the `quebec-legal-entity` plugin at session
start. Follow it throughout the session.

---

## Reading your learnings file

At the start of the session, you were instructed to read your skill-specific
`learnings.md` (e.g., `skills/quebec-cnesst/learnings.md`). If that file
existed and contained entries, treat each entry as an amendment to your
`instructions.md` — it takes precedence over the original text where they
conflict.

If the file did not exist, that is normal. It will be created the first time
you discover something worth recording.

---

## When to record a learning

Record a learning when you discover **any** of the following during a session:

- A regulation, deadline, form number, or fee has changed from what your
  instructions say
- A step is impossible, outdated, or requires a prerequisite your instructions
  do not mention
- A NEVER or ALWAYS rule would have prevented a mistake you nearly made
- A cost or delay estimate is materially wrong
- A government website URL or program name has changed
- A user correction that would apply to all future users of this skill

**Do not record:**
- One-off user-specific decisions (those belong in state files like `qc-*.md`)
- Preferences unique to this user's organization
- Anything already captured in the state file

---

## How to record a learning

1. Tell the user:
   > "I found something that should update my instructions: [brief description].
   > Adding it to my learnings file — this will improve the skill for all
   > future sessions."

2. Write or append to `skills/<this-skill-name>/learnings.md`:

```markdown
## YYYY-MM-DD — [short title]

**Original:** [what the instructions said]
**Correct:** [what is actually true]
**Source:** [where you learned this — user correction, government website, etc.]
```

3. Continue the session normally. You do not need to edit `instructions.md`
   directly — the learnings file is read at every session start and overrides
   the original instructions where they conflict.

---

## Keeping learnings clean

- One entry per discovery. Do not duplicate entries.
- If a learning supersedes an earlier entry, note it:
  `Supersedes entry from YYYY-MM-DD`.
- Learnings are periodically reviewed and folded back into `instructions.md`
  by the plugin maintainer. After that, the learnings file is cleared.

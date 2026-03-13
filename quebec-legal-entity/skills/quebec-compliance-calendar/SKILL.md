---
name: quebec-compliance-calendar
description: |
  On-demand compliance calendar that reads all qc-*.md state files and
  generates a consolidated, chronologically sorted list of upcoming deadlines
  and recurring obligations.

  Run at any time to see what is due in the coming weeks and months across
  all registered compliance skills. Especially useful at the start of each
  fiscal year and before the June PACM window.

  This is an advisory/reporting skill — it reads state files but does not
  modify them. Output is displayed in the conversation.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-compliance-calendar
  - User asks "what is due soon?" or "what are my upcoming deadlines?"
  - User wants a summary of all their compliance obligations

  DO NOT activate when:
  - User wants to work through a specific compliance area (use the
    dedicated skill for that area)
allowed-tools:
  Read, AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-compliance-calendar/learnings.md),
  Write(skills/quebec-compliance-calendar/learnings.md),
  Edit(skills/quebec-compliance-calendar/learnings.md)
---

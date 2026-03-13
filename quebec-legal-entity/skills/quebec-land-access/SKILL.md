---
name: quebec-land-access
description: |
  Interactive guide for negotiating and recording droits de passage (land access
  agreements) with private landowners for Quebec snowmobile trail networks.

  Covers landowner inventory, FCMQ standard agreement templates, negotiation
  approach, compensation structures, and annual renewal tracking.

  Without signed access agreements, trails cross private land without legal
  basis. This skill is critical before any trail opens to the public.

  Reads and writes qc-land-access.md to track progress.

  ONLY activate when:
  - User invokes /quebec-legal-entity:quebec-land-access
  - User is a Quebec snowmobile club needing land access agreements for trails
  - User asks about droits de passage or landowner permission for trail networks

  DO NOT activate when:
  - User has not yet obtained FCMQ membership (complete quebec-snowmobile-club first)
  - User is asking about MRC or municipal permits (use quebec-mrc-permits)
allowed-tools:
  Read, Write(qc-status.md), Edit(qc-status.md),
  Write(qc-land-access.md), Edit(qc-land-access.md), AskUserQuestion,
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/quebec-land-access/learnings.md),
  Write(skills/quebec-land-access/learnings.md),
  Edit(skills/quebec-land-access/learnings.md)
---

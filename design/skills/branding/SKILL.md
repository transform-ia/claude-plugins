---
name: branding
description: |
  Thorough brand identity session for any company or project. Conducts an
  18-question discovery process across five phases (foundation, audience,
  personality, visual direction, context), then generates a complete brand
  kit in one session.

  Outputs three files:
  - brand.md — brand strategy, voice guidelines, visual identity rules
  - brand-prompts.md — Nano Banana 2 logo and photography prompts
  - brand-tokens.json — design tokens and CSS custom properties

  ONLY activate when:
  - User invokes /design:branding
  - User asks to create a brand, logo, or visual identity for a company
  - User asks "how should my company look" or "we need a brand"

  DO NOT activate when:
  - User already has a brand and is asking to apply it to code (use
    the token file they already have)
  - User is asking about UI component design (not a brand question)
allowed-tools:
  AskUserQuestion,
  Write(brand.md), Write(brand-prompts.md), Write(brand-tokens.json),
  Read(skills/_shared/learnings-protocol.md),
  Read(skills/branding/learnings.md),
  Write(skills/branding/learnings.md),
  Edit(skills/branding/learnings.md)
---

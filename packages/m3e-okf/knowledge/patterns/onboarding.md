---
type: pattern
title: Onboarding
description: Introducing a product or feature with a short, skippable, value-first sequence.
resource: https://m3.material.io/foundations/content-design/overview
tags: [pattern, onboarding, first-run, expressive, content-design]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/content-design/overview
    retrieved: 2026-07-11
    note: Clear, concise, value-first messaging.
---

Onboarding is the first-run sequence that orients a new user or introduces a new feature.
It is one of the few surfaces where richer [expressive](/expressive/applying-expressive)
treatment earns its place, because it is spacious, one-time, and about making a good
first impression — but it still has to respect the user's goal of getting to the product.

## Shape

A short sequence of steps, each carrying a single idea: what the product does, one or two
things that matter, and permissions or setup that genuinely must happen up front. A
progress indicator (dots or a [stepper](/implementations/m3e-web/components/stepper)) shows
how far the sequence runs.

## Principles

- **Lead with value, not features.** Say what the user gets, in plain language; see
  [content design](/foundations/content-design).
- **Keep it short.** Every extra screen is a chance to abandon. Ask only for what is
  needed now, and defer the rest to in-context prompts later.
- **Always skippable.** Provide a clear way to skip or dismiss; a user who already knows
  the product should not be trapped.
- **One idea per step.** Do not stack multiple asks or emphasized elements on one screen;
  see [too many emphasis levels](/anti-patterns/too-many-emphasis-levels).

## Expressive treatment, applied well

This is the right place for spring motion and shape morphing to add a moment of delight —
but honor reduced-motion, keep transitions quick enough that a fast user is not held up,
and never let the animation become the reason someone can't skip. See
[applying expressive](/expressive/applying-expressive) and
[accessibility](/foundations/accessibility).

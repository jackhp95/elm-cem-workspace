---
type: anti-pattern
title: Over-expressive motion in dense workflows
description: Applying springy, morphing, attention-grabbing motion to dense, repetitive, task-focused screens.
resource: https://m3.material.io/styles/motion/overview/how-it-works
tags: [anti-pattern, motion, expressive, density, performance]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://design.google/library/expressive-material-design-google-research
    retrieved: 2026-07-11
    note: Expressive design aids usability only when well applied.
---

## The mistake

The full expressive motion toolkit — bouncy springs, shape morphs, animated
transitions — is applied uniformly to a dense, work-focused surface: a data table, a
long settings list, an editor, an inbox scanned hundreds of times a day. Every row
springs, every toggle morphs, every scroll bounces.

## Why it hurts

Motion is an attention tool, and attention is exactly what a power user is trying to
spend on their task, not on the chrome. In a dense, repetitive workflow the same
animation the user has already seen a thousand times becomes a tax: it delays the moment
a control is usable, competes with the content for the eye, and — under rapid input —
can feel sluggish or janky as animations queue. The research behind
[expressive design](/expressive/research-rationale) shows emphasis helps *when applied
well*; applied to everything at once, it stops distinguishing anything and just slows
the interface down.

## The better alternative

Scale expression to the surface's job:

- **Reserve rich motion for spacious, consumer-facing moments** — onboarding, a hero
  action, a first-run flow — where a little delight has room to land.
- **In dense workflows, keep motion functional and quick** — short, low-emphasis
  transitions that clarify what changed, not that perform. Use the calmer
  [motion](/expressive/motion-physics) spring roles rather than the liveliest ones.
- **Honor reduced-motion** everywhere, and treat it as the baseline experience, not a
  degraded one. See [accessibility](/foundations/accessibility) and
  [applying expressive](/expressive/applying-expressive).

If a user has to wait for the UI to finish moving before they can act, the motion is
working against them.

---
type: pattern
title: Applying expressive
description: How to use motion, shape, and emphasis to guide attention without overwhelming a UI.
resource: https://m3.material.io/blog/building-with-m3-expressive
tags: [expressive, pattern, emphasis, restraint, hierarchy]
timestamp: 2026-07-11T00:00:00Z
diataxis: how-to
sources:
  - url: https://design.google/library/expressive-material-design-google-research
    retrieved: 2026-07-11
    note: Expressive design helps usability only when well applied.
---

Material 3 Expressive gives a UI three attention tools — physics-based motion,
morphing shape, and emphasized type. Each works by contrast, so each loses its power
when overused. Applying expressive well is mostly a discipline of scarcity.

## Pick the moments that lead

Before reaching for emphasis, decide what the screen is *for*. Every screen has a small
number of elements that lead — the primary action, the one status a user is waiting on,
the heading that orients them. Those are the candidates for expressive treatment.
Everything else should stay quiet so the leads have something to stand out against.

## One channel per moment is usually enough

Motion, shape, and emphasis are additive. A primary action that morphs its shape,
springs on press, *and* carries emphasized type is often one signal too many — it reads
as busy rather than important. Prefer a single strong channel per moment: emphasize the
type, or morph the shape, and let the others stay neutral.

## Respect density

Expressive motion and morphing suit spacious, consumer-facing surfaces. In a dense,
information-heavy workflow — a data table, a settings list, an editor — constant
movement fights the user's task. Dial expression down where people are working fast and
repetitively. See
[over-expressive motion in dense workflows](/anti-patterns/over-expressive-motion-in-dense-workflows).

## Keep accessibility non-negotiable

Expression layers on top of the foundations; it never overrides them. Motion honors
reduced-motion preferences, shape changes never become the *only* signal of state,
and emphasized type still meets contrast and target requirements. See
[accessibility](/foundations/accessibility) and
[color-only state signaling](/anti-patterns/color-only-state-signaling).

## Measure against the research

The [research rationale](/expressive/research-rationale) sets the bar: expressive design
made people find key elements up to four times faster — *when well applied*. If a
treatment does not help a user find or do something faster, it is decoration, and
decoration is where over-expression starts. When in doubt, remove a signal and see if
the screen still leads the eye where it should.

---
type: concept
title: Motion
description: Consistent, emotionally tuned transitions driven by shared easing and duration.
resource: https://m3.material.io/styles/motion/overview/how-it-works
tags: [styles, motion, easing, duration, reduced-motion]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration
    retrieved: 2026-07-11
    note: Easing and duration system.
  - url: https://m3.material.io/styles/motion/overview/how-it-works
    retrieved: 2026-07-11
    note: Motion physics overview.
  - url: https://m3.material.io/styles/motion/transitions
    retrieved: 2026-07-11
    note: The named transition patterns (container transform, shared axis, fade through).
---

Motion makes transitions consistent and emotionally tuned through a shared system
of **easing** and **duration**. A common set of curves and timings means related
transitions feel like one family rather than each being tuned by hand.

## Easing and duration

Easing shapes how a transition accelerates and settles; duration sets how long it
runs. Drawing both from the system keeps motion coherent across a UI.

## Physics-based motion

Some interactions use a spring-based physics model instead of a fixed curve, so
they respond with natural momentum. Which interactions use physics is an
implementation choice layered on the shared system.

## Transition patterns

Material names a few transition patterns and matches each to the *relationship*
between the two states, so the movement itself communicates how they connect:

- **Container transform** — one element visibly transforms into another, morphing a
  shared container from its start size and position to its end. Use it when opening an
  element expands into a fuller view: a card into its detail, a search bar into a search
  view. It creates a strong "this became that" connection.
- **Shared axis** — two states with a spatial or navigational relationship slide and
  fade together along a shared axis (x, y, or z). Use it for steps in a sequence or
  levels of a hierarchy — a stepper's next step, drilling one level down — so direction
  reinforces where the user moved.
- **Fade through** — two states with **no** strong relationship cross-fade: the outgoing
  content fades out, then the incoming content fades in (and scales up slightly). Use it
  when swapping unrelated content, such as switching top-level destinations, where there
  is nothing to morph or slide.

Choosing the pattern that matches the relationship keeps motion meaningful rather than
decorative. In Material 3 Expressive these transitions are driven by
[spring physics](/expressive/motion-physics) rather than fixed curves.

## Reduced motion

Motion respects a reduced-motion preference, simplifying or disabling transitions
so expressive movement never gets in the way of comfort or accessibility. Treat the
reduced-motion experience as a first-class path, not a degraded one — the transition
should still communicate the state change, just without the flourish.

---
type: concept
title: Motion physics
description: Springs replace fixed easing and duration, giving transitions natural momentum.
resource: https://m3.material.io/styles/motion/overview/how-it-works
tags: [expressive, motion, physics, spring, easing, duration]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/motion/overview/how-it-works
    retrieved: 2026-07-11
    note: Motion system overview.
  - url: https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/
    retrieved: 2026-07-11
    note: M3E introduces smoother, more natural animation.
---

In baseline Material, a transition is defined by two numbers and a shape: a
**duration** (how long it runs) and an **easing curve** (how it accelerates and
settles). Material 3 Expressive replaces that description with a **spring** — a
physical model defined by stiffness and damping rather than by time.

## What a spring changes

A spring does not run for a fixed length of time; it settles when the physics say it
has settled. That has three consequences:

- **Momentum carries over.** If an element is already moving when a new gesture
  arrives, the spring continues from that velocity instead of snapping to a fresh
  curve. Motion feels continuous rather than restarted.
- **Interruptions are graceful.** A spring can be redirected mid-flight and still
  settle smoothly, so a UI that responds to rapid input never looks like it is
  fighting itself.
- **Character comes from stiffness and damping.** A stiffer, less-damped spring feels
  quick and lively; a softer, more-damped one feels calm and deliberate. Tuning those
  two properties sets a transition's personality without picking a bespoke curve.

## Spring roles

Rather than tuning every transition by hand, M3E groups springs into named roles —
spatial springs that move things through space, and effect springs for properties
like color or opacity — at a few emphasis levels. Choosing a role keeps related
motion in family, the same way the baseline system keeps easing and duration
coherent. See baseline [motion](/styles/motion) for how the shared system frames this.

## Reduced motion still governs

Physics-based motion does not override a user's reduced-motion preference. When that
preference is set, expressive movement is simplified or removed so momentum and bounce
never come at the cost of comfort or accessibility. See
[accessibility](/foundations/accessibility).

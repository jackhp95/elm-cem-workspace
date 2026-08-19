---
type: concept
title: Shape morphing
description: An expanded shape library plus animated transforms that morph a control between shapes on interaction.
resource: https://m3.material.io/styles/shape/overview-principles
tags: [expressive, shape, morph, corner-radius, animation]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/shape/overview-principles
    retrieved: 2026-07-11
    note: Shape principles and the shape system.
  - url: https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/
    retrieved: 2026-07-11
    note: M3E adds a broader shape library and shape morphing.
---

Baseline Material treats shape as a mostly static choice: a surface picks a corner
radius from the shape scale and holds it. Material 3 Expressive keeps that scale and
adds two things — a much larger **library of shapes** and **shape morphing**, the
animated transformation of a control from one shape into another.

## The expanded library

M3E ships a substantially larger set of shapes than baseline Material — reported as
35 new shapes in the launch materials — including squircles, pill and cookie forms,
scalloped and clover-like outlines, and other distinctive silhouettes. The point is
range: a designer can give a surface a recognizable form without hand-drawing a
one-off outline that would drift out of the system.

> Note: the specific count of 35 is drawn from Google's M3E launch coverage; the
> canonical shape reference is the m3.material.io shape section, which is a JS
> application and may not enumerate the full library in a fetchable form.

## Morphing between shapes

Morphing animates the corners themselves. A control can start as a rounded square at
rest and become a circle when pressed, then return — the transition interpolates the
shape rather than swapping one image for another. Because the morph is driven by the
shape system, it stays on the radius scale throughout instead of passing through
arbitrary intermediate values.

## Shape as a state signal

Morphing gives shape a job it did not have before: signaling state. A pressed or
selected control can change its silhouette, adding a channel of feedback beyond color
and elevation. That extra channel is useful for accessibility, since it does not rely
on color alone — see [color-only state signaling](/anti-patterns/color-only-state-signaling).

## Restraint

Because a morph draws the eye, it belongs on moments that matter — a primary action,
a selection, a state change — not on every control at once. Constant morphing across a
dense screen turns a helpful signal into noise. See
[applying expressive](/expressive/applying-expressive). For the baseline corner-radius
scale this builds on, see [shape](/styles/shape).

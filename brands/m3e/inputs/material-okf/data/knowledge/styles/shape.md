---
type: concept
title: Shape
description: Corner rounding carries brand and hierarchy through a fixed radius scale.
resource: https://m3.material.io/styles/shape/overview-principles
tags: [styles, shape, corner-radius, morph, shape-library]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/shape/corner-radius-scale
    retrieved: 2026-07-11
    note: The corner-radius scale steps.
  - url: https://m3.material.io/styles/shape/overview-principles
    retrieved: 2026-07-11
    note: Shape principles and consistency.
  - url: https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/
    retrieved: 2026-07-11
    note: The expanded M3E shape library (reported as 35 new shapes) and morphing.
---

Shape uses corner rounding to carry brand and signal hierarchy. Corners come from
a fixed **radius scale** rather than arbitrary values, so shapes stay consistent
across a UI.

## The radius scale

The scale runs from none through extra-small, small, medium, large, and
extra-large, up to a full pill. Sizing a surface's corners from a scale step —
instead of a one-off radius — keeps it in family with everything else. Larger
surfaces generally take larger corners; small controls take smaller ones, so the
rounding reads as proportionate rather than arbitrary.

## The expanded shape library

Beyond the corner-radius scale, Material 3 Expressive adds a much larger **library of
shapes** — reported as 35 new shapes in Google's launch materials — that go past
rounded rectangles into squircles, pills, cookie and clover forms, scalloped outlines,
and other distinctive silhouettes. The library gives a surface a recognizable form
without a hand-drawn, off-system outline. (The exact count of 35 comes from the M3E
launch coverage; the canonical shape section on m3.material.io is a JS application and
may not enumerate the full set in a fetchable form.)

## Shape morphing

Some controls morph their shape between rest, hover, and pressed as an expressive
touch — a rounded square becoming a circle on press, for example. The morph animates
the corners themselves and is driven by the shape system, so it stays on the radius
scale throughout; animating corner radius by hand instead drifts off the scale.
Morphing also gives shape a role as a **state signal** that does not depend on color,
which helps accessibility. For the full expressive treatment, see
[shape morphing](/expressive/shape-morphing).

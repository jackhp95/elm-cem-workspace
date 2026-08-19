---
type: concept
title: Layout
description: Choose navigation and pane structure by window size class, not by device.
resource: https://m3.material.io/foundations/layout/layout-overview/overview
tags: [foundations, layout, responsive, panes, navigation]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/layout/breakpoints/overview
    retrieved: 2026-07-11
    note: Width breakpoints and size classes.
  - url: https://m3.material.io/foundations/layout/canonical-examples/overview
    retrieved: 2026-07-11
    note: Canonical layouts (list-detail, supporting pane, feed).
---

Layout in an adaptive model is chosen by the **window size class** — a width
band — rather than by a device category. Pick the navigation and pane structure
for the size class, then let it adapt as the window changes.

## Window size classes

Width is grouped into classes — compact, medium, expanded, and wider. A phone in
portrait sits in the compact class; a large window sits in the expanded class or
beyond. The class, not the hardware, drives the layout decision.

## Navigation across size classes

The responsive navigation pattern shifts with the size class: a bottom bar at
compact widths, a side rail at medium widths, and a persistent side drawer once
the window is expanded. The same destinations move between these presentations
as the window grows.

## Panes and canonical layouts

Canonical layouts — list-detail, supporting pane, and feed — are built from
panes arranged within the window. A list-detail split, for instance, is a
two-pane region: a list on one side and its detail on the other.

## Spacing

Regions are separated using a shared spacing scale so gaps and margins stay
consistent across a screen rather than being set ad hoc.

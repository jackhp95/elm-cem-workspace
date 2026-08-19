---
type: concept
title: Adaptive layouts
description: A single layout reflows across size classes; canonical patterns give the reflow a known shape.
resource: https://m3.material.io/foundations/layout/layout-overview/adaptive-design
tags: [foundations, adaptive, responsive, breakpoints]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/layout/layout-overview/adaptive-design
    retrieved: 2026-07-11
    note: Adaptive design principles across size classes.
  - url: https://m3.material.io/foundations/layout/canonical-examples/overview
    retrieved: 2026-07-11
    note: Canonical layout shapes the reflow targets.
---

An adaptive layout is one design that reflows across size classes rather than
several fixed designs. The goal is that a UI stays usable and recognizable as
the window grows or shrinks, without a separate hand-built layout per device.

## Reflow, not rebuild

As width crosses a size-class boundary, regions move and navigation changes
presentation, but the content and its relationships stay the same. A list-detail
view that stacks at compact widths becomes a two-pane split when there is room.

## Canonical shapes as targets

The canonical layouts give the reflow known endpoints: a compact arrangement and
an expanded one that the design animates or snaps between. Designing to those
shapes keeps the adaptive behavior predictable instead of improvised at each
breakpoint.

---
type: pattern
title: Feed
description: A canonical layout arranging content cards in a grid that reflows from one column to many.
resource: https://m3.material.io/foundations/adaptive-design/canonical-layouts
tags: [pattern, feed, grid, cards, adaptive, canonical-layout]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/adaptive-design/canonical-layouts
    retrieved: 2026-07-11
    note: Feed arranges content in a reflowing grid.
---

A feed arranges a large amount of similar content — cards, tiles, media — in a grid the
user scrolls through for a quick overview. It is one of Material's canonical adaptive
layouts and suits home surfaces, galleries, dashboards, and content streams.

## Shape

Uniform content units (typically [cards](/implementations/m3e-web/components/card)) laid
out in a grid. Each unit shows enough to let the user decide whether to open it; the
grid itself carries the sense of "there is a lot here, keep scrolling."

## Adaptive behavior

The grid is what makes a feed adaptive: the same feed becomes a single scrolling column
at compact width and a multi-column grid as width grows, filling the extra space with
more columns rather than stretching each card. Because units are interchangeable, the
reflow needs no special cases — the column count simply tracks the
[size class](/foundations/adaptive-layouts).

## Guidance

Keep units consistent in structure so the grid reads as one collection, and let their
height vary only as much as the content honestly requires. Load incrementally for long
feeds rather than all at once. If a feed item opens into a fuller view, that view is
often a [list-detail](/patterns/list-detail) or [supporting pane](/patterns/supporting-pane)
layout. Reserve expressive motion for entry and selection, not every scroll — see
[over-expressive motion in dense workflows](/anti-patterns/over-expressive-motion-in-dense-workflows).

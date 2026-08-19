---
type: pattern
title: Navigation
description: Choosing and adapting the top-level navigation surface — bar, rail, or drawer — across size classes.
resource: https://m3.material.io/foundations/layout/understanding-layout/overview
tags: [pattern, navigation, adaptive, nav-bar, nav-rail, drawer]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/components/navigation-bar/overview
    retrieved: 2026-07-11
    note: Navigation bar for top-level destinations on compact width.
  - url: https://m3.material.io/components/navigation-rail/overview
    retrieved: 2026-07-11
    note: Navigation rail for medium width.
  - url: https://m3.material.io/components/navigation-drawer/overview
    retrieved: 2026-07-11
    note: Navigation drawer for expanded width and larger destination sets.
---

Top-level navigation lets a user move between a small set of primary destinations. The
right *surface* for it depends on how wide the window is, so navigation is best treated
as one adaptive pattern rather than a fixed component choice.

## The three surfaces

- **Navigation bar** — a horizontal bar of destinations at the bottom edge, suited to
  **compact** width (phones). Best for roughly three to five top-level destinations.
- **Navigation rail** — a vertical strip of destinations along the leading edge, suited
  to **medium** width (small tablets, foldables), keeping destinations reachable without
  consuming a full column.
- **Navigation drawer** — a wider panel listing destinations with labels, suited to
  **expanded** width or when there are more destinations than a bar or rail holds
  comfortably. It can be permanent on wide screens or modal (over a scrim) on demand.

## Adaptive behavior

The pattern is to present the **same destinations** through whichever surface fits the
[size class](/foundations/adaptive-layouts): bar at compact, rail at medium, drawer at
expanded. Destinations, order, and selected state carry across the transition, so the
user's mental model of "where am I" survives a resize.

## Guidance

Keep the destination set small and stable — top-level navigation is for a few durable
sections, not for every screen in the app. Mark the current destination clearly with a
non-color cue as well as color (see
[color-only state signaling](/anti-patterns/color-only-state-signaling)). Do not stack a
navigation bar and a rail at once; pick the one surface the width calls for. Deeper
navigation within a section belongs to in-content patterns like
[list-detail](/patterns/list-detail), not to the top-level surface.

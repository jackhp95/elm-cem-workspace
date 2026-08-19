---
type: concept
title: Navigation bar
description: A bottom bar of top-level destinations for compact-width screens.
resource: https://m3.material.io/components/navigation-bar/overview
tags: [components, navigation-bar, navigation, compact, destinations]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/navigation-bar/overview
    retrieved: 2026-07-11
    note: Navigation bar anatomy.
  - url: https://m3.material.io/components/navigation-bar/guidelines
    retrieved: 2026-07-11
    note: Destination counts and compact-width usage.
---

A navigation bar is a horizontal bar of top-level destinations, anchored at the bottom edge,
suited to **compact** width (phones). It keeps a few primary sections one tap away.

## Anatomy

A row of destinations, each an icon with a short label; the current destination is marked
active. It holds roughly three to five destinations.

## Usage

Use a navigation bar for the top-level sections of an app on compact screens. Keep the
destination set small and stable. As width grows, the same destinations move to a
[navigation rail](/components/navigation-rail) (medium) or drawer (expanded) — see
[navigation](/patterns/navigation). Do not put per-screen actions here; those belong to an
[app bar](/components/app-bar) or [FAB](/components/fab).

## Do / Don't

**Do**

- Use a navigation bar for the top-level sections of an app on compact (phone)
  width, and keep it to roughly three to five destinations.
- Give every destination a short label alongside its icon, and mark the current
  destination active with more than color.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).
- Keep the destination set and its order stable, and mirror it in the
  [rail](/components/navigation-rail) and drawer as width grows.
  See [navigation](/patterns/navigation).

**Don't**

- Don't put per-screen or contextual actions in the navigation bar — those belong
  to an [app bar](/components/app-bar) or [FAB](/components/fab).
- Don't exceed about five destinations; overflow makes targets cramped and hides
  sections.
- Don't reorder or rename destinations between size classes — it breaks the user's
  spatial memory.
- Don't use icon-only destinations without labels where the icon is ambiguous.

## Accessibility

The bar is exposed as navigation, the current destination is announced and signaled beyond
color, and each destination is keyboard-reachable with an accessible name. See
[color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/nav-bar](/implementations/m3e-web/components/nav-bar).

---
type: concept
title: Breadcrumb
description: A trail showing the user's location within a hierarchy, with links back to ancestor levels.
resource: https://m3.material.io/foundations/layout/understanding-layout/overview
tags: [components, breadcrumb, navigation, hierarchy, wayfinding]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/foundations/layout/understanding-layout/overview
    retrieved: 2026-07-11
    note: Orienting the user within a structure.
---

A breadcrumb is a horizontal trail that shows where the user is within a hierarchy and lets
them jump back to any ancestor level. It aids wayfinding in deep structures — nested folders,
category trees, multi-level settings.

## Anatomy

A row of level labels from the root to the current location, separated by a delimiter; each
ancestor is a link, and the current level is shown but not linked.

## Usage

Use a breadcrumb when content is genuinely hierarchical and users move up and down levels.
It complements, and does not replace, top-level [navigation](/patterns/navigation). On narrow
screens, truncate or collapse middle levels rather than wrapping the trail. Do not use a
breadcrumb for a flat structure with no real hierarchy.

## Do / Don't

**Do**

- Use a breadcrumb when content is genuinely hierarchical and users move up and
  down levels — nested folders, category trees, multi-level settings.
- Show the full trail from the root to the current location, linking every
  ancestor and marking the current level as current.
- On narrow screens, truncate or collapse middle levels rather than wrapping the
  trail.
- Keep it as a complement to top-level [navigation](/patterns/navigation), not a
  replacement.

**Don't**

- Don't use a breadcrumb for a flat structure with no real hierarchy.
- Don't make the current (last) level a link — it goes nowhere.
- Don't let a long trail wrap onto multiple lines; collapse it instead.
- Don't rely on the breadcrumb as the only way to reach primary destinations.

## Accessibility

The trail is exposed as navigation, the current location is marked as current (not just
styled differently), and ancestor links are keyboard-reachable with clear names. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/breadcrumb](/implementations/m3e-web/components/breadcrumb).

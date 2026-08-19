---
type: concept
title: Elevation
description: Hierarchy and layering expressed with tonal surface color plus shadow across six levels.
resource: https://m3.material.io/styles/elevation/overview
tags: [styles, elevation, surface, shadow, layering]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/elevation/overview
    retrieved: 2026-07-11
    note: Elevation levels and tonal surfaces.
  - url: https://m3.material.io/styles/elevation/applying-elevation
    retrieved: 2026-07-11
    note: When to raise a surface.
---

Elevation expresses hierarchy and layering. A raised surface is drawn with tonal
color — a surface tint that grows with height — together with a shadow, so a
floating element reads as being above its neighbors.

## The six levels

Elevation runs across six levels, each a height mapped to a tonal-surface and
shadow pairing. Higher levels sit closer to the user; a surface is raised only to
signal that it floats above what surrounds it.

| Level | Typical surface |
| --- | --- |
| 0 | background and flat surfaces at rest |
| 1 | cards and resting floating actions |
| 2 | resting search surfaces |
| 3 | menus, dialogs, resting drawers |
| 4-5 | transient or pressed peaks |

## Choosing elevation

Elevation is chosen by picking the right surface or variant rather than by
setting a raw shadow. A hand-written shadow misses the tonal tint and drifts from
the level scale.

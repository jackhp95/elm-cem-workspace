---
type: anti-pattern
title: Color-only state signaling
description: Communicating state, selection, or validity through color alone, with no second cue.
resource: https://m3.material.io/foundations/designing/color-contrast
tags: [anti-pattern, color, accessibility, state, contrast]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/designing/color-contrast
    retrieved: 2026-07-11
    note: Do not rely on color alone to convey information; pair it with another cue.
---

## The mistake

State is carried by color and nothing else: a required field turns red when invalid, a
selected chip just changes hue, a status dot is the only difference between "online" and
"offline," a link is distinguished from body text purely by color. Remove the color and
the meaning disappears.

## Why it hurts

Color is not perceivable by everyone. Users with color-vision deficiencies, low vision,
or a monochrome or high-glare display may not distinguish the hues at all — and a
red/green pairing is the single most common failure. Long-standing accessibility guidance
(reflected in Material's contrast guidance) is explicit that color must not be the *only*
means of conveying information. A color-only signal also fails silently: it looks fine to
the designer who can see it, so the gap ships unnoticed.

## The better alternative

Pair color with at least one non-color cue:

- **Selection / active state** — add a checkmark, a filled vs. outlined shape, a change
  in [shape](/expressive/shape-morphing), elevation, or a border, alongside the color
  change.
- **Validation** — pair the error color with an icon and a text message that names the
  problem, not just a red outline. See [text field](/components/text-field).
- **Status** — give each status a distinct icon or label, not only a colored dot.
- **Links and controls** — distinguish them by weight, underline, or shape as well as
  color.

The check: view the screen in grayscale. If any state becomes ambiguous, it was relying
on color alone. See [accessibility](/foundations/accessibility) and
[color](/styles/color).

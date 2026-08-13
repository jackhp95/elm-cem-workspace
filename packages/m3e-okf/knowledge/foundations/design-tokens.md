---
type: concept
title: Design tokens
description: Named variables for visual decisions, flowing through reference, system, and component tiers.
resource: https://m3.material.io/foundations/design-tokens/overview
tags: [foundations, tokens, theming, design-tokens]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/design-tokens/overview
    retrieved: 2026-07-11
    note: The token system and its tiers.
  - url: https://m3.material.io/foundations/design-tokens/how-to-use-tokens
    retrieved: 2026-07-11
    note: Which tier to theme against.
  - url: https://m3.material.io/styles/color/system/overview
    retrieved: 2026-07-11
    note: Dynamic color generates system-tier color tokens from a source color.
---

A design token is a named variable for a visual decision — a color, a type
style, a corner radius, a duration. Naming the value once and referencing it
everywhere keeps a design consistent and makes a theme change a single edit.

## The token chain

Tokens flow through three tiers:

- **Reference** — the raw primitives (a palette, a type scale).
- **System** — role-based, semantic names built from the reference tier. This is
  the tier a UI themes against.
- **Component** — per-element values wired to system tokens, for fine-tuning one
  element without moving the whole system.

## Theming against the system tier

The system tier is the stable, role-named contract, so theming targets it rather
than reaching into reference primitives or overriding component tokens globally.
A one-off adjustment sets a component token in scope instead of changing a system
token everywhere.

## Scoped overrides

Because tokens cascade, an override applies to whatever scope you set it in. Set a
system token at the root and it re-themes the whole UI; set it on a subtree and only
that subtree changes; set a component token on a single element and only that element
moves. Prefer the **narrowest scope that achieves the goal** — reach for a global
system-token change to shift the whole theme, and a scoped or component-token override
for a local exception. Overriding component tokens globally to force a one-off is the
thing to avoid: it detaches that element from the system it should track.

## Multi-brand theming

The tiered chain is what makes multi-brand practical. Two brands can share the same
**component** structure and the same **system** role names while swapping the
**reference** primitives and the source values that feed them — a different palette,
type, and shape rounding produce a different-looking product from the same components.
Brand-specific values live at the reference/system boundary; the components below never
need to know which brand they are rendering.

## Dynamic color as generated tokens

[Dynamic color](/styles/color) fits this model cleanly: rather than hand-authoring
values, it **generates** the system-tier color tokens at runtime from a single source
color (often the user's wallpaper). The generated tones map onto the standard color
roles, so components that theme against the system tier pick up a personalized,
still-accessible scheme without any per-component work.

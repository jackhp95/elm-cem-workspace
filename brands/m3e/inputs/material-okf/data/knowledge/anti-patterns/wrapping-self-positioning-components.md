---
type: anti-pattern
title: Wrapping self-positioning components
description: Adding manual positioning wrappers around components that already handle their own placement via attributes like `for`, `anchor`, or `position`.
tags: [anti-pattern, badge, positioning, layout, component-api]
timestamp: 2026-08-03T00:00:00Z
diataxis: explanation
sources:
  - url: https://matraic.github.io/m3e/#/components/badge.html
    retrieved: 2026-08-03
    note: Badge uses `for` attribute to attach itself to a target element.
---

## The mistake

Wrapping a component and its target in a `relative`/`absolute` positioning container to overlay one on the other — when the component already provides a declarative attachment mechanism (e.g. a `for` attribute referencing the target's `id`).

Common symptom: a `<span class="relative inline-flex">` wrapper with the badge `absolute`-positioned inside, fighting or duplicating what the component does internally.

## Why it hurts

- **Breaks the component's positioning logic.** The component's built-in `position` attribute (e.g. `above-after`, `below-before`) stops working because the manual wrapper overrides or conflicts with its layout.
- **Fragile.** Manual offsets break across sizes, densities, and responsive breakpoints that the component already handles.
- **Obscures intent.** Future readers see custom positioning CSS instead of a declarative attribute, making it harder to understand or change the layout.

## The better alternative

Use the component's own attachment API:

```html
<!-- ✅ Correct: badge attaches itself via `for` -->
<m3e-icon-button id="cart-btn">
  <m3e-icon name="shopping_bag"></m3e-icon>
</m3e-icon-button>
<m3e-badge for="cart-btn" position="above-after">3</m3e-badge>
```

```html
<!-- ❌ Wrong: manual positioning wrapper -->
<span class="relative inline-flex">
  <m3e-icon-button>
    <m3e-icon name="shopping_bag"></m3e-icon>
  </m3e-icon-button>
  <span class="pointer-events-none absolute right-0 top-0">
    <m3e-badge>3</m3e-badge>
  </span>
</span>
```

## Components with self-positioning

| Component | Attachment mechanism |
| --- | --- |
| `m3e-badge` | `for` attribute targeting the host element's `id` |
| `m3e-tooltip` | `for` attribute targeting the host element's `id` |
| `m3e-menu` | `anchor` attribute or slotted inside the trigger |

## When manual positioning IS appropriate

Only when composing elements that genuinely have no built-in attachment — e.g. a custom status dot on a third-party widget with no slot or `for`-style API.

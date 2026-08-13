---
type: anti-pattern
title: Re-abstracting design tokens
description: Wrapping already-semantic utility classes or design tokens in an additional abstraction layer that adds no invariant enforcement.
tags: [anti-pattern, tokens, tailwind, shape, surface, abstraction]
timestamp: 2026-08-03T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/design-tokens/overview
    retrieved: 2026-08-03
    note: Design tokens are the smallest unit of design decision — they ARE the abstraction.
---

## The mistake

Creating a wrapper type or module around utility classes that are already at the design-token level — e.g. wrapping `rounded-md-corner-large` in a `Shape.large` opaque type, or wrapping `bg-primary text-on-primary` in a `Surface` record.

## Why it hurts

- **No invariant gained.** If the classes already encode the design decision (token name = semantic intent), wrapping them in a type just adds indirection without preventing mistakes.
- **Obscures the actual output.** Developers can't see what CSS classes end up in the DOM without looking up the wrapper's internals.
- **Prevents composition.** Utility classes compose naturally in a single `class` string. Wrapping them in separate opaque types means you can't merge them without unwrapping.
- **Diverges from docs.** The m3e documentation shows classes directly; a wrapper makes examples non-transferable.

## The better alternative

Use the token classes directly. If you want to prevent typos or ensure pairing, use **named constants** (strings or documentation) rather than opaque types:

```elm
-- ✅ Direct, composable, readable
Seam.node "div"
    [ Seam.asAttribute (TA.class "bg-primary-container text-on-primary-container rounded-md-corner-large p-6") ]
    kids
```

```elm
-- ❌ Unnecessary indirection
Surface.view Surface.primaryContainer
    [ Shape.corner Shape.large, TA.class "p-6" ]
    kids
```

## When an abstraction IS warranted

An abstraction earns its keep when it **enforces a non-obvious invariant** — e.g. ensuring `bg-X` is always paired with `text-on-X`. But even then, a simple module of string constants (`primaryContainer = "bg-primary-container text-on-primary-container"`) achieves the same safety without opaque types or custom `view` functions.

## Related

- Corner-radius tokens (`rounded-md-corner-*`) are already semantic — they name the M3 scale position, not a pixel value.
- Surface role tokens (`bg-surface-container`, `text-on-surface`) are already paired by naming convention in the m3e Tailwind plugin.

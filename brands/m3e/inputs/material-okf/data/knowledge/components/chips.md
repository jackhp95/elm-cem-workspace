---
type: concept
title: Chips
description: Compact elements for input, filtering, selection, or triggering an action in context.
resource: https://m3.material.io/components/chips/overview
tags: [components, chips, filter, input, selection]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/chips/overview
    retrieved: 2026-07-11
    note: The four chip types (assist, filter, input, suggestion).
  - url: https://m3.material.io/components/chips/guidelines
    retrieved: 2026-07-11
    note: When to use each chip type.
---

Chips are compact elements that represent a small piece of information or an action in
context. Material defines several types: **assist** (a contextual action), **filter**
(a toggleable filter), **input** (a user-entered token, often removable), and **suggestion**
(a recommended option).

## Anatomy

A small rounded container with a label, optionally a leading icon or avatar and a trailing
remove affordance. Chips usually appear in a horizontal set.

## Usage

Match the type to the job: filter chips for narrowing a result set, input chips for tokens
the user has entered (like recipients or tags), assist chips for a contextual shortcut,
suggestion chips for offered options. Filter chips must show their selected state by more
than color. Do not use chips as primary navigation or as a substitute for
[buttons](/components/button) when a clear action hierarchy is needed.

## Do / Don't

**Do**

- Match the chip type to the job: filter chips to narrow results, input chips for
  tokens the user entered, assist chips for a contextual shortcut, suggestion
  chips for offered options.
- Keep chip labels short — a word or a short phrase — and make removable input
  chips clearly removable.
- Show filter and selection state with more than color (a checkmark or fill), so
  the selected chips are unmistakable.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).
- Let a chip set wrap or scroll gracefully when there are many options.

**Don't**

- Don't use chips as primary navigation or as a replacement for
  [buttons](/components/button) when the screen needs a clear action hierarchy.
- Don't mix chip types with conflicting behaviors in the same set (a filter chip
  next to an action chip) where it confuses what a tap does.
- Don't rely on color alone to mark a filter chip as selected.
- Don't overflow a row with so many chips that the important options are hidden.

## Accessibility

Each chip is a control with an accessible name; a removable chip's remove action is
separately reachable and named. Filter selection state is exposed to assistive technology
and signaled beyond color. Chips are keyboard-navigable as a group. See
[color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/chips](/implementations/m3e-web/components/chips).

---
type: concept
title: Switch
description: A toggle for turning a single setting on or off with immediate effect.
resource: https://m3.material.io/components/switch/overview
tags: [components, switch, toggle, setting, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/switch/overview
    retrieved: 2026-07-11
    note: Switch anatomy and states.
  - url: https://m3.material.io/components/switch/guidelines
    retrieved: 2026-07-11
    note: When to use a switch vs a checkbox.
---

A switch toggles a single setting **on or off**, and the change takes effect immediately
rather than waiting for a form submission. Its sliding track-and-handle form signals an
instant state change.

## Anatomy

A track with a handle that moves between the off and on positions; the on state also shifts
color, and the handle may carry a small icon to reinforce which state it is in.

## Usage

Use a switch for an immediate binary setting — enabling a feature, turning something on.
Use a [checkbox](/components/checkbox) instead when the choice is part of a form that is
submitted together, or when an indeterminate state is needed.

## Do / Don't

**Do**

- Use a switch for an immediate binary setting — enabling a feature, turning
  something on — where the change takes effect at once.
- Label the switch by the setting it controls, worded so "on" is unambiguous.
- Signal the on/off state by position (and often an icon), not color alone.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).

**Don't**

- Don't use a switch inside a form that's submitted together, or when an
  indeterminate state is needed — use a [checkbox](/components/checkbox).
- Don't attach a switch to an action that needs confirmation or has heavy
  consequences without a safeguard; switches imply instant, low-stakes change.
- Don't pair a switch with a separate "Apply"/"Save" button — that contradicts
  its immediate-effect meaning.
- Don't rely on color alone to convey the current state.

## Accessibility

The on/off state is exposed to assistive technology and is signaled by more than color —
position, and often an icon — so it is not [color-only](/anti-patterns/color-only-state-signaling).
The switch has an accessible name, meets the minimum target size, and is keyboard-operable.

For the technology-specific API, see
[/implementations/m3e-web/components/switch](/implementations/m3e-web/components/switch).

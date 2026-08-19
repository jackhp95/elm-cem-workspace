---
type: concept
title: Interaction states
description: Every interactive element expresses the same set of visual states through a state layer.
resource: https://m3.material.io/foundations/interaction/states/overview
tags: [foundations, interaction, states, state-layer, disabled, selected]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/interaction/states/overview
    retrieved: 2026-07-11
    note: The set of interaction states.
  - url: https://m3.material.io/foundations/interaction/states/state-layers
    retrieved: 2026-07-11
    note: State layers and their opacities.
---

Interactive elements share one state model. The same states — enabled, hover,
focus, pressed, dragged, and disabled — apply everywhere, so a control's
response to input is consistent across a UI.

## The state layer

Hover, focus, and pressed are drawn as a translucent overlay — a state layer —
tinted by the element's color role at a role-specific opacity. The overlay is a
built-in part of the state model, not something composed by hand per control.

## Disabled and disabled-but-focusable

A plain disabled control is inert and skipped by the keyboard. A separate mode
keeps a control focusable while unavailable, so assistive technology can reach
it and explain why it cannot be used — useful when the reason matters.

## Selected state

Toggleable elements add a distinct selected state on top of the base states, so
an on control reads differently from an off one beyond just the state layer.

## Reduced motion

State transitions respect a reduced-motion preference, simplifying or dropping
the animation while keeping the state change legible.

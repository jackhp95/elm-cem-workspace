---
type: concept
title: Button
description: A labeled control that performs an action, in emphasis variants from filled to text.
resource: https://m3.material.io/components/buttons/overview
tags: [components, button, action, emphasis]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/buttons/overview
    retrieved: 2026-07-11
    note: Button variants and emphasis.
  - url: https://m3.material.io/components/buttons/guidelines
    retrieved: 2026-07-11
    note: Button usage and hierarchy.
---

A button is a labeled control the user activates to perform an action. Buttons
come in an emphasis ladder — from a filled button for the most prominent action
down through tonal, elevated, and outlined to a low-emphasis text button — so a
screen can rank its actions visually.

## Anatomy

A button is a text label, optionally with a leading icon, inside a shaped
container. The container carries the color and elevation that set the button's
emphasis level.

## Usage

Reserve the highest-emphasis variant for the primary action in a context and
step down for secondary ones; more than one high-emphasis button in the same area
flattens the hierarchy. Labels are short and action-oriented — they say what
happens.

## Do / Don't

**Do**

- Reserve the filled (or highest-emphasis) variant for the single most important
  action in a view, and step down the ladder for secondary actions.
- Keep labels short and action-first — a verb or verb phrase that names what
  happens ("Save", "Add to cart", "Send").
- Pair a button with a matching state: disable it only when the action is genuinely
  unavailable, and explain why nearby when the reason isn't obvious.
- Group related actions together and order them consistently (the confirming
  action last, in end-aligned dialog and form footers).

**Don't**

- Don't place two high-emphasis buttons side by side — competing "loudest"
  buttons flatten the hierarchy and leave users unsure which to pick.
  See [too many emphasis levels](/anti-patterns/too-many-emphasis-levels).
- Don't use a button for navigation that just moves the user to another place —
  that's a link. Buttons perform actions; links go places.
- Don't write vague labels ("OK", "Submit", "Click here") when a specific verb
  would tell the user the outcome.
- Don't rely on color alone to signal a button's emphasis or disabled state;
  keep the distinction legible without color.

## Accessibility

The visible label is the button's accessible name, so it does not need a separate
one. A button stays focusable and is activated by keyboard as well as pointer,
and its target keeps the minimum interactive size even when the label is short.

For the technology-specific API (tags, attributes, slots, events), see the
implementation card at [/implementations/m3e-web/components/button](/implementations/m3e-web/components/button).

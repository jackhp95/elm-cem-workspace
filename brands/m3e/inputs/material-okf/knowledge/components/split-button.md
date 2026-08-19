---
type: concept
title: Split button
description: A button pairing a primary action with an attached menu of related choices.
resource: https://m3.material.io/components/split-button/overview
tags: [components, split-button, actions, menu, expressive]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/split-button/overview
    retrieved: 2026-07-11
    note: Split button as an M3 Expressive component.
  - url: https://m3.material.io/components/split-button/guidelines
    retrieved: 2026-07-11
    note: When a default action plus related choices fits.
---

A split button pairs a **primary action** with an attached affordance that opens a
[menu](/components/menu) of related choices. It offers a default action for one tap while
keeping variations one step away — one of the components Material 3 Expressive introduced.

## Anatomy

Two joined regions: a main button that performs the default action, and a smaller adjacent
trigger that opens a menu of alternative or related actions.

## Usage

Use a split button when there is a clear default action plus a few close variants — "Save" with
"Save as…", "Send" with scheduling options. Make the default the action users want most often.
When there is no obvious default, a plain [button](/components/button) opening a menu, or a
[button group](/components/button-group), may communicate the choices more clearly.

## Do / Don't

**Do**

- Use a split button when there's a clear default action plus a few close variants
  — "Save" with "Save as…", "Send" with scheduling options.
- Make the default the action users want most often, and label it clearly.
- Keep the attached menu to related alternatives of the same intent.

**Don't**

- Don't use a split button when there's no obvious default — a plain
  [button](/components/button) opening a [menu](/components/menu), or a
  [button group](/components/button-group), reads more clearly.
- Don't fill the attached menu with unrelated actions; it's for variants of the
  primary one.
- Don't make the menu trigger so small it's hard to hit next to the main button.
- Don't hide a destructive option as the default where a mis-tap would be costly.

## Accessibility

The primary action and the menu trigger are exposed as separate controls, each with its own
accessible name; the trigger reports its expanded state; both are keyboard-operable and the
menu follows standard menu focus behavior. See [menu](/components/menu).

For the technology-specific API, see
[/implementations/m3e-web/components/split-button](/implementations/m3e-web/components/split-button).

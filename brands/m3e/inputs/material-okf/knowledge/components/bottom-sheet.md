---
type: concept
title: Bottom sheet
description: A surface anchored to the bottom edge that presents supplementary content or actions.
resource: https://m3.material.io/components/bottom-sheets/overview
tags: [components, bottom-sheet, surface, modal, actions]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/bottom-sheets/overview
    retrieved: 2026-07-11
    note: Standard and modal bottom sheets.
  - url: https://m3.material.io/components/bottom-sheets/guidelines
    retrieved: 2026-07-11
    note: When to use a bottom sheet.
---

A bottom sheet is a surface anchored to the bottom edge that slides up to present
supplementary content or a set of actions. It comes in **standard** (coexisting with the
content) and **modal** (over a scrim, blocking the content) forms, and can often be dragged
between heights.

## Anatomy

A rounded surface rising from the bottom edge, usually with a drag handle, holding content or
a list of actions. A modal sheet adds a scrim.

## Usage

Use a bottom sheet for secondary content or a menu of actions that benefits from more room
than a [menu](/components/menu) — a share sheet, a set of options, a supporting panel. On
smaller screens it is a natural home for the supporting content of a
[supporting pane](/patterns/supporting-pane) layout. Use a modal sheet only when the choice
should block; otherwise prefer a standard sheet.

## Do / Don't

**Do**

- Use a bottom sheet for secondary content or a menu of actions that needs more
  room than a [menu](/components/menu) — a share sheet, a set of options, a
  supporting panel.
- Prefer a standard (non-blocking) sheet, and reserve the modal sheet for when the
  choice should block the content behind a scrim.
- Give a draggable sheet a clear handle, and let it settle at sensible heights.
- On smaller screens, use it as the home for a
  [supporting pane](/patterns/supporting-pane) layout's content.

**Don't**

- Don't use a modal bottom sheet for a decision that a
  [dialog](/components/dialog) handles more directly, or for a brief notice that
  belongs in a [snackbar](/components/snackbar).
- Don't put a screen's primary action only inside a sheet the user must first open.
- Don't leave a modal sheet without a scrim and a dismiss/escape affordance.
- Don't cram long, scrolling, multi-step content into a sheet — use a full view.

## Accessibility

A modal bottom sheet moves focus into itself, traps focus while open, closes on escape or a
dismiss action, and returns focus to the trigger. Its accessible name describes its purpose.
See [accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/bottom-sheet](/implementations/m3e-web/components/bottom-sheet).

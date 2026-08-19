---
type: concept
title: Date picker
description: A control for choosing a date or range, by calendar or by direct text entry.
resource: https://m3.material.io/components/date-pickers/overview
tags: [components, date-picker, calendar, input, form]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/date-pickers/overview
    retrieved: 2026-07-11
    note: Calendar and input date-picker modes.
  - url: https://m3.material.io/components/date-pickers/guidelines
    retrieved: 2026-07-11
    note: When to offer calendar vs text entry.
---

A date picker lets the user choose a date (or a range) either by browsing a
[calendar](/components/calendar) or by typing into a field. Offering both modes serves users
who want to scan a month and those who already know the exact date.

## Anatomy

A field showing the selected date, plus a calendar view for browsing months; a range picker
tracks a start and end. A docked variant sits inline; a modal variant opens over the content.

## Usage

Use a calendar mode when the date is relational — "the second Tuesday," "sometime next week" —
where seeing the month helps. Offer text entry when the user likely knows the exact date, and
accept flexible input formats. Constrain selectable dates (min/max, disabled days) to prevent
invalid choices up front. See [forms](/patterns/forms).

## Do / Don't

**Do**

- Offer a [calendar](/components/calendar) mode when the date is relational —
  "the second Tuesday," "sometime next week" — where seeing the month helps.
- Offer text entry when the user likely knows the exact date, and accept flexible
  input formats.
- Constrain selectable dates (min/max, disabled days) to prevent invalid choices
  up front.
- Use a docked variant inline and a modal variant when the picker should take over.

**Don't**

- Don't force calendar browsing for a birthdate or other known exact date — let
  users type.
- Don't reject a reasonable typed format the user could plausibly enter; parse
  generously.
- Don't allow selection of out-of-range dates and only complain afterward.
- Don't signal the selected or focused date with color alone.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).

## Accessibility

The field is labeled and its value exposed; the calendar is keyboard-navigable (arrow keys move
by day, with month/year controls); the selected and focused dates are announced and signaled
beyond color; a modal picker traps and restores focus. See
[color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/datepicker](/implementations/m3e-web/components/datepicker).

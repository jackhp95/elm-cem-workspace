---
type: concept
title: Calendar
description: A month-grid view for browsing and selecting dates.
resource: https://m3.material.io/components/date-pickers/overview
tags: [components, calendar, date, grid, selection]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/date-pickers/overview
    retrieved: 2026-07-11
    note: The calendar grid within date selection.
  - url: https://m3.material.io/components/date-pickers/guidelines
    retrieved: 2026-07-11
    note: When calendar selection helps versus text entry.
---

A calendar presents dates in a month grid for browsing and selection. It is the visual, scannable
side of date selection — the view a [date picker](/components/date-picker) shows when the user
wants to see the shape of a month rather than type a date.

## Anatomy

A grid of days for a month, with weekday headers and controls to move between months and years.
Today, the selected date, and any range endpoints are visually distinguished; unavailable dates
are shown as disabled.

## Usage

Use a calendar when choosing a date benefits from spatial context — day of week, proximity to
other dates, a range spanning days. For a known exact date, direct text entry via a date picker
is faster. Mark unavailable dates clearly and prevent selecting them.

## Do / Don't

**Do**

- Use a calendar when choosing a date benefits from spatial context — day of week,
  proximity to other dates, a range spanning days.
- Distinguish today, the selection, and range endpoints with more than color.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).
- Mark unavailable dates clearly and prevent selecting them.
- Provide month and year controls so users can move quickly across long spans.

**Don't**

- Don't force a calendar for a known exact date — direct text entry via a
  [date picker](/components/date-picker) is faster.
- Don't rely on color alone to mark today, the selection, or disabled dates.
- Don't let users pick a disabled date and then reject it after the fact.
- Don't hide the month/year navigation, stranding users far from the target date.

## Accessibility

The grid is keyboard-navigable (arrow keys by day, controls for month and year), today and the
selection are announced and signaled beyond color, and disabled dates are conveyed as
unavailable to assistive technology, not by color alone. See
[color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/calendar](/implementations/m3e-web/components/calendar).

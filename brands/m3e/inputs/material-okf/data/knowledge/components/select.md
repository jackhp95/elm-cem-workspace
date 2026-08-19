---
type: concept
title: Select
description: A control that reveals a list of options and lets the user choose one, saving space over inline options.
resource: https://m3.material.io/components/menus/overview
tags: [components, select, menu, dropdown, form]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/menus/overview
    retrieved: 2026-07-11
    note: Menus, including exposed-dropdown selection.
  - url: https://m3.material.io/components/menus/guidelines
    retrieved: 2026-07-11
    note: When to use a menu-based selection.
---

A select presents a single field that, when activated, reveals a list of options for the
user to choose from. It saves space compared with showing every option inline, at the cost
of hiding the options until opened.

## Anatomy

A field showing the current selection (or a placeholder) with an affordance indicating it
opens; activating it reveals an overlay list of [options](/implementations/m3e-web/components/option),
the chosen one reflecting back into the field.

## Usage

Use a select for one choice among many options where showing all of them inline would
crowd the layout. When the set is short and worth seeing at a glance, a
[radio group](/components/radio-group) or [segmented button](/components/segmented-button)
keeps the options visible. When the user needs to filter a long list by typing, an
autocomplete fits better.

## Do / Don't

**Do**

- Use a select for one choice among many options where showing them all inline
  would crowd the layout.
- Give the field a persistent label and a sensible default or placeholder.
- Order options predictably (alphabetical, by frequency, or by logical grouping)
  so the target option is easy to find.

**Don't**

- Don't hide a short, high-value option set behind a select — a
  [radio group](/components/radio-group) or
  [segmented button](/components/segmented-button) keeps a few options visible at
  a glance.
- Don't use a plain select when the user needs to filter a long list by typing —
  an autocomplete fits better.
- Don't pack the option list with so many entries, or such long labels, that
  scanning becomes work; group or filter instead.
- Don't leave the field without a label or rely on the first option as a de facto
  label.

## Accessibility

The field has a label, exposes its current value and its expanded/collapsed state, and is
fully keyboard-operable — open, move through options, choose, and dismiss. Focus returns to
the field on close. See [forms](/patterns/forms) and [menu](/components/menu).

For the technology-specific API, see
[/implementations/m3e-web/components/select](/implementations/m3e-web/components/select).

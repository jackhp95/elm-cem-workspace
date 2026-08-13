---
type: concept
title: Radio group
description: A set of mutually exclusive options where exactly one can be selected.
resource: https://m3.material.io/components/radio-button/overview
tags: [components, radio, selection, form, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/radio-button/overview
    retrieved: 2026-07-11
    note: Radio button states and grouping.
  - url: https://m3.material.io/components/radio-button/guidelines
    retrieved: 2026-07-11
    note: When to use radio buttons.
---

A radio group presents a set of **mutually exclusive** options: exactly one is selected at
a time, and choosing another clears the previous choice. Use it when the options are few
and worth showing all at once.

## Anatomy

A group of circular targets, each with a label; the selected one is filled. The controls
share a group so selecting one deselects the rest.

## Usage

Use a radio group for a single choice among a small set (roughly two to a handful) where
seeing every option matters. For many options, a [select](/components/select) saves space.
For independent on/off choices, use [checkboxes](/components/checkbox); for an immediate
setting toggle, a [switch](/components/switch).

## Do / Don't

**Do**

- Use a radio group for a single choice among a small set (roughly two to a
  handful) where seeing every option matters.
- Give the group a label and each option a clear, parallel label.
- Preselect a sensible default when one exists, so the group isn't left empty.
- Signal the selected option with more than color.

**Don't**

- Don't use a radio group when many options make the list long — a
  [select](/components/select) saves space.
- Don't use radios for independent on/off choices — those are
  [checkboxes](/components/checkbox); for an immediate setting toggle, a
  [switch](/components/switch).
- Don't offer a single radio button on its own; a lone choice is a checkbox.
- Don't scatter the options so the group reads as unrelated controls.

## Accessibility

The options are exposed as one group with a group label, so assistive technology announces
"option 2 of 4" and arrow keys move within the group. Each label is associated with its
control, and targets meet the minimum size. See [forms](/patterns/forms).

For the technology-specific API, see
[/implementations/m3e-web/components/radio-group](/implementations/m3e-web/components/radio-group).

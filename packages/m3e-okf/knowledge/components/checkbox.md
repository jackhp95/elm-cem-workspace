---
type: concept
title: Checkbox
description: A control for selecting any number of options independently, including an indeterminate state.
resource: https://m3.material.io/components/checkbox/overview
tags: [components, checkbox, selection, form, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/checkbox/overview
    retrieved: 2026-07-11
    note: Checkbox states including indeterminate.
  - url: https://m3.material.io/components/checkbox/guidelines
    retrieved: 2026-07-11
    note: When to use a checkbox vs other selection controls.
---

A checkbox selects options that are **independent** of one another — the user can check any
number of them, including none. It supports checked, unchecked, and an indeterminate state
used when a parent summarizes partially-selected children.

## Anatomy

A small square target that shows a checkmark when selected (or a dash when indeterminate),
with an associated label.

## Usage

Use checkboxes for multi-select or for a single independent on/off choice within a form.
Use a [radio group](/components/radio-group) instead when exactly one option must be chosen
from a set, and a [switch](/components/switch) for toggling a setting on or off immediately.

## Do / Don't

**Do**

- Use checkboxes when the user can select any number of independent options,
  including none.
- Give each checkbox a clear label, and toggle the box when the label is tapped.
- Use the indeterminate state for a parent that summarizes partially-selected
  children.
- Phrase labels positively so the checked state has an unambiguous meaning.

**Don't**

- Don't use a checkbox where exactly one option must be chosen from a set — that's
  a [radio group](/components/radio-group).
- Don't use a checkbox for a setting that should take effect immediately — a
  [switch](/components/switch) signals instant on/off.
- Don't write a negatively-worded label ("Don't send emails") that makes the
  checked state confusing.
- Don't rely on color alone to show the checked or indeterminate state.

## Accessibility

The label is programmatically associated with the box so tapping the label toggles it, and
the whole label plus box forms one target at the minimum size. The checked/indeterminate
state is exposed to assistive technology, and the control is keyboard-operable. See
[forms](/patterns/forms) and [accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/checkbox](/implementations/m3e-web/components/checkbox).

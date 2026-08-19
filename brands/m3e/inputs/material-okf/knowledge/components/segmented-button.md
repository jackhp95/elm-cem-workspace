---
type: concept
title: Segmented button
description: A compact row of connected buttons for choosing among a few related options, single- or multi-select.
resource: https://m3.material.io/components/segmented-buttons/overview
tags: [components, segmented-button, selection, toggle, filter]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/segmented-buttons/overview
    retrieved: 2026-07-11
    note: Single- and multi-select segmented buttons.
  - url: https://m3.material.io/components/segmented-buttons/guidelines
    retrieved: 2026-07-11
    note: When to use segmented buttons.
---

A segmented button is a compact, connected row of options for choosing among a few
closely-related choices — a view mode, a filter, a sort. It supports **single-select**
(exactly one active, like a toggle set) and **multi-select** (several active at once).

## Anatomy

Two to a handful of connected segments, each a label and/or icon; the active segment(s)
show a selected state distinct from the rest.

## Usage

Use a segmented button when the options are few, related, and worth showing all at once in
a small footprint — it keeps every choice visible, unlike a [select](/components/select).
For many options, or options that are not a tight set, prefer a select or
[radio group](/components/radio-group). Keep segment labels short.

## Do / Don't

**Do**

- Use a segmented button when the options are few, related, and worth showing all
  at once in a small footprint — a view mode, a filter, a sort.
- Keep segment labels short, and make the selected segment(s) clearly distinct.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).
- Choose single-select for a one-of set (like a toggle) and multi-select when
  several can be active.

**Don't**

- Don't use a segmented button for many options or a loose set — prefer a
  [select](/components/select) or [radio group](/components/radio-group).
- Don't use it to trigger actions; it holds a selection. For peer actions, use a
  [button group](/components/button-group).
- Don't cram more than a handful of segments in; the row gets cramped and labels
  truncate.
- Don't signal the selected segment with color alone.

## Accessibility

The row is exposed as a group; selection state is announced and signaled beyond color;
segments are keyboard-navigable. Single- vs multi-select semantics are conveyed to
assistive technology so the user knows whether choosing one clears the others. See
[color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/segmented-button](/implementations/m3e-web/components/segmented-button).

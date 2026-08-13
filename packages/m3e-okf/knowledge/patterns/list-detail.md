---
type: pattern
title: List-detail
description: A canonical layout pairing a scannable list with the selected item's detail, reflowing from stacked to two-pane.
resource: https://m3.material.io/foundations/adaptive-design/canonical-layouts
tags: [pattern, list-detail, adaptive, navigation, canonical-layout]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/adaptive-design/canonical-layouts
    retrieved: 2026-07-11
    note: List-detail is one of the three canonical adaptive layouts.
---

List-detail pairs a **list** of explorable items with a **detail** view of whichever
item is selected. It is one of Material's canonical adaptive layouts and fits any
content where a user browses a collection and drills into one entry — mail, messages,
files, contacts, settings.

## Shape

- **List pane** — a scannable column of items, each showing enough to choose from.
- **Detail pane** — the full content of the selected item.

## Adaptive behavior

The layout reflows across [size classes](/foundations/adaptive-layouts):

- **Expanded width** — list and detail sit side by side as two panes; selecting an item
  updates the detail in place, with the list still visible.
- **Compact and medium width** — there is only room for one pane, so the view shows the
  list, then swaps to the detail on selection, with a back affordance returning to the
  list.

Because it is one design reflowing rather than two screens, the content and its
relationships stay constant; only the presentation changes.

## Guidance

Keep list items lightweight and consistent so the column stays scannable. Preserve
selection state across the reflow — an item chosen in two-pane mode stays chosen if the
window shrinks. On expanded widths, show a sensible default (the first item, or an empty
state) rather than a blank detail pane. Related patterns:
[supporting pane](/patterns/supporting-pane) and [feed](/patterns/feed).

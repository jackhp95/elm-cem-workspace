---
type: concept
title: Divider
description: A thin line that separates content into groups without adding a heavier container.
resource: https://m3.material.io/components/divider/overview
tags: [components, divider, separator, grouping, layout]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/divider/overview
    retrieved: 2026-07-11
    note: Full-width and inset dividers.
  - url: https://m3.material.io/components/divider/guidelines
    retrieved: 2026-07-11
    note: When a divider helps vs adds noise.
---

A divider is a thin line that separates content into groups. It is the lightest way to
signal a boundary, adding structure without the weight of a container or the emphasis of
whitespace alone.

## Anatomy

A single thin line, either full-width or inset to align with adjacent content. It is
decoration, not a control.

## Usage

Use a divider to separate groups within a [list](/components/list) or sections of content
where whitespace alone is not enough. Do not divide every item — a divider between each row
adds noise and defeats grouping. Prefer spacing for light separation and reserve dividers for
meaningful group boundaries.

## Do / Don't

**Do**

- Use a divider to separate meaningful groups within a [list](/components/list) or
  sections of content where whitespace alone isn't enough.
- Prefer an inset divider when it should align with adjacent content, and a
  full-width one for a top-level boundary.
- Reach for spacing first for light separation, and reserve dividers for real
  group boundaries.

**Don't**

- Don't divide every item in a list — a line between each row adds noise and
  defeats the grouping it's meant to show.
- Don't use a divider where a heading or grouped markup would convey the structure
  more clearly.
- Don't stack dividers with heavy containers so the boundary is signaled twice.
- Don't rely on a divider alone to convey a semantic group change to assistive
  technology.

## Accessibility

A divider is usually purely visual and not announced. When it marks a genuine semantic
boundary (a group change), that grouping is conveyed through structure — headings or grouped
markup — not by the line alone. See [accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/divider](/implementations/m3e-web/components/divider).

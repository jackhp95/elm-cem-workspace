---
type: concept
title: List
description: A vertical arrangement of related items in a consistent row format.
resource: https://m3.material.io/components/lists/overview
tags: [components, list, rows, content, navigation]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/lists/overview
    retrieved: 2026-07-11
    note: List item anatomy and line counts.
  - url: https://m3.material.io/components/lists/guidelines
    retrieved: 2026-07-11
    note: When to use a list.
---

A list arranges related items vertically in a consistent row format, so a collection is
scannable top to bottom. Rows can be one, two, or three lines and may carry leading and
trailing elements.

## Anatomy

A stack of rows; each row has a primary line and optional supporting lines, with optional
leading (icon, avatar, image) and trailing (metadata, control) elements. Rows share a
format so the column reads as one set.

## Usage

Use a list for a homogeneous collection where items share a structure — messages, settings,
files. Keep the row format consistent across items. When each item drills into a detail
view, the list is the browse side of a [list-detail](/patterns/list-detail) layout. For a
grid of richer cards, use a [feed](/patterns/feed) instead.

## Do / Don't

**Do**

- Use a list for a homogeneous collection whose items share a structure —
  messages, settings, files.
- Keep the row format consistent across items (same line count, same leading and
  trailing slots) so the column reads as one set.
- Use leading and trailing elements purposefully: an avatar or icon to identify,
  a control or metadata to act or inform.
- When each row drills into detail, treat the list as the browse side of a
  [list-detail](/patterns/list-detail) layout.

**Don't**

- Don't vary row height and structure item to item; inconsistent rows are hard to
  scan.
- Don't overload a row with competing controls that obscure the item's primary
  target.
- Don't use a list for a grid of rich, media-heavy cards — reach for a
  [feed](/patterns/feed) instead.
- Don't rely on a decorative leading icon to carry meaning without a text label.

## Accessibility

The list is exposed as a list with a known item count, rows are keyboard-navigable, and any
interactive element within a row is separately reachable and named. Leading icons that carry
meaning are labeled; purely decorative ones are not announced. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/list](/implementations/m3e-web/components/list).

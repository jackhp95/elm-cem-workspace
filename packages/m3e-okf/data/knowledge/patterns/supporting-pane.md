---
type: pattern
title: Supporting pane
description: A canonical layout with a primary content area and a secondary pane holding supporting content.
resource: https://m3.material.io/foundations/adaptive-design/canonical-layouts
tags: [pattern, supporting-pane, adaptive, canonical-layout]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/adaptive-design/canonical-layouts
    retrieved: 2026-07-11
    note: Supporting pane splits primary content from supporting content.
---

The supporting pane layout splits a window into a **primary** area holding the main
content and a **secondary** pane holding content that supports it — tools, metadata,
related items, a chat or comments sidebar. It is one of Material's canonical adaptive
layouts. The primary area takes the majority of the window (commonly about two thirds),
and the supporting pane takes the remainder.

## When it fits

Use it when the main task has a persistent companion that the user references or acts on
without leaving the primary content: a document with an outline or properties panel, a
video with a queue, an editor with a details inspector.

## Adaptive behavior

- **Expanded width** — primary and supporting content sit side by side; the supporting
  pane is always visible.
- **Compact and medium width** — there is not room for both at full size, so the
  supporting content moves into a bottom sheet, an expandable section, or a separate
  view reached from the primary content, keeping the primary task front and center.

## Guidance vs. list-detail

Supporting pane differs from [list-detail](/patterns/list-detail) in intent: in
list-detail the two panes are *the same content at two granularities* (a collection and
one item), so selecting in one drives the other. In supporting pane the secondary content
*augments* a single primary view and does not replace it. Reach for supporting pane when
the sidebar assists the main content, and list-detail when the two panes are a browse-then-drill relationship. See [adaptive layouts](/foundations/adaptive-layouts).

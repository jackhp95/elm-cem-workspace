---
type: concept
title: Badge
description: A small overlay marker that signals a count or a state on another element.
resource: https://m3.material.io/components/badges/overview
tags: [components, badge, notification, count, status]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/badges/overview
    retrieved: 2026-07-11
    note: Badge types (small dot and numbered).
  - url: https://m3.material.io/components/badges/guidelines
    retrieved: 2026-07-11
    note: When to use a badge.
---

A badge is a small marker overlaid on another element — an icon, an avatar, a navigation
destination — to signal a count of items or the presence of new activity.

## Anatomy

Either a small dot (presence only) or a compact numbered pill (a count), positioned at the
corner of its host element. It is decoration on top of the host, not a control itself.

## Usage

Use a badge to draw attention to unseen or pending items, such as unread messages on a
navigation icon. Keep numbers short, capping large counts (for example, "99+"). Do not
overload a UI with badges, or they stop signaling importance.

## Do / Don't

**Do**

- Use a badge to draw attention to unseen or pending items — unread messages on a
  navigation icon, new activity on an avatar.
- Keep numbers short and cap large counts (for example, "99+").
- Choose a bare dot when only presence matters, and a numbered pill when the count
  is meaningful.
- Make the badge's meaning available in text, not just as a colored dot.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).

**Don't**

- Don't overload the UI with badges; when everything is badged, nothing signals
  importance.
- Don't put long numbers or text in a badge — it's a marker, not a label.
- Don't use a badge as a control; it decorates a host and isn't tappable on its
  own.
- Don't rely on the dot alone to convey a state assistive technology can't read.

## Accessibility

A badge's meaning is exposed to assistive technology, not left as a purely visual dot — the
count or "new items" state is part of the host's accessible description. Because a bare dot
relies on color and position, ensure the underlying information is available in text too.
See [color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/badge](/implementations/m3e-web/components/badge).

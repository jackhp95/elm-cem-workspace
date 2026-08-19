---
type: concept
title: Floating action button
description: A prominent, elevated control representing the single primary action of a screen.
resource: https://m3.material.io/components/floating-action-button/overview
tags: [components, fab, action, primary, emphasis]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/floating-action-button/overview
    retrieved: 2026-07-11
    note: FAB anatomy and sizes.
  - url: https://m3.material.io/components/floating-action-button/guidelines
    retrieved: 2026-07-11
    note: The FAB represents a screen's primary action.
---

A floating action button (FAB) is a prominent, elevated control that floats above the
content to represent the **single most important action** of a screen — compose, create,
add. Its elevation, color, and persistent position make it the loudest control the system
offers.

## Anatomy

A shaped, filled container floating over the content, carrying an icon (and optionally an
extended label). It sits above the surface on its own elevation and holds a fixed position
as content scrolls beneath it.

## Usage

Use exactly one FAB per screen, for the one action you most want the user to take. Do not
spend it on secondary actions or stack several FABs — that flattens the hierarchy. If a
screen has no dominant action it may need no FAB; if it has a few related creation actions,
a FAB menu that expands from one button fits better. See
[FAB for non-primary actions](/anti-patterns/fab-for-non-primary-actions).

## Do / Don't

**Do**

- Use one FAB per screen, for the single action you most want the user to take.
- Give the FAB a clear, universally recognized icon (and an accessible name) so
  its purpose reads at a glance.
- Choose the extended FAB with a text label when the icon alone would be
  ambiguous, or to reinforce an important primary action.
- Keep the FAB anchored in a consistent position and let content scroll beneath it.

**Don't**

- Don't spend the FAB on a secondary or destructive action — it's reserved for
  the screen's primary, constructive one.
  See [FAB for non-primary actions](/anti-patterns/fab-for-non-primary-actions).
- Don't stack or place several FABs in the same view; if a screen has a few
  related creation actions, use a FAB menu that expands from one button instead.
- Don't add a FAB when a screen has no single dominant action — an unneeded FAB
  just adds visual weight.
- Don't let the FAB cover content or controls the user needs; keep clear space
  around it.

## Accessibility

The FAB carries an accessible name describing its action, since it is usually icon-only;
it is keyboard-focusable and activatable, and keeps the minimum interactive target size.

For the technology-specific API, see
[/implementations/m3e-web/components/fab](/implementations/m3e-web/components/fab).

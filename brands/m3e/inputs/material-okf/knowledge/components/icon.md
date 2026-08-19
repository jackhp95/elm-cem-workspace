---
type: concept
title: Icon
description: A small symbolic graphic that represents an action, object, or concept.
resource: https://m3.material.io/styles/icons/overview
tags: [components, icon, symbol, iconography, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/styles/icons/overview
    retrieved: 2026-07-11
    note: Iconography system and styles.
  - url: https://m3.material.io/styles/icons/applying-icons
    retrieved: 2026-07-11
    note: Applying icons consistently.
---

An icon is a small symbolic graphic standing in for an action, object, or concept. Icons make a
UI faster to scan when their meaning is clear, and they carry visual weight in dense controls
like [icon buttons](/components/icon-button) and [lists](/components/list).

## Anatomy

A single glyph from a consistent icon set, sized and weighted to sit on the type and layout grid.
Material's icons come in styles (such as outlined and filled) and support optical sizing so they
read well small or large.

## Usage

Use icons whose meaning is widely understood, and use them consistently — the same icon for the
same meaning throughout. Pair an icon with a label when its meaning is not obvious; an icon alone
is only as clear as its recognizability. Keep to one icon style within a context. See
[icons](/styles/icons) for the style system.

## Do / Don't

**Do**

- Use icons whose meaning is widely understood, and use them consistently — the
  same icon for the same meaning throughout.
- Pair an icon with a label when its meaning isn't obvious on its own.
- Keep to one icon style (outlined, filled) within a context.
- Give a standalone, meaningful icon an accessible name.

**Don't**

- Don't invent or repurpose an icon to mean something users won't recognize.
- Don't mix icon styles within the same context — it looks inconsistent.
- Don't use an icon alone where its meaning is ambiguous; add a label.
- Don't let an icon be the only carrier of state that must also be perceivable
  without color.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).

## Accessibility

A meaningful icon that stands alone (as in an icon button) needs an accessible name; a decorative
icon beside already-labeled text is hidden from assistive technology so it is not announced twice.
Icons are never the sole carrier of state that also needs to be perceivable without color. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/icon](/implementations/m3e-web/components/icon).

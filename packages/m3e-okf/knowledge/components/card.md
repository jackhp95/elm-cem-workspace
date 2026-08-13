---
type: concept
title: Card
description: A contained surface grouping related content and actions about a single subject.
resource: https://m3.material.io/components/cards/overview
tags: [components, card, container, surface, content]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/cards/overview
    retrieved: 2026-07-11
    note: Card variants (elevated, filled, outlined).
  - url: https://m3.material.io/components/cards/guidelines
    retrieved: 2026-07-11
    note: When to use a card.
---

A card is a contained surface that groups content and actions about a single subject —
an item in a feed, a summary, a piece of media. It comes in elevated, filled, and outlined
variants that differ in how they separate from the background.

## Anatomy

A shaped container holding content (text, media, controls) as a unit. It may be static or,
when the whole card represents one target, interactive.

## Usage

Use a card to package related content into a scannable unit, especially in a
[feed](/patterns/feed). Keep one subject per card. If the entire card is clickable, make
that obvious and avoid burying separate interactive controls inside a clickable card in a
way that confuses which target is being activated.

## Do / Don't

**Do**

- Use a card to package related content and actions about one subject into a
  scannable unit, especially in a [feed](/patterns/feed).
- Keep one subject per card, and choose the variant (elevated, filled, outlined)
  by how much separation from the background the context needs.
- If the whole card is a target, make that obvious and give it a single clear
  action.
- Keep the markup's content order matching the visual reading order.

**Don't**

- Don't nest separate interactive controls inside a fully clickable card in a way
  that makes it unclear which target a tap hits.
- Don't cram multiple unrelated subjects into one card — split them.
- Don't use a card merely to draw a box around content that isn't a distinct
  unit; plain layout may serve better.
- Don't mix card variants arbitrarily within one set where consistency aids
  scanning.

## Accessibility

If the whole card is a single target, it is one focusable control with an accessible name;
if it contains distinct controls, each is independently reachable and the card itself is not
also a competing target. Content order in the markup follows the visual reading order. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/card](/implementations/m3e-web/components/card).

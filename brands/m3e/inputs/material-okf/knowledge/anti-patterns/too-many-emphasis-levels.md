---
type: anti-pattern
title: Too many emphasis levels
description: Emphasizing so many elements that nothing reads as more important than anything else.
resource: https://m3.material.io/styles/typography/overview
tags: [anti-pattern, emphasis, hierarchy, typography, buttons]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/components/buttons/guidelines
    retrieved: 2026-07-11
    note: One high-emphasis action per context so hierarchy reads.
---

## The mistake

Emphasis is handed out freely: several high-emphasis buttons in one view, emphasized
type on half the lines on screen, bold color roles on every card. Each element was made
prominent to make it stand out — but they were all made prominent, so none of them do.

## Why it hurts

Hierarchy is relative. A control reads as important because the things around it are
**not** emphasized; emphasis is a contrast effect, and contrast needs a quiet
background. When a screen has three filled buttons, five emphasized headings, and a wall
of bold text, the user's eye finds no single entry point and has to read everything to
figure out where to start — which is exactly the work good hierarchy is supposed to save.
Material's own button guidance points the same way: keep one high-emphasis action per
context so the primary choice is unmistakable.

## The better alternative

Budget emphasis like a scarce resource:

- **One primary action per context.** Give it the highest-emphasis
  [button](/components/button) variant; step secondary actions down to tonal, outlined,
  or text. See [FAB for non-primary actions](/anti-patterns/fab-for-non-primary-actions)
  for the FAB corollary.
- **A few emphasized lines, not many.** Reserve
  [emphasized type](/expressive/emphasized-type) for the lines that genuinely lead — the
  heading that orients the screen, the one status that matters — and let the rest sit at
  baseline weight.
- **Let quiet do the work.** Most of a well-ranked screen is low-emphasis on purpose.
  When you add a new emphasized element, ask what you can de-emphasize to keep the
  balance. See [applying expressive](/expressive/applying-expressive).

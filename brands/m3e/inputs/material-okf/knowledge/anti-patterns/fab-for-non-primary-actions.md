---
type: anti-pattern
title: FAB for non-primary actions
description: Using the floating action button for anything other than a screen's single most important action.
resource: https://m3.material.io/components/floating-action-button/overview
tags: [anti-pattern, fab, hierarchy, actions]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/components/floating-action-button/guidelines
    retrieved: 2026-07-11
    note: The FAB represents the primary action of a screen.
---

## The mistake

A floating action button is dropped onto a screen for a secondary or incidental
action — a share, a filter, a settings shortcut — or several FABs are stacked so a
screen has more than one. The FAB is the loudest control the system offers, and here
it is spent on something that does not lead.

## Why it hurts

The FAB earns its prominence — elevation, color, a persistent floating position — by
representing the **one** most important action on a screen. Material guidance frames it
as the screen's primary action. When it points at a non-primary action, three things go
wrong: the real primary action loses its most emphatic home; users are drawn to the
wrong thing first; and if two FABs compete, neither reads as primary and the hierarchy
collapses. Expressive emphasis only works by contrast, and a mis-aimed FAB spends that
contrast on the wrong target.

## The better alternative

Reserve the FAB for the single primary action of the screen — the one thing you most
want the user to do, like compose or create. Give secondary actions lower-emphasis
homes: a [button](/components/button) in a lower-emphasis variant, an
[icon button](/implementations/m3e-web/components/icon-button) in a toolbar, or a menu.
If a screen has no single dominant action, it may not need a FAB at all. If it has
several related creation actions, consider a FAB menu that expands from one primary
button rather than multiple free-floating FABs.

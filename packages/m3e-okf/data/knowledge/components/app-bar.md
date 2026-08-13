---
type: concept
title: App bar
description: A bar at the top or bottom of a screen holding titling, navigation, and key actions.
resource: https://m3.material.io/components/top-app-bar/overview
tags: [components, app-bar, top-app-bar, actions, navigation]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/top-app-bar/overview
    retrieved: 2026-07-11
    note: Top app bar sizes and behavior.
  - url: https://m3.material.io/components/top-app-bar/guidelines
    retrieved: 2026-07-11
    note: What belongs in an app bar.
---

An app bar is a persistent bar, usually at the top of a screen, that provides titling and a
home for a small number of key actions and navigation affordances. Top app bars come in sizes
from a single row up to larger headers.

## Anatomy

A bar containing a leading element (a back or menu affordance), a title, and a few trailing
action [icon buttons](/components/icon-button) — with an overflow [menu](/components/menu) for
the rest. Larger variants give the title more prominence.

## Usage

Use an app bar to orient the user (where am I) and to surface the two or three most relevant
actions for the current screen; send the rest to an overflow menu. Do not crowd the bar with
every possible action. Top-level app destinations belong to
[navigation](/patterns/navigation) surfaces, not the app bar.

## Do / Don't

**Do**

- Use the app bar to orient the user (a clear title) and to surface the two or
  three most relevant actions for the current screen.
- Send the remaining actions to an overflow [menu](/components/menu) rather than
  crowding the bar.
- Give each action [icon button](/components/icon-button) an accessible name, and
  keep the leading affordance (back or menu) consistent.
- Pick a larger app-bar size when the title deserves more prominence.

**Don't**

- Don't pack the bar with every possible action; it becomes a cluttered strip of
  ambiguous icons.
- Don't put top-level app destinations in the app bar — those belong to
  [navigation](/patterns/navigation) surfaces.
- Don't change the title's meaning or the action set unpredictably between related
  screens.
- Don't use icon-only actions whose meaning isn't obvious without a label or
  tooltip.

## Accessibility

The title conveys the current context; action icon buttons carry accessible names; the bar
and its controls are keyboard-reachable in a sensible order. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/app-bar](/implementations/m3e-web/components/app-bar).

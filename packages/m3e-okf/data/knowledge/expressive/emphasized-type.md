---
type: concept
title: Emphasized type
description: An emphasized typography scale that pushes key lines forward in the hierarchy without resizing them.
resource: https://m3.material.io/styles/typography/overview
tags: [expressive, typography, emphasis, hierarchy, variable-fonts]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/typography/overview
    retrieved: 2026-07-11
    note: The type scale and roles.
  - url: https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/
    retrieved: 2026-07-11
    note: M3E adds emphasized type styles to reinforce hierarchy and highlight key actions.
---

Baseline Material's type scale ranks text by **size and weight** across display,
headline, title, body, and label roles. Material 3 Expressive keeps that scale and
adds **emphasized** variants of its styles — heavier, more expressive cuts that raise
a line's prominence without changing where it sits or how large it is.

## Emphasis as a separate axis

The value of an emphasized style is that emphasis becomes its own axis, independent of
size. A layout can make an unread count, a section heading, or a primary action stand
out by switching it to the emphasized variant of the style it already uses — rather
than bumping it up a size, which would disturb spacing and the reading order. The line
grows in weight and presence while staying in its slot.

## Where it comes from

The emphasized styles lean on **variable fonts**, which let a single typeface flex
along a weight axis smoothly. That is what makes an emphasized variant feel like the
same type family turned up, not a different font pasted in.

## Using it with intent

Emphasis works because it is scarce. When most of a screen is emphasized, nothing is —
the eye has no contrast to lock onto. Reserve emphasized styles for the few lines that
genuinely lead: the primary action, a critical status, the one heading that orients
the screen. See [too many emphasis levels](/anti-patterns/too-many-emphasis-levels) for
the failure mode, and baseline [typography](/styles/typography) for the scale this
extends.

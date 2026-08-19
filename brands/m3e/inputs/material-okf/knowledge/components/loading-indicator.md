---
type: concept
title: Loading indicator
description: A compact expressive indicator that signals a brief, ongoing wait.
resource: https://m3.material.io/components/loading-indicator/overview
tags: [components, loading-indicator, progress, wait, expressive]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/loading-indicator/overview
    retrieved: 2026-07-11
    note: Loading indicator as an M3 Expressive component for brief waits.
---

A loading indicator is a compact, often expressive animation that signals a brief, ongoing
wait — content arriving, an action processing. Material 3 Expressive brings it forward as a
distinct, more characterful way to communicate a short indeterminate wait.

## Anatomy

A small animating mark shown in place of, or alongside, the content that is loading. Unlike a
[progress indicator](/components/progress-indicator), it does not track a measurable fraction;
it simply says "working."

## Usage

Use a loading indicator for short, indeterminate waits where a percentage would be meaningless.
For measurable progress, use a determinate progress indicator; for content whose layout is
known in advance, a skeleton placeholder may communicate the wait with less motion. Remove the
indicator as soon as the content is ready.

## Do / Don't

**Do**

- Use a loading indicator for short, indeterminate waits where a percentage would
  be meaningless.
- Place it in or near the region that's loading so the wait's scope is clear.
- Remove it as soon as the content is ready.
- Honor a reduced-motion preference by simplifying the animation.
  See [motion physics](/expressive/motion-physics).

**Don't**

- Don't use a loading indicator for measurable work — use a determinate
  [progress indicator](/components/progress-indicator) instead.
- Don't show a spinner for a wait long enough that a skeleton placeholder or
  progress bar would set better expectations.
- Don't leave the indicator spinning after the content has arrived.
- Don't convey the busy state by animation alone with no accessible signal.

## Accessibility

The busy state is exposed to assistive technology, not conveyed by animation alone, and the
indicator honors a reduced-motion preference by simplifying its movement. See
[accessibility](/foundations/accessibility) and [motion physics](/expressive/motion-physics).

For the technology-specific API, see
[/implementations/m3e-web/components/loading-indicator](/implementations/m3e-web/components/loading-indicator).

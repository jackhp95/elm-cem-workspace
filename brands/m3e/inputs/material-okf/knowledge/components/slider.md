---
type: concept
title: Slider
description: A control for selecting a value or range along a continuous or stepped track.
resource: https://m3.material.io/components/sliders/overview
tags: [components, slider, range, input, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/sliders/overview
    retrieved: 2026-07-11
    note: Continuous, discrete, and range sliders.
  - url: https://m3.material.io/components/sliders/guidelines
    retrieved: 2026-07-11
    note: When a slider fits.
---

A slider selects a value from a range by dragging a handle along a track. It can be
**continuous** (any value in the range), **discrete** (snapping to steps), or a **range**
slider with two handles for a lower and upper bound.

## Anatomy

A track marking the range, one or two handles the user drags, and often a value label that
appears while dragging. Discrete sliders may show tick marks at each step.

## Usage

Use a slider when the value is spatial or approximate and immediate feedback helps —
volume, brightness, a price range. When a precise number matters more than a feel for
magnitude, a numeric [text field](/components/text-field) may serve better, or pair the two.

## Do / Don't

**Do**

- Use a slider when the value is spatial or approximate and immediate feedback
  helps — volume, brightness, a price range.
- Show the current value in text (a label while dragging, or a nearby readout) so
  it's not conveyed by handle position alone.
- Use a discrete slider with tick marks when the value should snap to steps, and a
  range slider when the user sets a lower and upper bound.

**Don't**

- Don't use a slider when a precise number matters more than a feel for magnitude
  — a numeric [text field](/components/text-field) serves better, or pair the two.
- Don't make the track cover so wide a range that fine adjustment is impractical.
- Don't hide the selected value; a slider with no readout is hard to set
  accurately.
- Don't shrink the handle below the minimum target size.

## Accessibility

The slider exposes its current value, minimum, and maximum to assistive technology and is
operable by keyboard (arrow keys step the value). The handle target meets the minimum size,
and the current value is perceivable in text, not only by handle position. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/slider](/implementations/m3e-web/components/slider).

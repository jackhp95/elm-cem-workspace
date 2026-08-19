---
type: concept
title: Icon button
description: A compact control that performs an action using only an icon, common in toolbars and dense contexts.
resource: https://m3.material.io/components/icon-buttons/overview
tags: [components, icon-button, action, toolbar, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/icon-buttons/overview
    retrieved: 2026-07-11
    note: Icon button variants and states.
  - url: https://m3.material.io/components/icon-buttons/guidelines
    retrieved: 2026-07-11
    note: When to use an icon button and its emphasis variants.
---

An icon button performs an action using only an icon, with no visible text label. Its
compactness suits toolbars, list rows, and other dense contexts where a full
[button](/components/button) would not fit, and it comes in emphasis variants (from filled
down to standard) like other buttons.

## Anatomy

A single icon inside an interactive target, optionally within a shaped container that
carries the emphasis color. The visible glyph is smaller than the target it sits in.

## Usage

Use an icon button when the action is well represented by a familiar icon and space is
tight. Prefer a labeled button when the icon's meaning is not obvious. A toggle icon
button that switches between two states must make the state clear by more than color.

## Do / Don't

**Do**

- Use an icon button when the action is well represented by a familiar icon and
  space is tight — toolbars, list rows, dense contexts.
- Give every icon button an explicit accessible name (and often a tooltip) since
  there's no visible label.
- Choose the emphasis variant (from filled down to standard) to match the action's
  importance.
- For a toggle icon button, make the on/off state clear by more than color.

**Don't**

- Don't use an icon button when the icon's meaning isn't obvious — prefer a
  labeled [button](/components/button).
- Don't ship an icon button with no accessible name; the glyph alone isn't
  announced.
- Don't shrink the target below the minimum interactive size, even though the
  glyph is small.
- Don't rely on color alone to convey a toggle icon button's state.

## Accessibility

Because there is no visible text, an icon button **must** carry an explicit accessible
name describing its action — the glyph itself is decorative and not announced. It keeps
the minimum interactive target even though the glyph is small, and any toggle state is
exposed to assistive technology. See [accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/icon-button](/implementations/m3e-web/components/icon-button).

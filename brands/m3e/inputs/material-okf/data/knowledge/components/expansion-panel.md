---
type: concept
title: Expansion panel
description: A titled section that expands to reveal its content and collapses to hide it.
resource: https://m3.material.io/components/lists/overview
tags: [components, expansion-panel, accordion, disclosure, content]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/foundations/content-design/overview
    retrieved: 2026-07-11
    note: Progressive disclosure keeps a surface scannable.
---

An expansion panel is a titled section that expands to show its content and collapses to hide
it, letting a surface stay scannable while keeping detail one interaction away. A stack of
them forms an accordion.

## Anatomy

A header showing a title and an expand/collapse affordance, with a content region that
appears when expanded. The header's state indicates whether the content is showing.

## Usage

Use expansion panels for progressive disclosure — FAQs, optional settings, secondary detail —
where showing everything at once would overwhelm. Keep headers descriptive so the user can
decide whether to expand. Do not hide essential, always-needed content behind a collapse.

## Do / Don't

**Do**

- Use expansion panels for progressive disclosure — FAQs, optional settings,
  secondary detail — where showing everything at once would overwhelm.
- Write descriptive headers so the user can decide whether to expand without
  guessing.
- Signal the expanded/collapsed state with more than color.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).
- Let users expand more than one panel when comparing sections helps.

**Don't**

- Don't hide essential, always-needed content behind a collapse.
- Don't nest accordions deeply so users lose track of what's open.
- Don't use vague headers ("More", "Details") that don't hint at the content.
- Don't collapse content that the user just acted on and still needs to see.

## Accessibility

The header exposes its expanded/collapsed state and controls the associated content region,
so assistive technology announces whether it is open; the state is signaled beyond color; the
header is keyboard-operable. See
[color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/expansion-panel](/implementations/m3e-web/components/expansion-panel).

---
type: concept
title: Typography
description: A tokenized type scale of named roles that encode size, weight, line height, and tracking.
resource: https://m3.material.io/styles/typography/overview
tags: [styles, typography, type-scale, roles]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/typography/overview
    retrieved: 2026-07-11
    note: The type system and its roles.
  - url: https://m3.material.io/styles/typography/type-scale-tokens
    retrieved: 2026-07-11
    note: The baseline type-scale roles.
---

Typography is expressed as a **type scale** of named roles rather than ad-hoc
font sizes. Each role — display, headline, title, body, and label, in large,
medium, and small — encodes a full style: size, weight, line height, and tracking.

## Roles, applied by context

A role is chosen by its place in the hierarchy, not by a pixel value. A label
role suits a button, a body role suits list text, a headline role suits a section
title. Using the role keeps the scale consistent across a screen.

## Encoded style

Because a role bundles size, weight, line height, and tracking together, applying
it sets all four at once. Overriding a single dimension breaks the role's tuned
proportions.

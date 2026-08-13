---
type: concept
title: Color
description: A role-based color system generated from a source color, cascading to every element.
resource: https://m3.material.io/styles/color/system/overview
tags: [styles, color, theming, dynamic-color, roles]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/styles/color/system/overview
    retrieved: 2026-07-11
    note: The role-based color system.
  - url: https://m3.material.io/styles/color/roles
    retrieved: 2026-07-11
    note: Color roles and their on-pairs.
---

Color is organized by **role** rather than by raw value. Roles like primary,
surface, and outline — each with a paired on-role for text or icons drawn over it
— let a scheme cascade to every element and stay accessible by construction.

## Static and dynamic color

A static scheme uses fixed, spec-aligned values. A dynamic scheme is generated at
runtime from a single source color, mapping perceptually tuned tones onto the
standard roles so a personalized theme still lands on accessible pairings.

## Role pairing

Pairing a container role with its on-role — on-primary text over a primary
surface — keeps contrast correct without hand-tuning. Reaching for a raw value
instead of a role loses that guarantee.

## High-contrast environments

A color system adapts to forced-colors and high-contrast settings, adjusting so
that legibility and semantic clarity survive the override.

---
type: concept
title: What changed in Material 3 Expressive
description: The three foundational shifts M3E makes over baseline Material 3 — motion, shape, and typography.
resource: https://m3.material.io/blog/building-with-m3-expressive
tags: [expressive, m3e, motion, shape, typography, overview]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://design.google/library/expressive-material-design-google-research
    retrieved: 2026-07-11
    note: The research program behind M3E and the three shifts it drove.
  - url: https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/
    retrieved: 2026-07-11
    note: Launch framing — smoother animations, more personal and intuitive interactions.
---

Material 3 Expressive (M3E) is an evolution of Material 3, not a replacement. It
keeps the same token system, color roles, and component set, then layers on a more
emotive, attention-guiding surface. Three foundational shifts define it.

## Motion becomes physics

Baseline Material animates with fixed **easing curves and durations**. M3E replaces
that model with **spring physics**: a transition is described by how a spring
behaves — its stiffness and damping — rather than by a curve and a millisecond count.
Springs carry momentum and settle naturally, so movement reads as alive rather than
scripted. See [motion physics](/expressive/motion-physics).

## Shape expands and morphs

M3E broadens the shape system with a much larger library of shapes and adds
**shape morphing** — controls that smoothly transform from one shape into another
as their state changes, such as a rounded square becoming a circle on press. Shape
moves from a static corner-radius choice to an animated dimension. See
[shape morphing](/expressive/shape-morphing).

## Typography gains emphasis

M3E adds **emphasized type styles** alongside the baseline type scale. These heavier,
more expressive variants let a layout push a key line — an unread count, a primary
label — forward in the hierarchy without changing its size or position. See
[emphasized type](/expressive/emphasized-type).

## Why these three

The shifts are not stylistic whims; they came out of a large research program that
measured how expressive design affects real usability. That evidence — including
eye-tracking findings on how much faster people locate key elements — is covered in
[research rationale](/expressive/research-rationale). For how to put the three shifts
to work without overdoing them, see [applying expressive](/expressive/applying-expressive).

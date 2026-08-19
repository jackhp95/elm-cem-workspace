---
type: concept
title: Stepper
description: A control that guides the user through an ordered sequence of steps, showing progress through them.
resource: https://m3.material.io/foundations/content-design/overview
tags: [components, stepper, sequence, progress, forms]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/foundations/content-design/overview
    retrieved: 2026-07-11
    note: Guiding a user through a task in clear steps.
---

A stepper guides the user through an **ordered** sequence of steps and shows where they are
in it — a checkout, a multi-part form, a setup wizard. Unlike [tabs](/components/tabs), which
switch between peer views, a stepper implies progression from one step to the next.

## Anatomy

A row or column of steps, each labeled and marked as completed, current, or upcoming, with
controls to move forward and back. Content for the current step shows alongside.

## Usage

Use a stepper when a task genuinely has an order and benefits from being broken into stages —
it reduces the sense of a long form and lets the user see progress. Keep the number of steps
small, allow moving back, and validate each step before advancing. For unordered sections,
use tabs instead. See [forms](/patterns/forms).

## Do / Don't

**Do**

- Use a stepper when a task genuinely has an order and benefits from being broken
  into stages — a checkout, a multi-part form, a setup wizard.
- Keep the number of steps small, and let the user move back to a previous step.
- Validate each step before advancing, and mark completed / current / upcoming
  states with more than color.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).

**Don't**

- Don't use a stepper for unordered, peer sections — those are
  [tabs](/components/tabs).
- Don't trap the user by disabling backward movement through completed steps.
- Don't split a short task into so many steps that it feels longer than a single
  form.
- Don't advance past a step with invalid input and surface the error only later.

## Accessibility

The current step and total are exposed to assistive technology; step state (completed /
current / upcoming) is signaled beyond color; forward and back controls are keyboard-operable
and clearly named. See [color-only state signaling](/anti-patterns/color-only-state-signaling).

For the technology-specific API, see
[/implementations/m3e-web/components/stepper](/implementations/m3e-web/components/stepper).

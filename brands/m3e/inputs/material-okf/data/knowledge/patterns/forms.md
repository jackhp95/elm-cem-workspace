---
type: pattern
title: Forms
description: Structuring input-heavy screens for clarity, validation, and error recovery.
resource: https://m3.material.io/components/text-fields/overview
tags: [pattern, forms, text-field, validation, accessibility]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/components/text-fields/guidelines
    retrieved: 2026-07-11
    note: Text-field labels, helper text, and error states.
  - url: https://m3.material.io/foundations/content-design/overview
    retrieved: 2026-07-11
    note: Clear, concise labels and messages.
---

A form collects structured input. The pattern is less about which controls to use than
about ordering, labeling, and error handling so the user always knows what is being
asked and what went wrong.

## Structure

Group related fields and order them the way the user thinks about the task, not the way
the database stores it. Keep one column on compact width; a form that sprawls into
multiple columns is easy to skip fields in. Use section headings for long forms so the
user can see the shape of what is ahead.

## Labels and help

Every field carries a persistent, visible label — a placeholder that vanishes on focus is
not a label. Reserve helper text for guidance the user needs *before* they type (format
hints, constraints). Keep labels and messages short and concrete; see
[content design](/foundations/content-design).

## Validation and errors

Validate at a helpful moment — usually when the user leaves a field or submits — not on
every keystroke. When a field is invalid, show the error **at the field**, pair the error
color with an icon and a message that says how to fix it, and never rely on color alone
(see [color-only state signaling](/anti-patterns/color-only-state-signaling)). On submit,
move focus to the first error so the user can act immediately. See
[text field](/components/text-field).

## Accessibility

Labels are programmatically associated with their fields, required fields are marked in
text and not color alone, and error messages are announced to assistive technology when
they appear. Interactive targets stay at or above the minimum size. See
[accessibility](/foundations/accessibility).

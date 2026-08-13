---
type: concept
title: Accessibility
description: Names, target sizes, focus, and contrast are construction concerns, not a finishing pass.
resource: https://m3.material.io/foundations/designing/overview
tags: [foundations, accessibility, a11y, focus, contrast]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/foundations/overview/assistive-technology
    retrieved: 2026-07-11
    note: Accessible names for controls without visible text.
  - url: https://m3.material.io/foundations/usability/overview
    retrieved: 2026-07-11
    note: Minimum touch-target sizing and focus visibility.
  - url: https://m3.material.io/foundations/designing/color-contrast
    retrieved: 2026-07-11
    note: Contrast minimums and role-paired color.
  - url: https://www.w3.org/TR/WCAG22/
    retrieved: 2026-07-11
    note: WCAG 2.2 success criteria the four construction concerns map to.
---

Accessibility is decided while a UI is built, not audited in afterward. Four
things the markup must carry regardless of the toolkit: an accessible **name**
on every control, a large-enough **target**, a visible **focus** indicator, and
**contrast** between text and its background.

## Accessible names

A control with no visible text — an icon-only button, for example — carries no
name for assistive technology unless one is supplied. Give such controls an
explicit label; the icon glyph itself is decorative and is not announced. A
control that already shows text does not need a separate label; its visible
text is its name.

## Touch targets

Interactive targets are kept at roughly a 48-by-48 minimum even when the visible
glyph is smaller, so a tap or click lands reliably. Shrinking a control below
that minimum with custom styling defeats the reserved hit area.

## Focus indicators

A visible focus indicator marks which control the keyboard is on and is never
removed. Keeping the indicator (and strengthening it in high-visibility
contexts) is what makes a UI keyboard-navigable.

## Color and contrast

Text and its background meet a contrast minimum. Pairing a container color role
with its matching on-role text — rather than a hand-picked value — keeps the
pairing contrast-correct by construction.

## How the four map to WCAG

The four construction concerns line up with specific WCAG 2.2 success criteria, which is
what makes them checkable rather than aspirational:

- **Accessible names** → *4.1.2 Name, Role, Value* — every control exposes a name and
  role to assistive technology; *2.5.3 Label in Name* keeps the accessible name
  consistent with any visible label.
- **Targets** → *2.5.8 Target Size (Minimum)* — interactive targets meet a minimum size
  so they are reliably operable.
- **Focus** → *2.4.7 Focus Visible* — the focused control is always visibly indicated;
  *2.4.11 Focus Not Obscured* keeps it from being hidden behind other content.
- **Contrast** → *1.4.3 Contrast (Minimum)* for text and *1.4.11 Non-text Contrast* for
  UI components and states; role-paired color satisfies these by construction.

Two cross-cutting criteria matter for expressive UI: *1.4.1 Use of Color* (never signal
state by color alone — see
[color-only state signaling](/anti-patterns/color-only-state-signaling)) and *2.3.3
Animation from Interactions*, which is why motion honors a reduced-motion preference — see
[motion physics](/expressive/motion-physics).

## Per-class emphasis

The same four concerns land differently by component class:

- **Actions** (buttons, FAB, icon buttons) — names on icon-only controls; keyboard
  activation; target size. See [button](/components/button).
- **Inputs** (text fields, selects, checkboxes, radios, switches) — programmatic
  label association; error state announced and not color-only; required-ness in text.
  See [text field](/components/text-field) and [forms](/patterns/forms).
- **Overlays** (dialogs, menus, sheets) — focus moves in and is trapped, returns on
  close, and escape dismisses. See [dialog](/components/dialog).
- **Navigation** (bar, rail, drawer, tabs) — current destination marked with a non-color
  cue; full keyboard traversal. See [navigation](/patterns/navigation).

## Checklist

- Every control without visible text has an explicit accessible name.
- Nothing removes the focus indicator.
- Interactive targets stay at or above the minimum size.
- Text is paired to the on-role of its container color.
- No state, selection, or validity is signaled by color alone.
- Motion honors the user's reduced-motion preference.

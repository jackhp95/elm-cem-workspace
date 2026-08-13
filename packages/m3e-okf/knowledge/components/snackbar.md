---
type: concept
title: Snackbar
description: A brief, non-blocking message shown at the edge of the screen, optionally with a single action.
resource: https://m3.material.io/components/snackbar/overview
tags: [components, snackbar, feedback, non-blocking, undo]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/snackbar/overview
    retrieved: 2026-07-11
    note: Snackbar anatomy and behavior.
  - url: https://m3.material.io/components/snackbar/guidelines
    retrieved: 2026-07-11
    note: When to use a snackbar and its single-action rule.
---

A snackbar delivers a brief, transient message about a process — "Message sent,"
"Photo deleted" — at the edge of the screen without blocking interaction. It appears,
lingers briefly, and dismisses itself.

## Anatomy

A short line of text in a low, single-line container near the bottom edge, optionally with
one text action (such as *Undo*). It does not carry an icon-heavy layout or multiple
actions.

## Usage

Use a snackbar for lightweight confirmation or notice that needs no decision. Keep the
message to one line and include at most one action. Do not use a snackbar for information
the user must act on before continuing — that is a [dialog](/components/dialog). Do not
stack snackbars; show one at a time. See
[dialog for non-blocking info](/anti-patterns/dialog-for-non-blocking-info).

## Do / Don't

**Do**

- Use a snackbar for a brief, low-priority confirmation or notice that needs no
  decision ("Message sent", "Photo deleted").
- Keep the message to one line, and include at most one action (commonly *Undo*).
- Let the action stay reachable long enough to be used before the snackbar
  auto-dismisses.
- Show one snackbar at a time, replacing rather than stacking.

**Don't**

- Don't use a snackbar for information the user must act on before continuing —
  that's a [dialog](/components/dialog).
  See [dialog for non-blocking info](/anti-patterns/dialog-for-non-blocking-info).
- Don't stack multiple snackbars or queue a burst of them.
- Don't put more than one action, or critical/destructive-only actions, in a
  snackbar that will disappear on its own.
- Don't rely on a snackbar for errors that need persistent, in-context attention.

## Accessibility

A snackbar is announced to assistive technology when it appears without stealing focus.
If it carries an action, that action stays reachable for long enough (and by keyboard) to
be used before the snackbar auto-dismisses.

For the technology-specific API, see
[/implementations/m3e-web/components/snackbar](/implementations/m3e-web/components/snackbar).

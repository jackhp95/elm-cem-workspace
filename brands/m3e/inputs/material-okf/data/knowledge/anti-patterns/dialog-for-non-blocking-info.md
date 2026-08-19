---
type: anti-pattern
title: Dialog for non-blocking info
description: Interrupting the user with a modal dialog to deliver information that does not require a decision.
resource: https://m3.material.io/components/dialogs/overview
tags: [anti-pattern, dialog, modal, snackbar, interruption]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/components/dialogs/guidelines
    retrieved: 2026-07-11
    note: Dialogs are for decisions or focused tasks that must interrupt.
  - url: https://m3.material.io/components/snackbar/overview
    retrieved: 2026-07-11
    note: Snackbars deliver brief, non-blocking messages.
---

## The mistake

A modal [dialog](/components/dialog) is used to announce something the user does not
need to act on — "Saved successfully," "Sync complete," a tip, a passive status. The
user's only real option is to dismiss the box they never asked for.

## Why it hurts

A dialog is a **blocking** surface: it drops a scrim over the page, traps focus, and
halts the task until the user acts. That cost is justified when the app genuinely needs
a decision or a short focused task before continuing. Spending it on information that
carries no decision makes the interruption pure friction — the user is stopped, made to
read, and made to click, all to acknowledge something that could have arrived quietly.
Train users that dialogs are dismissible noise and they will start dismissing the ones
that actually matter.

## The better alternative

Match the surface to whether the message blocks:

- **Transient confirmation** ("Saved," "Sent," "Copied") belongs in a
  [snackbar](/implementations/m3e-web/components/snackbar) — brief, self-dismissing,
  non-blocking, optionally with a single action like *Undo*.
- **Persistent but non-urgent status** belongs inline on the surface it concerns — a
  banner or a status line — not in a box over everything.
- **Only a real decision or a focused sub-task** ("Discard changes?", "Choose an
  account") justifies a modal dialog, because only then must the user act before
  continuing.

The test is simple: if the user has nothing to decide, do not block them to say so.

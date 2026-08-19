---
name: making-m3e-accessible
description: >-
  Makes elm-m3e Material 3 UIs accessible in Elm — accessible names, focus/keyboard
  expectations per component family, and reading the review rules as a11y guidance. Use
  in projects using elm-m3e when the user adds an icon-only control (icon button, FAB),
  asks "does this m3e component need an aria-label", how to name/label an m3e control,
  what keyboard behavior a dialog/menu/list gives you, why elm-review reports
  missingRequiredAttribute / RequireSlot, or wants to spot-check the accessibility tree.
  Covers the named-slot vs TypedHtml.Aria.label decision, what @m3e/web handles
  vs what the author must wire, interpreting the a11y-relevant Cem review errors, and the
  Playwright a11y spot-check recipe. For WCAG theory link the m3e knowledge base's
  accessibility page. For building components see building-m3e-uis; for a full design
  review see reviewing-m3e-designs.
---

# Making M3e UIs accessible

Accessibility in elm-m3e is largely **structural, not a checklist** (see the
`/guide/accessible-by-construction` route). The ARIA setters are first-class on every
component, and the codegen-aware review rules refuse a nameless control in CI. This skill
is the Elm-specific practice; for WCAG rationale (contrast ratios, focus-visible, name/
role/value) see the **m3e knowledge base's `foundations/accessibility` page**.

## Accessible name: named slot vs ARIA label

Every interactive control needs an accessible name. Decide by whether the control already
has visible text:

| Situation | How to name it | Example |
|-----------|----------------|---------|
| Control **has** visible text (a labelled button, a nav item with a label) | The text *is* the name — the named/text slot supplies it. Add nothing. | `M3e.button [ … ] [ M3e.text "Save" ]` |
| **Icon-only** control (icon button, icon-only FAB, a `Switch`/`Radio` whose label sits elsewhere) | Explicit ARIA name — **required** | `M3e.iconButton [ Aria.label "Back" ] [ M3e.icon [ M3e.Attributes.name "arrow_back" ] [] ]` |
| Name lives in another visible element | Reference it | `Aria.labelledby "field-id"` |

**ARIA is the native-HTML hybrid — the setters come from `TypedHtml.Aria`, not `M3e.*`.**
`M3e.*` deliberately does not mint aria setters; you reach across to the native-HTML brand:

```elm
import TypedHtml.Aria as Aria

M3e.iconButton [ Aria.label "Back" ] [ M3e.icon [ M3e.Attributes.name "arrow_back" ] [] ]
```

`Aria.label` / `Aria.labelledby` / `Aria.describedby` are ordinary `Attr` producers that fit
any element's row. (If you must set it as a raw string, `Seam.asAttribute (attribute
"aria-label" "…")` or `Native.attribute "aria-label" "…"` from `docs/kit/` also work.)

**The nameless icon-only control is the pattern you cannot ship.** An
`<m3e-icon-button>` wrapping a bare `<m3e-icon>` announces nothing to assistive tech.
Trailing `Switch`/`Radio` controls in list rows are the sneaky case — their visible label
is a sibling `ListItem` text, not their own, so they still need `Aria.label` (see the
Settings example's `switchRow`/`themeRow`, which pass `Aria.label label` on every
`Switch` and `Radio`).

## Read the review errors as a11y guidance

The Cem review rules (from `elm-review-cem`, wired in `review/src/ReviewConfig.elm`) are
accessibility feedback, not bureaucracy:

- **`missingRequiredAttribute`** on a control that lists `aria-label` in its
  `requiredAttrs` (config, e.g. `FilledButton`) = "this control has no accessible name;
  add `Aria.label` (from `TypedHtml.Aria`)." It reads per-component facts and refuses the nameless control when
  `elm-review` runs in CI.
- **`RequireSlot`** = a required semantic slot (a label, a title) is absent from the
  content — often the same "no accessible name / no visible label" problem seen as
  structure.
- These are **advisory/report-only** for cases the analyzer can't resolve statically
  (dynamic/`List.map`-built content) — a static-analysis limit, not a bug. A green
  `elm-review` is necessary but not sufficient; still spot-check the a11y tree.

## What @m3e/web handles vs what you wire

| Handled by `@m3e/web` (the custom element) | You must wire (Elm side) |
|--------------------------------------------|--------------------------|
| Roving focus / arrow-key navigation within a component (menu, list, tabs, radio group) | The **accessible name** of icon-only controls (`TypedHtml.Aria.label`) |
| Internal roles on shadow-DOM parts | **Focus management across route/state changes** (moving focus into an opened dialog, returning it on close) |
| Focus ring / focus-visible styling (strengthen with `Theme.strongFocus`) | **Grouping semantics** you own — e.g. a `name` shared across a `Radio` group so it reads as one control (Settings `themeRow` uses `M3e.Attributes.name "theme"`) |
| Escape-to-close, backdrop, focus-trap on dialogs it owns | **Live-region / status** announcements for your own app state changes |
| `disabled`/`checked` state on the element | **Meaningful order** of DOM/slot children (screen readers follow source order) |

Rule of thumb: `@m3e/web` owns *intra-component* keyboard and focus; **you** own
*inter-component* focus, naming, and grouping. Never signal state by color alone (the
knowledge base's `color-only-state-signaling` anti-pattern) — pair it with an icon, text,
or `aria-*`.

## Playwright a11y spot-check recipe

The docs use a browser harness (`docs/tests-browser/`, `docs/playwright.config.ts`) and a
one-shot transform (`docs/scripts/a11y-icon-button-labels.mjs`) that gives every icon-only
example an accessible name. Adapt this spot-check for your own app:

1. Serve the app; wait until the custom elements upgrade (poll for a component's
   `shadowRoot`, as the usage specs do — `networkidle` never fires under the dev SSE).
2. Snapshot the accessibility tree and assert every interactive node has a non-empty
   accessible name:
   ```js
   const snapshot = await page.accessibility.snapshot();
   // walk snapshot; fail if any button/link/switch/radio node has name === ""
   ```
3. Tab through: assert focus order is sensible and a visible focus ring appears.
4. For dialogs/menus: assert Escape closes and focus returns to the trigger.

## Reference

- The `/guide/accessible-by-construction` route (`docs/app/Route/Guide/AccessibleByConstruction.elm`)
  — the running labeled-vs-nameless example beside the real rule output.
- The m3e knowledge base's `foundations/accessibility` page — WCAG theory (contrast,
  name/role/value, focus-visible) and per-component accessibility notes.
- Per-component required-name facts live in `config/slots.json` (`requiredAttrs`) and the
  generated `M3e.Review.Facts`.

---
_Validated against elm-m3e 1.0.0, 2026-07._

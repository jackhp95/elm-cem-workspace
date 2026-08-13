# Coverage & Gaps — m3-kit profile

The correspondence Venn diagram between the **web-component library** (`@m3e/web` 2.7.0 CEM,
128 custom-element tags) and the **Figma Material 3 Design Kit** (171 `COMPONENT_SET`s), plus
the rationale for every correspondence candidate we evaluated and skipped.

_Snapshot date: 2026-07-29. Regenerate the figures with `pnpm gap --profile m3-kit`._

## Venn snapshot

| Region | Count | Meaning |
|---|---|---|
| **Overlap (matched)** | 69 Figma sets ↔ 49 CEM entries | 43 confirmed + 4 proposed + 2 newly bound |
| **Figma-only crescent** | 102 sets / 41 families | Figma sets bound to no CEM tag |
| **Web-components-only crescent** | ~79 CEM tags | CEM tags with no Figma set — mostly primitives & sub-parts (`m3e-ripple`, `m3e-state-layer`, `m3e-focus-ring`, `m3e-dialog-action`, `m3e-menu-item-checkbox`, `m3e-breadcrumb-item`, …) |

## The Figma crescent — what Figma has, split by *why* it's unbound

Cross-referencing all 41 figma-only families against the 128 CEM tags, the 102 figma-only sets
fall into four buckets. **Only bucket A is genuinely "missing from `@m3e/web`."**

### A. Genuinely missing from `@m3e/web` (the true crescent)
- **Carousel** (`Carousel`, `Carousel - Full screen`) — no `m3e-carousel`. The nearest tags,
  `m3e-slide` / `m3e-slide-group`, are a *pagination/scroll* control for overflowing content,
  not an M3 media carousel. Different semantics.
- **XR / spatial family** (16 sets: `XR App Bar`, `XR Dialog`, `XR Navigation Rail`, and XR
  variants of other components) — `@m3e/web` has **no XR components at all**. This is the
  single largest genuine gap.

### B. Covered by `@m3e/web`, just not matched (a matching task, not a missing component)
- **Date pickers** — `Modal date picker`, `Docked input date picker [desktop]`,
  `Input date picker`, `Local M3 calendar cell`, `Year` → `m3e-datepicker`, `m3e-calendar`,
  `m3e-month-view`, `m3e-year-view`, `m3e-multi-year-view`, `m3e-date-input` all exist.
- **Time picker** — `Dial picker`, `Keyboard picker`, `Period Selector`, `Hour`,
  `Direct Input (keyboard) input` → `m3e-timepicker`, `m3e-timepicker-dial`,
  `m3e-timepicker-input`, `m3e-timepicker-input-period-toggle`. **Added in `@m3e/web` 2.7.0** —
  the version bump closed this gap on the code side, so it is now purely a matching follow-up.

### C. Variants of already-matched components (no dedicated CEM tag by design)
- `Centered slider`, `Range slider` → `m3e-slider` (+ `m3e-slider-thumb`, multi-thumb).
- `Secondary tabs` → `m3e-tabs`.
- `Search full-screen layout`, `Flat`/`On-scroll` search bars → `m3e-search-view` / `m3e-search-bar`.
- `List dialog`, `Scrollable list dialog` → `m3e-dialog` + `m3e-list`.
- `List Item - Swipe` → `m3e-list-item`.
- `Bottom app bar` → `m3e-toolbar` / `m3e-app-bar` (M3 bottom app bar ≈ toolbar; no dedicated tag).

### D. Building blocks / states / sub-parts (not standalone components)
`Card states`, `Content`, `Input`, `Leading element`, `Trailing element`, `Reveal element`,
`Menu list item`, `Menu button`, `Navigation bars`/`Navigation rail` nav-item blocks,
`Progress indicator` wave segments, `Standard`/`Vibrant` icon-button blocks,
`Side sheets`/`Bottom sheets` content blocks, `Button group` connected segments, `.Shape`,
`Examples/Layout grid`.

## Correspondence candidates evaluated & skipped (rationale)

Authored this pass (`manual-correspondence.json`):
- **`m3e-fab-menu-item`** → `.Building Blocks/FAB Menu/Primary/Segment` (`57998:42953`).
- **`m3e-button-segment`** → `Building Blocks/Segmented button/Button segment (middle)` (`53923:36691`).

Skipped, with reason:
- **`m3e-carousel` ↔ Carousel** — `m3e-carousel` is not a CEM tag; `m3e-slide-group` is a
  pagination control, not a media carousel. → genuine gap (bucket A), not a match.
- **`m3e-bottom-app-bar` ↔ Bottom app bar** — no such CEM tag (only `m3e-app-bar`). → variant (bucket C).
- **Range slider / Extended FAB** — already covered (`m3e-slider`; Extended FAB appended to `m3e-fab`).
- **`m3e-date-input` ↔ date picker** — its only clean match, `Input date picker`, is already
  bound to `m3e-datepicker`; no unclaimed genuine match.
- **`m3e-radio-group` / `m3e-selection-list` / `m3e-filter-chip-set` / `m3e-input-chip-set`** —
  would double-bind sets already bound to their base tags (`m3e-radio`→Radio buttons,
  `m3e-list`→List, `m3e-chip-set`→Chip groups).
- **`m3e-select`, `m3e-tree`/`m3e-tree-item`, `m3e-divider`, `m3e-paginator`, `m3e-autocomplete`,
  `m3e-stepper*`, `m3e-breadcrumb*`** — no corresponding Figma `COMPONENT_SET`.
- **`timepicker` family** — Figma time sets exist (bucket B) and the CEM tags now exist (2.7.0),
  but this pass was scoped to skip them; matchable follow-up.
- **The 4 already-`proposed` tags** (`m3e-bottom-sheet`, `m3e-fab-menu`, `m3e-loading-indicator`,
  `m3e-snackbar`) — left for a human-confirm step, not re-authored.

## Bottom line
The Figma crescent that `@m3e/web` **genuinely lacks** is essentially two things: **Carousel** and
the **XR/spatial family**. Everything else Figma draws is either already implemented in the CEM
(date/time pickers — time picker newly so in 2.7.0), a variant of a matched component, or a
building block. The remaining coverage work is therefore mostly *matching* (binding existing CEM
tags to their Figma sets), not *implementing* new web components.

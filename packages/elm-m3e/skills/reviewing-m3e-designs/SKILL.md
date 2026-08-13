---
name: reviewing-m3e-designs
description: >-
  Reviews Elm view code that uses elm-m3e for Material 3 Expressive design quality — the
  judgment-heavy mission skill. Use in projects using elm-m3e when the user asks to review
  an m3e screen or component, "does this look Material / on brand", "critique my m3e UI",
  "is this the right component", or wants a design/UX pass on Elm view code before merge.
  Applies a design-review checklist: component choice matches intent (chips vs radio vs
  select, FAB vs button, dialog vs inline), expressive principles applied deliberately
  (emphasized type / shape / motion for key moments, not everywhere), density and
  touch-target sanity, and the Material anti-patterns (FAB misuse, dialog misuse,
  over-expressive motion, color-only state, too many emphasis levels). Also runs
  elm-review with the Cem rules and interprets the results. Cross-links the m3e knowledge
  base's choosing guidance and anti-patterns for the neutral rationale. For building see
  building-m3e-uis; for layout composing-m3e-layouts; for a11y making-m3e-accessible.
---

# Reviewing M3e designs

This is a **design** review of Elm view code, not a code review. The mechanical checks
(enum validity, slot kinds, required presence) are handled by the compiler and
`elm-review` — run them, but they are table stakes. The judgment is: *is this the right
component, used with intent, at the right emphasis and density?* Run both passes.

## Pass 1 — mechanical (necessary, not sufficient)

From `docs/`, run the gating config (the always-on Cem rules —
`validEnumValue`, `requireSlot`, `singularSlot`, `singularAttribute`,
`missingRequiredAttribute`, `missingRequiredSingularSlot`, `validSlotKindWith Lenient` —
plus the repo-local `NoProprietaryDsClasses`):

```bash
cd docs && pnpm exec elm-pages gen \
  && node_modules/.bin/elm-review --config ../review --compiler node_modules/.bin/elm
```

Interpret, don't just clear: `missingRequiredAttribute`/`RequireSlot` are usually a11y
gaps (see making-m3e-accessible); `NoProprietaryDsClasses` means a class is doing a visual
job that a token should (see theming-m3e-apps); `validSlotKind` stays silent on content it
can't resolve statically (`List.map`, helpers) — so a clean run does **not** prove slot
kinds; eyeball dynamic content.

## Pass 2 — the design-review checklist

Go through every screen with these questions. Each maps to a page in the **m3e knowledge
base** — cite it for the neutral rationale, do not restate it here.

### 1. Component choice matches intent

Reuse the knowledge base's per-component *choosing* guidance (`components/*`). Common
mismatches:

- **Chips vs radio vs select vs segmented button.** Single choice from ≤~5 visible
  options → `Radio` group or `SegmentedButton`. Single choice from many → `Select`.
  *Filtering* a result set → `FilterChip` set. Free-form entry/removal of tags → input
  chips. A chip set used to pick one mutually-exclusive option is usually the wrong
  control.
- **FAB vs button.** A FAB is *the single most important, constructive* action on a
  screen (compose, create, add). One per screen. See "FAB misuse" below.
- **Dialog vs inline / snackbar.** A dialog is for a *blocking* decision the user must
  resolve now. Transient confirmation → `Snackbar`. Non-blocking info → inline. See
  "dialog misuse" below.
- **ListItem vs a laid-out row.** A control that isn't list supporting-text (a full-width
  `Slider`) belongs in a plain layout row, not crammed into a `ListItem` text slot — the
  Settings `densityRow` is the correct call.

### 2. Expressive principles applied DELIBERATELY

Material 3 *Expressive* adds emphasized type, an expanded shape system with morphing, and
physics-based motion. The discipline (knowledge base `expressive/applying-expressive`):
**pick the moments that lead; one channel per moment is usually enough.** Review for:

- **Emphasis for hierarchy, not decoration.** Emphasized/heavier type marks *the* thing
  that leads a view (a hero headline, a primary metric). If everything is emphasized,
  nothing is — the "too many emphasis levels" anti-pattern.
- **Shape/motion at key moments only.** Reserve expressive shape and spring motion for
  moments that deserve weight (a primary CTA, a celebratory confirmation), not on every
  card and every transition.
- **Respect density.** Expressive motion in a dense, high-frequency workflow (a data
  table, a mail list) is fatiguing — the "over-expressive motion in dense workflows"
  anti-pattern.

### 3. Density and touch targets

- Interactive targets ≥48dp regardless of `Theme.density`. Compact density tightens
  spacing, not hit areas.
- Consistent spacing vocabulary (the examples stay within `gap-2/4/6`), not per-screen
  ad-hoc values (ties to composing-m3e-layouts).

### 4. Anti-patterns to flag (cross-link the knowledge base)

| Flag when you see | Anti-pattern (knowledge base) |
|-------------------|-------------------------------|
| A FAB used for a secondary/destructive action, or several FABs on one screen | `anti-patterns/fab-for-non-primary-actions` |
| A dialog used for non-blocking info, or a confirmation that should be a snackbar | `anti-patterns/dialog-for-non-blocking-info` |
| Spring/expressive motion on a dense list or table | `anti-patterns/over-expressive-motion-in-dense-workflows` |
| State (selected/error/disabled) signaled by color alone | `anti-patterns/color-only-state-signaling` |
| Three+ competing emphasis levels in one view | `anti-patterns/too-many-emphasis-levels` |

### 5. Color roles and theming

- Roles chosen by intent: `primary` reserved for actions; secondary/tertiary for accents
  (the Mail pane leans on `tertiary` to keep `primary` for actions). Contrast preserved
  on-surface. See theming-m3e-apps and the knowledge base's `styles/color`.
- No raw hex; no class doing a color/shape job.

## Output of a review

Report findings as: **file:function → what's wrong → the intended component/token →
the knowledge-base page.** Distinguish *blocking* (a11y gap, wrong control that misleads)
from *advisory* (an emphasis or motion refinement). Prefer the smallest change that
restores intent — usually swapping a component or a token, not restructuring.

## Reference

- **[reference/review-corpus.md](reference/review-corpus.md)** — a regression corpus of
  seeded design violations (the eval set) with the exact fix for each, so the review is
  reproducible.
- The m3e knowledge base's `anti-patterns/`, `expressive/`, and `components/` sections —
  the neutral design rationale this checklist applies.

---
_Validated against elm-m3e 1.0.0, 2026-07._

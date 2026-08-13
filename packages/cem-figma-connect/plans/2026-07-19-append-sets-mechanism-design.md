# 2nd-set ("appendSets") mechanism — Design + Plan

**Status:** approved-to-proceed (Jack 2026-07-19: "continue" — bank all remaining). Unlocks ~15 more bindings that are real Figma sets whose CEM tag is ALREADY confirmed.

**Goal:** Let a Figma COMPONENT_SET bind to an already-confirmed cemTag as an ADDITIONAL set, each with its OWN per-set example. `manual-correspondence.json` currently fail-loud refuses bound tags; this adds an explicit append mode. Unlocks: Extended FAB→m3e-fab; 4 Toggle-button→m3e-button; 4 Icon-button-togglable→m3e-icon-button; the 4 other tab content sets→m3e-tab (+ more later).

---

## Findings (render-verified 2nd-set shapes)
- Toggle button (m3e-button `toggle selected variant`): renders a filled selected toggle button (heart + Favorite). ✓
- Icon-button togglable (m3e-icon-button `toggle selected variant`): filled selected icon button. ✓
- Extended FAB (m3e-fab `extended`): pill FAB with label. ✓ (icon goes in the DEFAULT slot, not slot="icon" — the investigator markup used slot="icon" which rendered label-only; corrected to default-slot icon.)
- Tab icon-only (m3e-tab, icon slot only) + label-only (m3e-tab, default text only): ✓ (m3e-tab already banked with icon+label; these are content variants).

## Design — `appendSets` in manual-correspondence.json + per-set inline examples
A manual-correspondence entry gains an optional `appendSets` array (distinct from `figmaSets`, which is for pure-gap/unbound tags). Each appendSet: `{ nodeId, setName, fixedAttrs?, example?: { children: ChildSpec[] } }`.

**Merge** (`applyManualCorrespondence`, src/correspond/merge.mjs):
- For an entry with `appendSets`: the cemTag MUST already exist in the correspondence AND be bound (have ≥1 figmaSet). If absent/unbound → THROW (`appendSets: '<tag>' is not an existing bound entry — appendSets adds to a confirmed component, use figmaSets for a gap`).
- Append each appendSet to that entry's `figmaSets` (preserving the primary sets first, appended after, in file order). Each appendSet's `nodeId` MUST NOT already be present → THROW on duplicate.
- The appended figmaSet objects carry their inline `example` field through to emit.
- Deterministic (a match-time input) → re-match reproduces → the A8 byte-stable tracer holds. The PRIMARY sets are untouched → their emitted files stay BYTE-IDENTICAL; only NEW appended files appear.

**Emit** (html-label.mjs + elm.mjs): per figmaSet, resolve example children as
`figmaSet.example?.children  ??  config.examples[cemTag]?.children  ??  (standard prop-derived / bare)`.
So an appended set uses its OWN inline example; the primary sets keep their existing behavior (examples.json or standard). fixedAttrs on an appendSet emit + drive the slug exactly as today (so toggle-button files slug by variant: `m3e-button-filled`… collides with the plain button `m3e-button-filled`! → see collision note).

**Filename collision note:** toggle-button `fixedAttrs {variant:"filled"}` slugs to `m3e-button-filled`, which COLLIDES with the plain filled button. The appendSet needs a distinguishing slug. Add a per-appendSet `slugSuffix` (e.g. "toggle") → `m3e-button-filled-toggle`. Emit appends `-<slugSuffix>` to the id when present. (Simplest sound fix; avoids poisoning the primary slugs.)

**Validate** (`validateManualCorrespondence`): for each appendSet — nodeId is a real COMPONENT_SET in the figma export, setName matches, and the inline `example.children` validate against the CEM (reuse validateExamples' walk).

---

## Verification + banking
The append targets are CONFIRMED, so appended sets emit immediately (no per-set confirm). AF-07: the controller render-verified each shape. `check` 0-drift. **Tracer ripple:** appending to m3e-button/icon-button/fab/tab changes THEIR figmaSets counts + adds files → update html-label.test.mjs's `buttonEntry.figmaSets.length` (5→9) + emit/smoke counts + manifest per-tag lengths.

## Tasks (TDD)
- **T1** — merge: `appendSets` append logic (bound-only + no-dup + fail-loud) + `slugSuffix` + validate. Unit tests (synthetic): append onto a bound entry grows figmaSets + carries inline example + slugSuffix; append onto an absent/unbound tag THROWS; a dup nodeId THROWS.
- **T2** — emit: per-set inline `example` resolution (figmaSet.example first) + `slugSuffix` in the id, in html-label + elm. Tests: a figmaSet with inline example emits THOSE children (not examples.json); slugSuffix appears in the filename; a set without inline example is unchanged (byte-identical).
- **T3** — bank the appendSets (controller-driven config + confirm/emit + tracers).

## Scope / out
- **In:** appendSets + per-set inline example + slugSuffix + validation; bank Extended FAB, 4 Toggle-button, 4 Icon-button-togglable, 4 tab content sets.
- **Out:** the no-cem-tag sets (time pickers, bottom-app-bar, layout grid — library gaps); carousel (renders blank); list-item density/swipe, menu-baseline, dialogs (lower value — a later pass). Byte-stability of the 43 primary banks is a HARD gate.

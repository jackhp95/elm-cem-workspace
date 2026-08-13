# Representative-Example Emission — Design

**Status:** approved-in-principle 2026-07-18 (Jack — option A config + structural-eyeball verification). Enables by-example banking of composite/container components.

**Goal:** Let composite/container components (card, dialog, button-group, segmented-button, split-button, fab-menu, app-bar, menu-item, nav-item, slider, tooltip, …) bank via a **correct, representative code example** rather than the pixel gate. Policy (Jack): Code Connect's value is the *binding*, not pixel-reproducing the Figma showcase — so a component with a correct, illustrative example is bankable even when the harness can't reproduce its rich Figma default. Target: **+8–10 banked real components.**

**Why now:** the matcher's contains tier matched these components (correct correspondences exist as `proposed`), but their Figma defaults are rich showcases the harness renders blank/wrong → the pixel gate rejects them. The emitters today produce **bare** examples (`<m3e-segmented-button></m3e-segmented-button>`), **wrong** slot usage (split-button puts a label in the default slot, not `leading-button`/`trailing-button`), or **crash** on multiple TEXT→`content` props (card/dialog).

---

## Unit 1 — `examples.json` config + emitter injection

### 1.1 The config (emitter-agnostic, structured)

A new `profiles/m3-kit/examples.json`: `cemTag → { children: ChildSpec[] }`. A `ChildSpec` is a small recursive record both emitters can render:

```
ChildSpec = {
  tag: string,                 // e.g. "m3e-button-segment", "m3e-icon", "span"
  slot?: string,               // slot="<name>" (omit for default slot)
  text?: string,               // text content
  attrs?: { [name]: string },  // static attributes (e.g. name="star" for an icon)
  children?: ChildSpec[]       // nesting
}
```

Example:
```json
{
  "m3e-segmented-button": { "children": [
    { "tag": "m3e-button-segment", "text": "Label" },
    { "tag": "m3e-button-segment", "text": "Label" },
    { "tag": "m3e-button-segment", "text": "Label" }
  ]},
  "m3e-split-button": { "children": [
    { "tag": "m3e-button", "slot": "leading-button", "text": "Label" },
    { "tag": "m3e-icon-button", "slot": "trailing-button", "children": [
      { "tag": "m3e-icon", "attrs": { "name": "arrow_drop_down" } } ] }
  ]},
  "m3e-card": { "children": [
    { "tag": "span", "slot": "header", "text": "Header" },
    { "tag": "span", "slot": "content", "text": "Supporting text" },
    { "tag": "m3e-button", "slot": "actions", "text": "Action" }
  ]}
}
```

Explicit, correct, deterministic (config-driven, no inference), reviewable, bounded (~10 components). Each child's `tag` is a real CEM tag chosen to match the component's slots — the content the CEM cannot machine-declare.

### 1.2 Emitter behavior

When a component's `cemTag` has an `examples.json` entry, the emitter emits `<tag {mappedAttrs}>{rendered children}</tag>`:
- **mappedAttrs** — still computed from the correspondence axes/props as today (variant, size, etc.), so the example carries the real driven/fixed attributes.
- **children** — rendered from the config's `ChildSpec[]`, REPLACING any prop-derived slot content. Slot-bound props (text→`content`, icon slots, etc.) are SKIPPED for these components — the explicit example is the source of truth for slot content.
- Both emitters render the SAME `ChildSpec[]`: html-label into `<tag slot="..." ...>text</tag>`; the elm emitter into its `renderExample` child syntax (the `figma.code` element form).

A component WITHOUT an `examples.json` entry keeps the current behavior unchanged (the 14 banked stay byte-identical).

### 1.3 Loading

`examples.json` loads via `loadProfile`-adjacent code (a sibling to how `htmlLabel`/`elm` config already loads), passed into both emitters. Missing file → empty map (backward-compatible; existing profiles unaffected).

---

## Unit 2 — multi-TEXT-slot crash guard

Card/dialog crash because the matcher's `proposeProperty` maps EVERY Figma TEXT prop to `binding:"content"`, and the emitter throws on a second `content` prop. Two parts, both defensive and minimal:

1. **Emitter:** a component in `examples.json` skips ALL prop-derived slot content (§1.2), so the multiple-`content` props never reach the throw — the crash dissolves for our target components without touching the matcher.
2. **Robustness (no silent drop, no crash):** for a component NOT in `examples.json` that has >1 TEXT→`content` prop, the emitter emits the FIRST as default content and records the rest as a rationale comment in the file (`// note: additional text props <names> not emitted — needs an examples.json entry or a slot mapping`) instead of throwing. This keeps `emit` from crashing on any future multi-text component while making the gap visible.

We deliberately do NOT add name-affinity TEXT→slot mapping to the matcher now (YAGNI — the explicit `examples.json` children cover our targets more correctly than a heuristic could).

---

## Unit 3 — verification + banking (by-example)

No pixel gate for these. Verification has TWO parts, both autonomous:

1. **Structural validation (deterministic, machine-checkable):** every `ChildSpec.tag` is a real CEM custom-element tag (or a plain HTML tag like `span`), and every `ChildSpec.slot` is a real named slot of the PARENT component per the CEM. This catches typos + wrong-slot usage (the split-button-default-slot bug) mechanically, before any rendering. A tiny validator over the CEM + `examples.json`; runs in the test suite.
2. **Visual eyeball (structural yes/no, not a pixel ratio):** render the emitted example's RAW markup — write `<m3e-card {attrs}>{children}</m3e-card>` into a minimal static page (the m3e bundle loaded, fonts ready) and screenshot it. NOT page.mjs's URL-param slot scheme (which can't express nested children like split-button's trailing icon-button). Then eyeball: is it a plausible, correct instance matching the Figma's *kind* (a segmented button shows N segments; a split button shows a leading label + trailing chevron)? This is the AF-07 discipline adapted from a pixel ratio to a structural yes/no.

Bank on BOTH passing: add to `overrides.json` with **`gate:"example-verified"`** (distinct from `gate:"approved"` pixel-gated banks) + a note describing the example. The provenance stays honest — a reader can tell pixel-verified banks from example-verified ones.

`confirm → emit` then produces the `.figma.ts` with the representative example. The 4 tracer tests grow per banked component (as with fab/avatar).

---

## Architecture / units

- **`profiles/m3-kit/examples.json`** (new) — the per-component `ChildSpec[]` content.
- **`src/emit/example-content.mjs`** (new, small) — pure: `renderChildrenHtml(childSpecs)` + `renderChildrenElm(childSpecs)` (or an emitter-agnostic AST the two emitters consume) + `validateExamples(examples, cem)` (every child tag is a real CEM/HTML tag; every `slot` is a real named slot of its parent). One clear job area: turn `ChildSpec[]` into each emitter's child syntax + validate it against the CEM. Keeps both emitters thin.
- **`src/emit/html-label.mjs`** (modify) — when `examples[cemTag]` exists, use its children (via example-content.mjs) + skip prop-slot-content; else unchanged. Plus the Unit-2 no-crash guard.
- **`profiles/m3-kit/emitters/elm.mjs`** (modify) — same: render the `ChildSpec[]` into the Elm example child form.
- **loader** (small) — read `examples.json`, thread into both emitters.
- **`overrides.json`** — `gate:"example-verified"` entries for the newly-banked components.

---

## Testing

- **`example-content` unit:** `renderChildrenHtml`/`renderChildrenElm` for a nested ChildSpec (slot, attrs, text, children) → exact expected snippet; empty/missing → empty string. `validateExamples` — a bad child tag or a slot that isn't a real slot of its parent throws with a clear message; the real `examples.json` validates against the CEM.
- **html-label:** a component with an `examples.json` entry emits `<tag mappedAttrs>{children}</tag>` and does NOT emit prop-derived slot content; a component without one is byte-identical to today. The multi-content component (card) no longer throws (emits first content + a note, OR uses its examples children).
- **elm:** same component renders the ChildSpec children into the Elm example form.
- **Regression:** the 14 confirmed banks' emit output stays BYTE-IDENTICAL (none are in examples.json yet, so their emission path is unchanged); A8 byte-stable; full `pnpm test` green.
- **Per-bank:** each newly-banked component's `.figma.ts` contains its representative example; tracer tests updated.

---

## Scope / out of scope

- **In:** `examples.json` + `example-content.mjs` + both emitters' injection + the crash guard + verify/bank flow. Bank the ~8–10 target composites incrementally (one commit each, or batched) once their examples render correctly.
- **Out:** the matcher, the contains tier, the harness/gate, live capture, the pixel-gate tiers. No matcher name-affinity TEXT→slot mapping (YAGNI). Publishing (org PAT). The elm emitter's deeper surface-form mechanics beyond rendering the ChildSpec children.
- **Verification honesty:** `example-verified` banks are explicitly NOT pixel-verified — recorded distinctly so the quality provenance is auditable (preserves the AF-07 discipline's intent while relaxing its mechanism per Jack's policy).

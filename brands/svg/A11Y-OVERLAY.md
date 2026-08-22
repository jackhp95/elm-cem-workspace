# SVG a11y overlay — note for Task 6 (`Cem.ValidComposition`)

**Status:** spec note only. This file adds NO code. It records the SVG-AAM
constraints that the future `Cem.ValidComposition` rule (families/a11y plan
Task 6) should dispatch on for the `TypedSvg` brand. The *content-model* half of
this plan (which child may sit in which container) is already enforced — it was
authored into `inputs/config.json` as spec-derived `admits`/`slotKinds` and is
checked by `Cem.ValidSlotKind` (see the regenerated
`generated/package/elm-typed-svg/src/TypedSvg/Review/Facts.elm`). What remains,
and what this note scopes, is the **a11y overlay** that `ValidSlotKind` cannot
express because it is about *attributes* (`role` / `aria-*`), not child kinds.

## Source of truth

The overlay DATA already exists, provenance-stamped, in the shared foundation:

- `docs/a11y-foundation/composition-rules.json` → key `svgAamOverlay`
  (`enforcedBy: "ValidComposition"`), from **SVG Accessibility API Mappings 1.0**
  (<https://www.w3.org/TR/svg-aam-1.0/>, fetched 2026-08-22).

Task 6 should read that block, not re-derive it. This note only *maps it onto
this brand's element vocabulary* (the 27 elements actually modelled in
`generated/package/elm-typed-svg/manifest/svg.cem.json`).

## The two overlay rules Task 6 must dispatch (SVG scope)

### 1. `role` / `aria-roledescription` on a non-rendered element → violation

SVG-AAM: for elements that create no accessible object, *"no role may be
applied … The `aria-roledescription` attribute MUST NOT be exposed on these
elements."*

The foundation's `svgAamOverlay.nonRendered.elements` set is:
`animate, animateMotion, animateTransform, clipPath, defs, filter, mask,
pattern, set`.

**Intersected with THIS brand's current vocabulary** (no `fe*`/filter and no
animation elements are modelled here yet — they arrive with the svg-audit
branch's filter family), the elements to flag are:

- **`defs`**
- **`clipPath`**
- **`mask`**
- **`pattern`**

When the filter/animation families land (svg-audit branch merge), the flag set
must additionally cover: `filter`, `animate`, `animateMotion`,
`animateTransform`, `set` (and `discard`, which SVG-AAM treats the same). Task 6
should key off the foundation set, not this hand-copied subset, so it stays
correct after that merge.

Rule shape (advisory→error, Task 6's call): if a `TypedSvg.*` constructor for
one of the above elements is given a `TypedSvg.Attributes.role _` (or
`ariaRoledescription _`) attribute, report it — a `role`/`aria-roledescription`
on a non-rendered SVG element is an SVG-AAM violation.

> **Update (2026-08-22, Task 6 wiring):** `role` was already an open-row
> `_globals` entry (`TypedSvg.Attributes.role : String -> Attr c msg`) by the
> time Task 6 landed; `aria-roledescription` was added beside it the same way
> (`TypedSvg.Attributes.ariaRoledescription : String -> Attr c msg`), so the
> prerequisite this note originally flagged is now satisfied and the overlay
> fires — see `pipeline/elm-review-cem/src/Cem/ValidComposition.elm`
> (`svgAamCheck`) and this brand's `generated/package/elm-typed-svg/review/`.
> The content-model half (below) is fully live regardless. This *complements* the
content-model `admits` (it does not replace it): `defs`/`mask`/etc. are already
constrained as structural containers by `slotKinds`; this catches the orthogonal
*attribute* misuse.

### 2. `title` / `desc` name/description precedence — advisory only

SVG-AAM: `title`/`desc` create no accessible object; they are the name/
description *sources* for their PARENT, with precedence
`aria-labelledby > aria-label > child <title> > text`.

This is why `title`/`desc` are kept **universally admitted first children** in
every container's `admits` (verified: every container slot in
`inputs/config.json` lists `"title", "desc"` alongside its `@svg*Content` set).
No error is warranted here — it is an **advisory** the rule may surface (e.g.
"this element has both `aria-label` and a child `<title>`; `aria-label` wins").
Encode it as advisory, never as a hard failure.

## What is already DONE (so Task 6 does not redo it)

- Every `kinds:["any"]` container in `inputs/config.json` was replaced with a
  spec-derived kind list (SVG-2 content model, cross-checked against MDN
  per-element "Permitted content"). Containers fixed: `Svg`, `G`, `Defs`,
  `Symbol`, `A`, `Switch`, `Pattern`, `Mask`, `Marker`, `ClipPath`.
- `title`/`desc` remain universally admitted on every container.
- The regenerated facts prove enforcement: a spec-invalid composition (e.g. a
  `g` inside a `clipPath`, or a `linearGradient` inside a `switch`) now trips
  `Cem.ValidSlotKind`.

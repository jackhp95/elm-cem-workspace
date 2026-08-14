---
name: markup-categories-typed-globals-design
description: "Active markup design (2026-07-13) — typed enum globals via tokens + content-category nesting via container-side aliases; supersedes the prior handoff's (wrong) mechanism; validated in the real generator"
metadata: 
  node_type: memory
  type: project
  originSessionId: 28cacfe4-6445-4fd1-886a-e844274e69c6
---

Active design work on the **markup** HTML library (elm-cem), started 2026-07-13. Authoritative handoff:
`planning/execution/2026-07-13-markup-categories-typed-globals-design.md` (validated end-to-end in the
real generator — 64 modules compile). Two workstreams:

- **Typed enum globals** (`dir`, `contenteditable`, `hidden`, `draggable`, … 12): route through the
  manifest → shared-attr vocab → **portmanteau tokens** (like m3e `variant`), NOT hand-written unions.
  These are *enumerated* (not boolean); `""` is a synonym for the primary keyword (drop from token set).
  Keep `id`/`class`/`style`/`aria` on the open universal rail.
- **Content-category nesting**: categories are **container-side closed extensible-record type aliases**
  keyed on each element's EXISTING single marker — `type alias Phrasing e = { e | text : Shared, em : Brand, … }`,
  `Flow e = Phrasing { e | …block… }`. Dual-mode via the extension var (`Phrasing { option : Brand }`);
  lattice via alias composition. Elements and atom slots are **unchanged**.

CORRECTS the PRIOR handoff (`…-typed-globals-handoff.md`), which is **WRONG on mechanism**: you CANNOT
stamp category markers onto element rows (breaks closed atom slots — compiler-proven; the row polarity is
uniform: open producers + closed consumers = subset). Two-param `Element` and projection/opaque designs
were considered and rejected (doc Part 3). **Transparent/`*` elements** = a polymorphic **passthrough
row** (`view : … -> List (Element r msg) -> Element r msg`), which is EXACT for direct children (captures
`phrasing*`). Descendant rules (no-interactive-descendant) stay in the **review layer** (rows can't
subtract a flag).

Role/tag namespace rule (decided): **seam-role fields keep the `shared:` prefix** (`shared:text →
sharedText`, `shared:link → sharedLink`) so they never collide with **literal-tag fields** (`<link> →
link`) — dissolves the `<a>`/`<link>` collision by construction, generalizes to m3e user roles. `seam` =
the crossing *mechanism* (recast/Coerce/Seam); `shared` = cross-library *scope*. Flip the `shared:`-strip
in `kindFieldName` (duplicated in Config.elm + Coerce.elm) to keep-and-camelCase.
Error ergonomics: long-but-navigable (alias name preserved on the "needs" side, ~54 expanded field lines
on the inferred side, typo hint names the culprit) — opacity is the documented escape hatch, not paid up
front. Implementation wiring map is in doc §2.9.

**IMPLEMENTED + INTEGRATED 2026-07-13** (uncommitted per convention, in `~/Documents/code/elm-cem`).
Built by 2 parallel subagents in isolated copies + lead integration; full harness GREEN
(pipeline-proof, composition-test incl. new category negatives, size ≤700KB/facet, 361 tests,
format). Decisions taken with Jack: categories = **flow/phrasing/heading/metadata ONLY** (the only
ones used as container child-constraints — interactive/embedded/sectioning have ZERO container usage,
so modeling them is dead surface); **cross-lib seam BUILT** (unchecked projections in
`Markup.Category`); **`<a>` = curated `Markup.A` stays strict** (text-only `sharedText`, requires
href) **+ hand-written `Markup.TransparentAnchor.transparentAnchor : {href} -> List (Element r) ->
Element r`** seam (NO generator passthrough feature; §2.6 general passthrough deferred).

**GOTCHA (fixed):** Part 1's "globals on every element" tripled docs size — the per-element global
SETTER was duplicated ×113 elements (markup-build hit 1008KB/144%). Fix: added a `global : Bool`
provenance flag to `Cem.Attribute` (build.mjs stamps the 12 enumerated globals; the attr decoder reads
it — NOT a membership heuristic, which mis-fires on small libs) → `LibraryInfo.universalGlobalNames` →
suppress the duplicate per-element setter in `Middle.elm` and (via `buildSharedCtx.suppressedAttrs`)
`Top.elm`, while KEEPING globals in the capability ROW (rows use the un-suppressed `emittableSpecs`).
All facets back ≤700KB. **HARDENED the harness too:** `size-measure.mjs` no longer passes
`--no-assert`, so it now EXITS 1 on any facet >700KB (measure-docs' native gate; a try/catch still
prints the full report). Verified both paths — partA (Part-1-only, over) → FAIL; canonical → PASS.
Previously `--no-assert` made it print-only, which is exactly how the 1,008KB regression slipped past
two subagents' "green" exit codes.

Related: [[markup-full-coverage-prototype]], [[elm-m3e-cross-cem-branding]].

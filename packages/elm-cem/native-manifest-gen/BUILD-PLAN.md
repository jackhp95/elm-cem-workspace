*Historical record of the markup-prototype complete-HTML-coverage build (2026-07-13). Current architecture = HtmlIr IR + phantom generator; the referenced markup/ pipeline, config/\*.json runtime files, and dev harnesses (pipeline-proof.mjs / composition-test.mjs / size-measure.mjs) were deleted in the elm-phantom pass 1 refactor. This plan is archived — not the current development target.*

# Complete-Coverage Build Plan (autonomous, 2026-07-13)

Goal: **complete HTML coverage** — every non-obsolete tag, every attribute (element-specific +
global + ARIA + event handlers), and full closed-structural composition protection — generated
through the elm-cem pipeline with the family compiling + passing `elm make --docs`, split into
size-gated facets.

Baseline (already built): `manifest-gen/` emits `out/manifest.json` (113 elements, 386 element-attrs
+ 30 globals, 46.4% typed live surface) and pipeline-proof PASSes for 109 elements. See RESULTS.md.

## Slices & ownership (no two agents edit the same file)

### WA — Generator collision hardening  (dir: elm-cem/codegen/, Elm)
Fix the 4 name collisions full coverage surfaces so all 113 elements pass `--docs`:
- `<main>` → the raw-facet function is literally `main`, which Elm special-cases as the program
  entry point → escape reserved/special idents (e.g. emit `main_`, keep tag `markup-main`).
- `<style>`/`<title>`/`<slot>` element constructors collide with the same-named GLOBAL attribute
  setters in the barrel `Markup.elm` (confirmed duplicate `style =`). Disambiguate in the barrel.
Guardrail: `npm test` (elm-cem suite + compile-gate + split tests) stays green; `npm run format -- --validate` clean.

### WB — Attribute completeness  (dir: manifest-gen/, NEW files only)
Add the missing attribute surface as ISOLATED modules (do NOT edit build.mjs — export a clean API I wire):
- `src/aria.mjs` — ARIA: `role` + all `aria-*` from `aria-query`, typed (enumerated ARIA vals → enums).
- `src/events.mjs` — event handlers: all `on*` from WHATWG "event handler content attributes" index.
- `src/enums.mjs` — enum recovery for WHATWG "Other" value cells: `referrerpolicy`, `target`/`formtarget`
  (keyword hints), `sandbox`, `autocomplete` tokens, etc. Export a `recover(attr, valueCell)` overlay.
- `data/prose.json` — element summaries + attr descriptions for ALL 113 elements + every attr, from the
  WHATWG index Description columns (single cached source; note license/attribution). No generic fallbacks left.
Each module: documented exports + a self-test showing counts. Return the export signatures.

### WC — Composition config generation  (dir: manifest-gen/, NEW files only)
Generate the structural `config/slots.json` from the WHATWG "List of elements" Children column
(src/composition.mjs already extracts it — refine + productionize):
- `src/config.mjs` — emit a generated slots config: for each of the ~25 closed-structural families
  (table/tr/thead/tbody/tfoot/colgroup, ul/ol/menu, dl, select/optgroup/datalist, audio/video/picture,
  details/figure/fieldset/ruby/map/hgroup/html), a slot with closed `kinds` = the child elements'
  Brand kinds; category-only containers → `kinds: "arbitrary"`. Tier default: private for structural.
- Handle the kind vocabulary: each structural child element needs a Brand kind; parents reference them.
  Output must be shaped to merge with the hand-authored editorial `config/slots.json` (tiers/atoms),
  NOT overwrite it — emit `config/slots-structural.json` that composes.
- Self-test: print the parent→kinds map. Return it.

### INT — Integration (me)
Wire WB's modules + WC's config into build.mjs; regenerate manifest + merged config; pull in WA's
fixed generator. Produce the full 113-element manifest + generated structural config.

### VERIFY — Proof (me + a verification agent)
1. Full pipeline-proof: all 113 elements + compositions → generate + compile + `--docs` PASS.
2. `elm-cem split` + `measure-docs.mjs` with a packages.json adapted to full coverage → per-facet bytes ≤700,000.
3. **Negative composition tests** (load-bearing): Elm that puts a wrong child in a closed slot
   (e.g. `<div>` inside `Build.Tr`) MUST be a compile error. Prove protection is real, not cosmetic.
4. Adversarial typing spot-check: sample extracted enum/ARIA keyword sets vs the spec.

## Boundaries (deliberate, not silent)
- **Category nesting** (flow vs phrasing enforcement across all containers) is NOT auto-generated —
  faking a phrasing/flow kind lattice for all of HTML is a design decision, not a mechanical one.
  Category containers stay `arbitrary`; closed structural families get real protection. Flagged for editorial.
- **Editorial tier/atom/accessibility config** (link-requires-text, label↔control, img alt) stays
  hand-authored; WC generates STRUCTURAL slots only and composes with the curated layer.

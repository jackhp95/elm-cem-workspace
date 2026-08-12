*Historical record of the markup-prototype pipeline proof (Phases 0–4, 2026-07-13). Current architecture = HtmlIr IR + phantom generator; the markup/ pipeline, pipeline-proof.mjs dev harness, and the three size/composition test scripts were deleted in the elm-phantom pass 1 refactor. These results informed the design but are no longer the current state.*

# manifest-gen — Prototype Results (Phases 0–4)

> Executed 2026-07-13 from `planning/execution/2026-07-12-markup-full-coverage-handoff.md`.
> The tool is real infrastructure: `node gen.mjs` emits `out/manifest.json` (full HTML surface,
> CEM shape) + `out/reports.json`; `node pipeline-proof.mjs` runs the real generator + `elm make --docs`.

## TL;DR for the decision gate (Phase 5)

**Full HTML coverage is viable through the unchanged generator — with a small, named collision
fix.** 109/113 elements generate → compile → pass the `elm make --docs` publish gate today.
Four element names collide and need handling (below). Typed-attribute yield on the live surface is
**46.4%** (enum/bool/int/float); the rest are String because HTML/Elm model them as String, not
because typing failed. Total docs surface ~857 KB → **multi-facet split is mandatory** (anticipated).

## Load-bearing claim — VERIFIED empirically (not just by code reading)

- The generator (`bin/elm-cem.js` + `codegen/`) accepts the full-coverage CEM manifest **with zero
  generator changes**: `codegen/Attr.elm:classifyText` turns a `type.text` union string
  (`"'get' | 'post'"`) into the closed enum Value vocabulary; `"boolean"`→Bool, `"number"`→Int/Float.
- 5-element smoke + 109-element full run both: **generate + plain-compile (0 failures) + `--docs` PASS.**
- The 22-keyword `input[type]` enum flowed through and was handled ("multiple types across
  components; shared as dominant + type-suffixed variants").

## Coverage (out/reports.json)

| metric | value |
|---|---|
| Live elements (webref, non-obsolete) | **113** |
| Obsolete excluded | 29 (applet, acronym, bgsound, dir, frame, …) |
| Element-scoped attributes | 386 (265 live / 121 deprecated) |
| Global attributes (factored ONCE) | 30 |
| BCD noise pruned | 22 keys (implicit_noopener, text_fragments, input_type_*, …) |

## Typing (the long pole — honest split)

- **Live surface: 123/265 = 46.4%** get a precise-Elm type (enum 55 / bool 46 / int 41 / float 11).
- Deprecated attrs: 13/121 = 10.7% typed — because 97/121 are gone from the current spec (no WHATWG
  row). That is **correct**, not a gap.
- Of the String remainder, ~96 are **String-by-nature** (url/idref/token-lists/mime — Elm has no
  richer type; they'd be String in `elm/html` too). Genuine recoverable gap is small: `referrerpolicy`
  (+6 enum), 18 live attrs with no WHATWG row.
- Enums are emitted via elm-cem's **shared Value vocabulary** (phantom tokens), not N literal Elm
  unions — hence `docs.json` shows the closed Value row, matching the m3e design.
- Method note (anti-laundering): enum keyword sets are extracted from the WHATWG Value column's inline
  quoted literals (`"sync"; "async"; "auto"`) + one injected set (`input[type]` from BCD `type_*`).
  Spot-checked: decoding→sync|async|auto, crossorigin→anonymous|use-credentials|'', contenteditable→
  true|false|plaintext-only|''. All match the spec.

## Size (Phase 4 — out/size.json)

- 109-element package: **466 modules, 1.22 MB source, 856,494 B whole-package docs, 2,993 documented values.**
- The 700,000 B gate is **per facet**; whole-package docs (857 KB) exceeds one facet → the family MUST
  split across facets (Raw / Typed / Build / …), exactly as the handoff's size risk predicted.
- **Remaining measurement:** run `elm-cem split` + `measure-docs.mjs` with a `packages.json` adapted
  from the 16-element version to 109 elements, to confirm each *split* facet lands ≤700 KB (or needs
  finer slicing). Not yet done — the v1 packages.json is keyed to the 16-el facet structure.

## Collisions — full HTML surfaces names the 16-el v1 never hit (NEW finding)

| element | collides with | fix |
|---|---|---|
| `<main>` | Elm's special `main` (compiler treats top-level `main` as program entry; `--docs` rejects) | generator must escape reserved/special idents (`main_`), or manifest-gen renames the raw fn |
| `<style>` | `style` global attribute (barrel re-exports both as `style`) — CONFIRMED duplicate in `Markup.elm` | generator barrel must disambiguate element-ctor vs attr-setter names |
| `<title>`, `<slot>` | `title`/`slot` global attrs (element∩global) — dropped defensively to reach a clean PASS | same as style |

These are small, legitimate generator hardening items (reserved-word + barrel collision handling),
NOT a manifest-data problem. They are the reason full coverage is "one small generator tweak" from
zero-touch, not literally zero-touch. Excluding these 4, the other 109 elements pass cleanly.

## Files
- `gen.mjs` → `out/manifest.json` + `out/reports.json` (rerun to regenerate)
- `pipeline-proof.mjs` → runs generator + `--docs` on any manifest
- `src/{whatwg,typing,build}.mjs` — the tool; `data/whatwg-attributes.json` — cached spec table (offline-repeatable)
- `out/manifest-clean.json` — the 109-element PASS manifest; `out/size.json` — size numbers
- `PHASE-0-FINDINGS.md` — source spike + schema lock

## Recommended next steps (not blocking the decision)
1. **Collision handling** in the generator (reserved-word escape + barrel disambiguation) → restores the full 113.
2. **Per-facet split + size measurement** (adapt packages.json) → the last size number.
3. **Enum recovery polish**: `referrerpolicy`, `target` keyword hints (small typed-ratio gains).
4. **Real MDN prose**: 97/113 element summaries + 119/386 attr descriptions are generic fallbacks
   (provenance tracked in reports.prose: elemMdn 16, attrWhatwg 297). Scrape MDN for the rest before a real v1.

*Historical record of the markup-prototype complete-HTML-coverage milestone (2026-07-13). Current architecture = HtmlIr IR + phantom generator; the referenced markup/ config/\*.json files and the three dev harnesses (pipeline-proof.mjs / composition-test.mjs / size-measure.mjs) were deleted in the elm-phantom pass 1 refactor. The native-manifest-gen/ tooling (gen.mjs, phantom-native.mjs) and the data/ tables survive and are current infrastructure.*

# markup — Complete HTML Coverage (BUILT + VERIFIED, 2026-07-13)

Autonomous build from `planning/execution/2026-07-12-markup-full-coverage-handoff.md`, extended to
complete coverage at Jack's direction. **Every non-obsolete tag, every attribute (element-specific +
global + ARIA + event handlers), and full closed-structural composition** — generated through the
elm-cem pipeline, compiling, passing the `elm make --docs` publish gate, and split into size-gated facets.

## Final numbers

| dimension | value |
|---|---|
| **Elements** | **113** live (29 obsolete excluded) |
| **Attributes** | **468** total — 386 element-scoped + 82 universal (30 globals + 52 ARIA). Event handlers OMITTED: elm/virtual-dom neutralizes any `on*` attribute name, so String event content-attrs are inert in Elm; typed `msg`-handlers already exist per-component (`<Lib>.Html.Shared`, `onClick`). |
| **Composition families** | **21** closed-structural (table/tr/thead/tbody/tfoot/colgroup, ul/ol/menu, dl, select/optgroup/datalist, audio/video/picture, details/figure/fieldset/ruby/map + html) |
| **Emitted Elm modules** | **504** |
| **Prose** | 113/113 elements + 416/416 attrs — **zero generic fallbacks** |
| **Generator changes** | reserved-word escape (`main`→`main_`) + barrel element/attr disambiguation (`style`→`attrStyle`, `title`→`attrTitle`) + type-aware universal re-export |

## Verification (all green)

1. **Pipeline proof** (`node pipeline-proof.mjs`): 504 modules generate → compile → `elm make --docs` **PASS**.
2. **Composition protection** (`node composition-test.mjs`) **PASS** — two-layer, same design as v1:
   - Type layer *guides*: valid nested `table > tbody > tr > td` compiles; an invalid child with no
     setter (`td` in `table`, `p` in `tr`, `li` in `select`) is a compile error.
   - Review layer *enforces*: generated Facts carry correct `slotKinds` for all 21 families (e.g.
     `table→[caption,colgroup,thead,tbody,tfoot,tr]`, `tr→[th,td]`, `select→[option,optgroup,hr,div,button]`)
     — the data the (independently unit-tested) `Cem.ValidSlotKind` rule enforces.
3. **Size gate** (`node size-measure.mjs`) — **ALL facets pass ≤700,000 B** with headroom:
   markup-core 56,835 · markup-raw 192,640 · markup-html 219,890 · **markup-build 345,064 (max, 49.3%)** · markup 326,907.
   No finer slicing needed.
4. **elm-cem suite** (`npm test`): **361 passed / 0 failed** — compile-gate + brand gates + atom gates
   + split gates intact (m3e generation not regressed by the shared generator/runtime changes).
5. **Format** (`npm run format -- --validate`): clean.

## Typing (honest)

- Element-scoped attrs: **147/386 = 38.1%** get a precise Elm type (enum 54 / bool 43 / int 39 / float 11).
  The rest are String **by nature** (url/idref/token-lists/mime/text — String in `elm/html` too) or
  belong to deprecated attrs gone from the current spec. Enum keyword sets are extracted from the WHATWG
  Value column + recovery overlay (referrerpolicy/sandbox/fetchpriority/…), spot-checked vs spec.
- Universal attrs typed: globals — bool→Bool, int→Int, string→String, **enums→String-with-doc**
  (a deliberate simplification for universal globals; `dir` flagged as a candidate for a real type).
  ARIA — all String (ARIA values serialize as strings; faithful). Events — String content-attr form.

## Deliberate boundaries / FLAG-TO-JACK

- **Category nesting** (flow vs phrasing enforcement across generic containers) is NOT modeled — the ~90
  category containers stay `arbitrary`. Faking a phrasing/flow kind-lattice for all of HTML is a design
  decision, not a mechanical one. Closed structural families get real protection; this is the boundary.
- **Event handlers as `String`** content attributes are faithful-to-HTML but not idiomatic Elm. The
  typed `msg`-producing handlers already exist per-component (`<Lib>.Html.Shared`, camelCase `onClick`);
  the universal setters are lowercase (`onclick`) and don't collide. Decide whether to add a typed
  universal `msg`-handler surface.
- **Universal enum globals as String-with-doc** (not real Elm unions) — revisit for high-value ones (`dir`).
- **Editorial tier/atom/accessibility config** (link-requires-text, label↔control, img alt, the text/
  link/label/icon atoms) stays hand-authored in `config/slots.json`; the generated
  `config/slots-structural.json` composes with it (deep-merged) and only supplies STRUCTURAL slots.
- **ARIA/attr prose provenance**: 48 attr descriptions + 51 ARIA one-liners are agent-authored
  (spec-grounded), not machine-extracted; the rest are WHATWG/MDN.

## The tool (regenerable infrastructure)

`manifest-gen/` — `node gen.mjs` emits `out/manifest.json` (113 CEM declarations), `out/reports.json`,
`out/universal-attrs.json` (the typed universal surface). `src/{whatwg,typing,enums,aria,events,prose,
composition,config,build}.mjs`. Sources cached in `data/` (offline-repeatable). Config overlay:
`markup/config/slots-structural.json`. Harnesses: `pipeline-proof.mjs`, `composition-test.mjs`, `size-measure.mjs`.

Generator/runtime changes live in `elm-cem/codegen/` (Naming/Barrel/Bottom/Middle/Config/Top/Facts) and
`markup/src/Markup/{Attributes,Aria,Events}.elm` (+ Raw variants) — the hand-written universal runtime modules.

## Remaining (optional polish, not blocking)
- Real Elm types for high-value universal enum globals (`dir`, `contenteditable`).
- Typed universal `msg`-handler event surface (if desired over String content-attrs).
- Richer types for a few recoverable element-attr enums; MDN prose for the agent-authored descriptions.
- Wire `manifest-gen` + `slots-structural.json` into the canonical regen path if this ships as v1.

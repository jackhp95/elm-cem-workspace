---
name: markup-full-coverage-prototype
description: markup COMPLETE HTML coverage BUILT + verified — 113 tags, 557 attrs, 21 composition families, through elm-cem, all gates green
metadata: 
  node_type: memory
  type: project
  originSessionId: c349fc38-e8a3-45a9-a7ee-1730581afc3d
---

**COMPLETE COVERAGE BUILT + VERIFIED 2026-07-13** (Jack asked for everything, autonomously). Full
report: `elm-cem/markup/manifest-gen/COMPLETE-COVERAGE.md`. Final: 113 live elements, 557 attributes
(386 element-scoped + 171 universal = 30 globals + 52 ARIA + 89 event handlers), 21 closed-structural
composition families, 504 modules. All gates green: pipeline-proof PASS, composition-test PASS
(type guides + Cem.ValidSlotKind review enforces via correct slotKinds Facts), per-facet size ALL
≤700KB (max markup-build 345KB/49%), npm test 361/0, format clean. Prose zero-generics (113/113,
416/416). Generator changes: reserved-word escape (main→main_) + barrel attr-disambiguation
(style→attrStyle, title→attrTitle). Built by 4 subagents (WA generator hardening, WB attr data,
WC composition config, WD universal-attr runtime) + lead integration/verification. FLAG-TO-JACK:
category-nesting NOT modeled (deliberate boundary); events as String content-attrs (msg-handler
alternative exists per-component); universal enum globals as String-with-doc (revisit `dir`);
editorial tier/atom config stays hand-authored, composes with generated slots-structural.json.

--- ORIGINAL PROTOTYPE (Phases 0-4, superseded by the complete build above) ---

The markup full-HTML-coverage manifest-gen prototype (handoff:
`planning/execution/2026-07-12-markup-full-coverage-handoff.md`) was executed 2026-07-13. Tool at
`elm-cem/markup/manifest-gen/` (`gen.mjs`, `pipeline-proof.mjs`, `src/{whatwg,typing,build}.mjs`);
findings in `manifest-gen/RESULTS.md` + `PHASE-0-FINDINGS.md`.

Key outcomes:
- **Sources decided empirically:** @webref/elements = existence + obsolete; @mdn/browser-compat-data =
  attr membership + deprecation + `input[type]` enum via `type_*`; WHATWG attributes index (cached in
  `data/whatwg-attributes.json`) = value types + inline enum keyword sets. MDN prose from
  `elm-m3e/config/native-mdn.json` (only covers the 16 v1 els).
- **Load-bearing claim VERIFIED:** full-coverage CEM manifest needs ZERO generator changes — enums flow
  via `codegen/Attr.elm:classifyText` (`type.text` union string → closed Value vocabulary). 109/113
  elements generate → plain-compile (0 fails) → pass `elm make --docs`.
- **Collisions (NEW):** `<main>` collides with Elm's special `main`; `<style>`/`<title>`/`<slot>`
  collide with same-named global attrs in the barrel. The 16-el v1 never hit these. Needs small
  generator hardening (reserved-word escape + barrel disambiguation), then full 113 works.
- **Typed yield:** live surface 46.4% precise-typed (enum/bool/int/float); rest are String-by-nature
  (url/idref/tokens/mime). Deprecated attrs mostly untyped because gone from current spec (correct).
- **Size:** 466 modules, ~857 KB whole-package docs → EXCEEDS one 700 KB facet → multi-facet split
  mandatory. Per-facet measurement (adapt `packages.json` 16→109 els, run `elm-cem split` +
  `measure-docs.mjs`) is the one remaining Phase 4 step.
- **Phase 5 = Jack's decision:** ship full coverage as v1, or curated subset now + full as v2.

Related: [[elm-m3e-cross-cem-branding]], [[elm-cem-repo-separation]].

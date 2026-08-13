---
name: elm-m3e-cross-cem-branding
description: "Cross-CEM shared-runtime + kind-branding: COMPLETE + re-squashed (2026-07-12). Repos are single-init, Stage-F publish is all that remains (Jack)."
metadata: 
  node_type: memory
  type: project
  originSessionId: ebbca701-1260-46fd-908a-c1cf62725fe9
---

## Status (2026-07-12): COMPLETE — WS0-WS8 + convergence + RE-SQUASH all done. Ready for Stage F (Jack).

- Public main = SINGLE INIT commit per repo (tree-identical to verified pre-squash state, gates green):
  **elm-cem `58377d5`** (355 tests) · **elm-review-cem `234c54f`** (179) · **elm-m3e `b26ca1a`** (build-shape pass).
- Full cross-CEM dev history preserved PRIVATE: `<repo>-archive` branch `pre-squash/cross-cem-2026-07-12`
  (+ older `main` from the 2026-07-11 first squash). Archives are GitHub-archived (read-only); to push, use
  the CF-02 wrap (`gh api PATCH archived=false` → push → `archived=true`), HTTPS not SSH (CF-01).
- ONLY Stage F remains (Jack + together): finalize package names (placeholders), create real `jackhp95/<pkg>`
  mirror repos, npm OIDC, publish 15 packages in topo order per `planning/execution/release-runbook.md`.
- Full execution record: `planning/execution/cross-cem-{state,worklog}.md` + `frictions-log.md` (CF-01..CF-17).
- FLAG-TO-JACK taste-calls (see cross-cem-state.md): markup v1=16 HTML elements (expand?); Seam helpers
  `Kit.text/link/label/icon` now return `Markup.Kind.Shared`; 5 stale m3e config keys never applied (curation call).

Remaining: WS8 planning docs (this session), re-squash all 3 repos, Stage F with Jack.

## End-state model (what actually landed)

**Runtime:** extracted from per-library copy into `jackhp95/markup-core` (elm-cem/markup/).
14 modules: Element/Node/Html.Attr/Token/Kind/Atoms/Aria/Attributes. elm-m3e uses
`config/runtime.json` `{"_runtime":{"owns":false}}`; imports all flip to `Markup.*`;
12 runtime modules dropped from src/; exposed-modules 619→611.

**Kind branding:** `M3e.Kind.Brand` (opaque, nullary) in every kind row of every
facet (standard/raw/html/record/build). `Markup.Kind.Shared` for atoms. `Supported`
GONE from kind rows (still on value/attr capability rows). Closed slots: generated
markup components AND M3e curated slots use closed records.

**Two tiers (config):**
- `"tier": "private"` (DEFAULT): `M3e.Kind.Brand` in kind row. Segregated.
- `"tier": {"role": "text|link|label|icon"}`: `Markup.Kind.Shared` in kind row. Cross-library.

**Atom vocabulary v1:** text, link, label, icon. Constructors in `Markup.Atoms`.
Accessibility enforced: link requires ≥1 content child (WCAG 2.4.4); icon = decorative
OR labeled (WCAG 1.1.1); label closed to `{text:Shared, icon:Shared}`.
Deferred: heading, image.

**Seam atoms change (FLAG TO JACK):** `Kit.text/link/label/icon` now return
`Markup.Kind.Shared` (was `M3e.Kind.Brand`). Deliberate atom-model refinement; only
these 4 helpers changed. Confirm this is desired.

**M3e tier curation (WS5):** 91 slots opened to shared atoms across 43 components
(36 shared:text, 53 shared:icon, 2 shared:link). Containers/mixed stay private.
`unionSlotKinds` conflict rule: shared: wins when Brand/Shared conflict on same field
(barrel-scoped only; per-component modules keep their exact marker).

**Seam model (WS6):** `recast` = general loud crossing; `M3e.Coerce.*` = config-blessed
named coercions. `_coerce` in config/slots.json. WS6 emitted `M3e.Coerce.asButton`
(`Chip→button` crossing, typed, greppable). `NoSeamOutsideAllowedModules` now takes
`{seamModules, allowedModules}` config record (not hardcoded). 179/179 tests.

**Generator neutrality (WS3/WS8):** Action roster → `_actions` in config/slots.json
(data-driven). Native attr table → markup/native-attrs.json (injected by CLI). 57
doc-comment illustrative M3e examples remain in codegen/ — deferred (CF-09); these
are comments, not data. M3e.Action byte-identical after re-data-driving.

**Markup surface (WS4):** 16 HTML elements in markup/manifest.json. Facets: core
(WS1) + standard + raw + html + build (record skipped — no required-singular HTML
slots). markup-core docs.json = 14,218B; markup standard = 132,168B (18% of 700KB gate).
Accessible atoms: see above.

**Facet-family packaging (WS7, CX11/CX12):**
- Markup family: 6 packages (markup-core/raw/html/markup/markup-build/markup-review-facts).
  No markup-record (skipped).
- m3e family: 7 packages (elm-m3e-core/raw/html/elm-m3e/elm-m3e-record/-build/-review-facts).
- ALL names are PLACEHOLDERS (Jack decides before Stage F).
- REAL measured size: m3e standard = **664,575B** (700KB soft gate = +35KB headroom,
  768KB hard cap = +103KB headroom). Measured by measure-docs.mjs (wired into npm test).
- Barrel doc-slimming (WS7): M3e barrel docs 104,760→45,100B (-59,660B/57%).
- Splitter: `elm-cem split` with `packages.json`. Gates: totality/disjoint/DAG/isolation/docs-size.
- Mirror script: `scripts/mirror-release.mjs`. `--rehearse` → `/tmp/mirror-rehearsal/`.
  Hard-exits without --rehearse. All 7 m3e + 6 markup packages rehearsed OK.
- Summary ≤79B constraint enforced (CF-15).

**Stale config keys (FLAG TO JACK):** `"Chips"`, `"Progress"`, `"ProgressIndicator"`,
`"Search"`, `"//"` in config/slots.json never matched any component (key mismatch).
Their config NEVER applied. Review intent: fixing keys APPLIES the config → changes
those slots. Jack's curation call.

## Key CF frictions (for future reference)

- CF-01: SSH dead → HTTPS everywhere; CF-02: archive repos are GH-archived → unarchive/push/re-archive
- CF-04: `_runtime` sentinel is top-level in config JSON (not nested)
- CF-06: elm-m3e/elm-cem/ is a stale clone; use canon CLI at ~/Documents/code/elm-cem/
- CF-07: unknown atom roles are now warned (not silent)
- CF-11: config key must match component name WITHOUT module prefix (strips to "Button" not "Markup.Button")
- CF-15: elm publish caps summary at 79 UTF-8 bytes; watch multi-byte chars
- CF-16: docs-size gate must ACTUALLY run and fail-loud; verify "productized" claims
- CF-17: elm-m3e-core is minimal (M3e.Kind + M3e.Token) since WS1; real sizes differ from WS0 estimates

## FLAG TO JACK (open taste-calls at end)

1. Atom helper kind change: Kit.text/link/label/icon now return `Markup.Kind.Shared` (was Brand). OK?
2. Stale config keys never matched — fixing them applies config, changing slots. Review intent.
3. Package names (placeholders everywhere; rename = cheap pre-Stage-F).
4. markup v1 = 16 HTML elements. Missing: ol, headings (h1-h6), img. Ship v1 or expand?
5. CF-09: 57 doc-comment M3e examples in codegen/ — genericize to `<Lib>.*` or allow-list?

## Topological publish order (Stage F)

markup-core → markup-raw → markup-html → markup(std) → markup-build → elm-cem(npm) →
elm-review-cem → markup-review-facts → elm-m3e-core → elm-m3e-raw → elm-m3e-html →
elm-m3e(std) → elm-m3e-record → elm-m3e-build → elm-m3e-review-facts

Each elm publish waits for registry visibility of deps. Full step-by-step: execution/release-runbook.md.

Related: [[release-planning-collection]], [[elm-cem-repo-separation]], [[elm-cem-codegen-overhaul]]

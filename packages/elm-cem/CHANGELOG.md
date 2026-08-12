# Changelog

All notable changes to elm-cem are recorded here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## Stability policy

elm-cem has **two public surfaces**, and a change to either is a breaking change:

1. **The CLI + exposed Elm modules** — the flags (`--flags-from` / `--config-from` /
   `--output`) and the exposed modules `Cem` (the CEM data model + `manifestDecoder`)
   and `Generate` (the pipeline entry point). Record-alias field changes and signature
   changes here break downstream consumers.
2. **The generated output** — the emitted module names, function names, and
   phantom-row field names are a contract for the downstream generated-bindings
   packages. A rename or type change to generated output is a breaking change even
   though it lives in another repo.

The emitted module set and key generated signatures are pinned by the phantom
gate (`tests/phantom/`) and golden tests, so a change to the generated public
surface shows up as a reviewed test diff rather than a silent break.

## Unreleased

The first public release cuts the **phantom architecture**. The generator now emits one
phantom-typed **brand** per library, and the legacy multi-form pipeline has been retired.

### Added — the phantom pipeline (opt-in via `_phantom: true`)
Passing a config with top-level `"_phantom": true` selects the phantom pipeline, which
emits a single brand as a fixed module shape driven by data:

- **`<Lib>`** — the general surface: every component constructor in the `elm/html` call
  shape, one import.
- **`<Lib>.<Component>`** — the strict per-component surface: `view`, `el` (when
  required content/attrs are configured), the shared `build`/`Builder` pipe-builder,
  narrowed value setters, and `with*` pipe setters.
- **`<Lib>.Attributes` / `<Lib>.Events` / `<Lib>.Values` / `<Lib>.Kind`** — the shared
  vocabulary: canonical open attribute producers, capability-gated events (+ `delegate`),
  the enum token vocabulary minted once, and the library's private phantom markers.
- **`<Lib>.Review.Facts`** — generated metadata for the elm-review-cem rules.
- Optional axes (`<Lib>.Coerce`, `<Lib>.Aria`, `<Lib>.Action`) appear only when the
  relevant config is present.

The two surfaces are **projections of one brand model**, so the terse general surface and
the strict per-component surface can never drift.

### Added — composable config primitives
The config vocabulary is a small set of orthogonal primitives — `kind`, `admits`,
`parents`, `_sets`, `_atoms`, `require`, `_coerce`, `_renames` (plus the carried-over
per-element curation keys). A brand is *data* in this vocabulary; each module is a
projection of that data. The generator validates the config loudly (unknown kind/set
references, the shared-admittedBy R1 discipline, identifier collisions). See
[`docs/config-primitives.md`](docs/config-primitives.md).

### Added — shared `build` capability + portmanteau setters
Every component exposes a shared `build`/`Builder` pipe-builder with write-once
capability markers (`Available`/`Used`), plus `with<Attr>` portmanteau pipe setters
alongside the bare setters, both projected from the same attribute data.

### Added — generated dependencies (HTML IR + elm-cem-facts)
Generated modules import the published `HtmlIr.*` IR package (no runtime source is copied
into the output directory) and the `Cem.Facts` schema from **elm-cem-facts** (which
`<Lib>.Review.Facts` populates). See [`docs/packaging-decay.md`](docs/packaging-decay.md)
for the vendoring→published-package migration a downstream brand goes through.

### Added — CEM input documentation & analyzer configs
Documented the CEM input story end-to-end (libraries that ship a manifest vs. producing
one with `@custom-elements-manifest/analyzer`) and shipped ready-made analyzer configs
under [`cem-configs/`](cem-configs/) for Carbon, Ionic, and Spectrum.

### Added — identifier-collision policy (`_renames`)
Cross-brand attribute/element/event/token rename resolution (K1–K7) so the same manifest
concept renders consistently, with a `_renames` escape hatch that fails loud on an
unknown source.

### Changed — legacy pipeline retired
The previous multi-form generator (the raw / html / record / build module quintet and the
runtime-injection pass) has been removed. Generated brands now **import** the shared IR
rather than having runtime source injected into the output. Running without
`"_phantom": true` reports the retirement and stops.

### Removed
Retired the runtime-injection pass (`_runtime` / `injectRuntime`), the multi-namespace
config keys of the old pipeline, and the separate raw/html surface layers.

## Historical notes (pre-phantom, kept for provenance)

### Added — `styleList` global + required accessible names (phantom)
The phantom pipeline now surfaces one extra global attribute setter on every brand:
`styleList : List (String, String) -> Attr` (a typed companion to `style`, sharing
`style`'s capability row). The per-component `requiredAttrs` (kebab manifest names,
e.g. `aria-label`) now also thread into the `el`/`build` required record as `String`
fields that are always stamped (emitted inline as `Ir.attribute "<name>"`, so the
enforcement is self-contained and does not depend on the attr being exposed as a
setter) — so an icon-only control (FAB, IconButton) can't be constructed without an
accessible name (a11y by construction). Previously `requiredAttrs` only fed the review
facts. Note: `aria-label` is a global HTML attribute already provided by the shared
native IR's `Aria.label` axis, so it is deliberately NOT re-exposed as a per-brand
global setter.

### Added — config-declared semantic seams (`_seams`)
A top-level `_seams` block declares userland semantic seams (e.g. `text`/`link`/
`label`) by kind. For each, the generator emits a public contract type in `<Lib>.Seam`
plus a phantom re-stamping stamper in `<Lib>.Seam.Internal` (`Element any msg ->
Contract s msg`). Producers of these kinds live in userland (the package ships the
seam *mechanism*, not the producers) — so `text`/`link`/`label` are no longer
library-defined, and the loose `<Lib>.Element.text` / dead `element` slot kind are
retired.

### Added — typed native HTML IR (`_native`)
A top-level `_native` block (`{ emit: [tags], semantics: { tag: kind } }`) emits
`<Lib>.Native.*` constructors as public typed facades over the `*.Internal` crossings.
Semantic tags stamp their kind (`a`→link, `label`→label); others return `Element any`.
A built-in, config-adjustable **attribute→element table** makes native attr setters
element-constrained — `href` only type-checks on `a`/`area`, `for` on `label`/`output`,
etc. (a wrong pairing like `Native.div [ Native.href … ]` is a compile error).

### Added — richer event-payload decoders (`events`, R9)
A per-component `events` descriptor emits typed convenience listeners from
`event.detail.<field>` extraction, a generic top-level `path`, and a Date→ISO helper
(plus the existing `target.value`/`checked`/`selected` and no-payload cases). Loud on
an unknown descriptor.

### Added — static-attribute injection (`staticAttrs`, R-EXTRA)
A per-component `staticAttrs: { name: value }` stamps fixed host attributes (e.g.
`role="group"` on chip-sets) ahead of caller attrs, so callers can still override.

### Added — declarative typed-argument overrides (`attrTypes`, R12)
A per-component `attrTypes` override coerces a generated argument's type: scalar
(`Int`/`Float`/`Bool`/`String`), list-enum, or a forced token→value map — so an
attribute the CEM under-describes (e.g. a numeric weight, a tri-state `boolean|"auto"`)
becomes a precise Elm type without hand-editing generated code.

### Changed — opaque-IR `*.Internal` boundary
The runtime IR modules (`Node`/`Element`/`Content`/…) split into a public module
(types, `map`/`fold`, out-bound `toNode`/`toHtml`/`toAttribute`) plus a `*.Internal`
module holding the raw↔phantom crossings (constructors, `fromNode`, slot minting).
Userland reaches crossings only through a single allow-listed seam module. The whole
mechanism is library-agnostic — every m3e specific lives in the consumer's config.

### Added — form-field `for`/`id` auto-wiring (`idWiring` config)
A per-component config key `idWiring: { control, label }` makes the generator wire
a structural label↔control association for sibling-slot form components (e.g.
`m3e-form-field`, which performs no association itself). When present, the
control-slot setter gains a required `String` id and stamps `id="<id>"`, and the
label-slot setter takes the same id and stamps `for="<id>"`, both via the new
runtime primitive `<Lib>.Content.Internal.slotWithAttr`. Absent `idWiring` ⇒ no
change (wrapping components like RadioButton get implicit association for free and
carry no id). Library-agnostic: which component/slots wire is a pure config
lookup, decoded loud on a partial descriptor. Pinned by `GoldenTest`'s `x-field`
fixture.

### Fixed — publishable docs (`elm make --docs`)
Regenerated output now builds `docs.json` with zero `-- NO DOCS` / `-- DOCS
MISTAKE` errors across every emitted module, so a generated package can build
docs and be published. Three gaps closed:
- **`<Lib>.Value` re-exports.** The generated `<Lib>.Value` aggregator listed
  `Value`, `Supported`, and `toString` in its `@docs` block and exposed them, but
  emitted their re-export definitions with no doc comment, so
  `elm make --docs=docs.json` failed with `-- NO DOCS` on `src/<Lib>/Value.elm`.
  Each re-export now carries a short doc comment pointing at `<Lib>.Value.Core`,
  mirroring the documented token functions beside them.
- **`<Lib>` barrel constructors.** The one-import barrel re-exposes every
  component under its noun (`button`, `tree`, …); these `@docs`-listed re-binds
  had no doc comment. `generateBarrelModule`'s `rebind` now attaches a synthesized
  doc comment referencing the per-component module.
- **`<Lib>.Content` runtime module.** The hand-written runtime `Content` module was
  missing an `@docs` line, and its `Content` type and `toNode` had no doc comment.
  Added the `@docs` list plus doc comments so the exposed API validates.

Regression-guarded in `GoldenTest` (Value re-exports + barrel constructor doc).

### Fixed — generator correctness / type safety
- **Attribute vs. property emission.** Bool/number attributes with no backing
  reactive property (`fieldName`) now emit a real HTML attribute under the kebab
  name instead of a guessed camelCase `property`, which was a silent no-op for
  hyphenated and `aria-*` attributes (#33). Attributes with an explicit
  `fieldName` still set that property.
- **Enum literals with spaces** are no longer dropped; unquoted type-name union
  members are rejected instead of leaking through as fake values (#16).
- **Single string-literal unions** now classify as one-value enums rather than
  degrading to `String` (#17).
- **Non-expressible enum members** are dropped individually instead of collapsing
  the whole enum to omitted (#22).
- **Conflicting shared attributes.** An attribute whose non-enum type differs
  across components is no longer merged into the shared vocab under one arbitrary
  type; it stays per-component and the generator warns (#23).
- **CEM decoder:** a superclass with no `module` now decodes (module is optional
  per the schema) instead of silently dropping the superclass (#29).

### Fixed — runtime
- `Node.addAttr` promotes a `Raw` node to a `<span>` instead of silently dropping
  the attribute (e.g. `slot=`) (#21).
- `Content` is now opaque, so only the generated setters can mint slot-tagged
  content with a valid row (#19).

### Fixed — CLI
- Temp CEM files are cleaned up instead of leaking into the OS temp dir (#18).
- Runs the locally-installed `elm-codegen` rather than bare `npx` (which could
  resolve or download an arbitrary version) (#32).
- Recognises multiline / commented `.d.ts` string-literal unions when inlining
  aliases (#26).
- `syncExposedModules` no-ops when the exposed set is unchanged and preserves the
  existing indentation (#25).

### Changed
- `deduplicateBy` is now O(n log n) via a `Set` (#27).
- Removed dead code: the unreachable `Emit` module and its `Naming`-only helpers
  (#12), and `generateEventHelper` / `generateSlotHelper` /
  `Docs.generateStructuredDocs` (#13).

### Documentation
- Corrected the generated module namespace in the README (it is `<Lib>.*`, not
  `Cem.<Lib>.*`) (#14).
- Documented `--config-from` and clarified that `cem-configs/` are analyzer
  configs (#24).
- Documented `Element.map`'s eager-render consequence (#20).

### Tests
- Removed `IntegrationTest`, which tested `Html.node` stubs rather than generated
  code (#15).
- Removed the stale, unwired `elm-verify-examples` config (#31).
- Pinned the warn-and-proceed policy for an unknown CEM schema (#28).

## 0.3.0

- Baseline extracted from the archived `elm-custom-elements-manifest` monorepo.

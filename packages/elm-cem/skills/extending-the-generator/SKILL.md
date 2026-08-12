---
name: extending-the-generator
description: >-
  Guides maintainer changes to the elm-cem generator itself — the codegen/ Elm app and
  the golden-test contract. Use when maintaining elm-cem (working inside this repo) and
  modifying the generator: adding a per-component config key, changing what a
  Generate/*.elm emitter produces, understanding the emit-family architecture, or
  interpreting a GoldenTest diff. Maps which Generate/*.elm owns which output shape and
  states the core rule: a golden diff that renames/retypes existing output is a BREAKING
  change for downstream consumers. Not for consumer-side config authoring (see
  configuring-cem-overrides) or cutting a release (see releasing-elm-cem).
disable-model-invocation: true
---

# Extending the elm-cem generator

Maintainer-facing. Ground every change in three invariants:

1. **Stay library-agnostic.** New behavior is a **config key**, never a hard-coded
   component or library name. A feature that only makes sense for one design system
   belongs in the consumer's config.
2. **A golden diff to existing output is a breaking change** for downstream packages
   (their compile breaks). Additive is cheap; churn is breaking until proven otherwise.
3. **Fail loud on invalid config.** A present-but-malformed key must error the build,
   never silently collapse to a default.

## Repo shape

- `bin/elm-cem.js` — the npm CLI: reads the CEM + `--config-from`, runs the four
  preprocessing passes, drives `elm-codegen`, syncs `exposed-modules`.
- `codegen/` — a standalone elm-codegen Elm **application**. `Generate.elm` is the entry
  (`generateFromManifest`); `Cem.elm` decodes the manifest; `Attr.elm` classifies
  attributes; `Naming.elm` handles name derivation; the emit families live in
  `codegen/Generate/*.elm`.
- `data/` — bundled lookup tables (e.g. `native-attrs.json`) injected into the CEM
  before codegen runs. Library-agnostic; libraries may override via `--config-from`.
- `native-manifest-gen/` — the WHATWG-sourced native HTML manifest generator
  (`phantom-native.mjs`). Produces the tables under `data/`.
- `tests/` — elm-test-rs suites incl. `GoldenTest.elm` (pins the public surface) plus the
  two Node gates (`compile-gate.mjs`, `exclude-cli.test.mjs`).

## Emit-family architecture map

Each `Generate/*.elm` owns one output shape. To change an output, edit its owner:

| Module | Owns |
| --- | --- |
| `Generate.elm` | entry point; orchestrates every family via `generateFromManifest` |
| `Generate/Top.elm` | the **top layer** (`<Lib>.<Component>`): strict, phantom-typed `view` + setters; variant-group tops |
| `Generate/Middle.elm` | the **Html layer** (`<Lib>.Html.<Component>`): held-Attr IR, eager component |
| `Generate/Bottom.elm` | the **raw bottom-layer** setters (`ABool`/`ANumber`/`AInt`); shared bottom modules |
| `Generate/Barrel.elm` | the `<Lib>` **barrel**: re-exposes every component + shared vocabulary |
| `Generate/Value.elm` | the `<Lib>.Token` **enum token** vocabulary |
| `Generate/Action.elm` | the `<Lib>.Action` capability-typed behavioural value |
| `Generate/Event.elm` | event handler names + typed event decoders |
| `Generate/Native.elm` | native/HTML element constructors (`_native` emit) |
| `Generate/Seam.elm` | `<Lib>.Seam` contract types (`_seams`) |
| `Generate/Slots.elm` | slot setter names, base-slot resolution |
| `Generate/BuildForm.elm`, `Generate/RecordForm.elm` | the build/record `view` form shapes |
| `Generate/SharedAttrs.elm` | component → module-name derivation (the shared-attr vocabulary itself lives in `Generate/Phantom/Model.elm`) |
| `Generate/Normalize.elm` | CEM normalization: tag merge, nameless-member drop, `applyTypeOverrides`, `applySyntheticAttrs` |
| `Generate/Config.elm` | the **single `_config`/`_runtime` decoder** and `shapesFor` |
| `Generate/Types.elm` | shared generator types (`Config`, `Shape`, `SlotKinds`, …) |
| `Generate/Facts.elm` | the `Review/Facts` module (external elm-review-cem integration) |
| `Generate/Warnings.elm` | the `⚠️`/`ℹ️` diagnostics |

## IR import model (elm-phantom pass 1)

The `injectRuntime` / `_runtime` / `ownsRuntime` mechanism was **retired** in the
elm-phantom refactor. Generated brands now **import** the published
`elm-html-intermediate-representation` package (`HtmlIr.*`) as a peer Elm dependency;
no runtime source is injected into the output directory. There is no `runtime/` dir,
no `markup/src/Markup/` dir, no `Acme` placeholder rewrite, and no `markup-core`
transitive dependency path. The `_runtime` CEM key is a no-op stub in the current
CLI (kept to avoid a loud parse error on stale configs).

## The golden-test contract

`tests/src/GoldenTest.elm` pins the generated module set and key signatures. `npm test`
runs it plus the two Node gates. When you get a golden failure, **categorize before you
re-pin**:

- **Expected (accept + re-pin):** you deliberately added a component / attribute / slot /
  config key, so a **new** module / setter / phantom-row field appears. Additive, renames
  nothing. Update the golden expectation and note it in `CHANGELOG.md` under _Unreleased_.
- **Red flag (stop):** an **existing** module / function / phantom-row field is
  **renamed, retyped, or disappears**. That silently breaks every downstream consumer's
  compile. If it wasn't the explicit point of your change, it's a regression — don't
  re-pin it away. If intentional, it's a **breaking change**: flag it loudly in the PR
  and the CHANGELOG's stability-policy section.

The two Node gates catch what the text-assertion golden can't: `compile-gate.mjs`
`elm make`s every emitted module **and** runs `elm make --docs` (the publish gate) on a
neutral fixture; `exclude-cli.test.mjs` checks `_exclude` end-to-end via the CLI.

## Adding a per-component config key — the end-to-end sites

A worked walkthrough, mirroring CONTRIBUTING's "first PR". Touch **all** of these:

1. **Decoder** — add the key to `componentDecoder` in `codegen/Generate/Config.elm`.
   Use `optStrict` (fail-loud) unless an absent-and-default-only key genuinely warrants
   the lenient `opt`. A typo in a value must fail the build.
2. **Type** — add the field to the component record in `codegen/Generate/Types.elm`.
3. **Wiring** — thread it where it takes effect: `Generate/Normalize.elm` for a
   CEM-shaping key (like `applySyntheticAttrs`), or the relevant emit family for an
   output-shaping key.
4. **Emitter** — make the owning `Generate/*.elm` render it.
5. **Test (red first)** — add a focused suite under `tests/src/` (each key has one, e.g.
   `SyntheticAttrTest.elm`, `TypeOverrideTest.elm`). Write the failing assertion first.
6. **Golden** — `npm test` will surface a `GoldenTest` diff if output changed; read it
   with the contract above, re-pin if additive.
7. **Docs** — add the key to the **CONTRIBUTING config-key inventory** (the per-component
   list) and the README/CHANGELOG. The inventory is the source of truth for the key set.

## Verify before every PR

```bash
npm test                       # elm-test-rs + compile-gate + exclude-cli
npm run format -- --validate   # codegen/ + tests/src/ are elm-format-clean (hard CI gate)
bash .github/neutrality-check.sh
node skills/check-skills.mjs    # if you touched skills/
```

---
Validated against elm-cem 1.0.0, 2026-07.

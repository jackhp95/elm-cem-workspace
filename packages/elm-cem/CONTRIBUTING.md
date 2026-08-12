# Contributing to elm-cem

Thanks for your interest! **elm-cem is a library-agnostic code generator**: it turns
a [Custom Elements Manifest](https://github.com/webcomponents/custom-elements-manifest)
(CEM) — optionally augmented by a config — into a typed Elm binding layer. It knows
nothing about any particular component library; all library-specific opinion lives in
the **consumer's config** (the override layer). Keep it that way: a feature that only
makes sense for one design system belongs in a config key, not in the generator.

## Shape of the repo

- `bin/elm-cem.js` — the npm CLI entry point (reads the CEM + `--config-from` files,
  drives elm-codegen, syncs `exposed-modules`).
- `codegen/` — a standalone [elm-codegen](https://github.com/mdgriffith/elm-codegen)
  Elm *application* (`Generate.elm`, `Cem.elm`, `Attr.elm`, …). This is the generator.
- `data/` — bundled lookup tables (e.g. `native-attrs.json`) injected into the CEM
  before codegen. Library-agnostic HTML data; libraries may override via `--config-from`.
- `native-manifest-gen/` — the WHATWG-sourced native HTML manifest generator
  (`phantom-native.mjs`); produces `data/native-attrs.json` and related tables.
  **Dev-only — not shipped in the npm package** (only its committed output, `data/`, is).
- `tests/` — `elm-test-rs` suites, incl. `GoldenTest` pinning the emitted public surface.

## Setup

```bash
npm ci                # install the CLI's Node deps
npm run setup         # elm-tooling install — fetches the pinned elm / elm-format / elm-test-rs
```

`npm run setup` (the `setup` script) installs the toolchain pinned in
`elm-tooling.json`. It is **not** a lifecycle hook — consumers who merely install
elm-cem never run it (that was a deliberate fix; a `prepare`/`postinstall` hook broke
git-URL installs). Run it once when you clone.

## Verify — run before every PR

```bash
npm test              # elm-test-rs over tests/src/*.elm (the golden + unit suites)
npm run format        # elm-format tests/src/ (hand-written Elm only)
npm run check:format  # same, --validate mode
npm run gate          # everything: check:* in parallel, then test:*
```

**elm-review is intentionally absent.** `codegen/` is the frozen generator — its Elm
source is not hand-authored and may not satisfy standard elm-review rules (it uses
generated-code patterns that trigger false positives). Adding elm-review would require
either ignoring the entire generator corpus or running it on only the five test-helper
files in `tests/src/`, neither of which provides useful signal. This is the documented
exception for elm-cem in the broader elm-cem ecosystem's release-readiness standard.

`GoldenTest` pins the generated module set and key signatures — a change to the
**generated public surface** (module/function/phantom-row names) shows up as a
reviewed golden diff. That output is a contract for downstream repos (`elm-cem-m3e`,
`elm-m3e`), so treat a golden change as a breaking change (see [CHANGELOG](CHANGELOG.md)
§ Stability policy).

### Reading a golden diff — expected change vs red flag

When `npm test` reports a `GoldenTest` failure, the diff tells you *what changed in the
generated output*. Categorize it before you accept it:

- **Expected (accept + re-pin):** you deliberately added a component, attribute, slot,
  or config key, so a **new** module / setter / phantom-row field appears. Additive
  changes that don't rename or retype anything existing are the normal case. Update the
  golden expectation, and note the addition in `CHANGELOG.md` under _Unreleased_.
- **Red flag (stop and investigate):** an **existing** module, function, or phantom-row
  field is **renamed or retyped**, or one **disappears**. That silently breaks every
  downstream consumer's compile. If it wasn't the explicit point of your change, it's a
  regression — don't re-pin it away. If it *is* intentional, it's a breaking change:
  flag it loudly in the PR and the CHANGELOG's stability-policy section.

Rule of thumb: green-field additions are cheap; churn to the existing surface is a
breaking change until proven otherwise.

## Testing a generator change end-to-end

Regenerate a real consumer and compile it:

```bash
node bin/elm-cem.js \
  --flags-from=<path>/custom-elements.json \
  --config-from=<path>/slots.json \
  --output=<path>/src
# then, in the consumer: elm make src/<Lib>.elm --output=/dev/null
```

## Your first PR — a worked walkthrough

A good starter contribution is extending an existing **config key** with a golden case.
Here's the loop, end to end:

1. **Pick a config key** to exercise — say `syntheticAttrs` (injects a settable
   attribute the CEM doesn't declare). Find its decoder in `Generate/Config.elm` and
   its wiring in `Generate/Normalize.elm` (`applySyntheticAttrs`).
2. **Find its test.** Each key has a focused suite under `tests/src/` — e.g.
   `SyntheticAttrTest.elm`. Read it to see the fixture-manifest → config → expected-Elm
   shape.
3. **Add a golden case first (red).** Write the assertion for the behaviour you want —
   e.g. a synthetic `enum`-typed attr mints the right `Token` — and run `npm test` to
   watch it fail. A failing case is the ideal repro and the spec for your change.
4. **Make it pass (green).** Implement the smallest change in the generator. Keep the
   generator library-agnostic: the behaviour must be driven by the config value, never
   by a hard-coded component or library name.
5. **Check the golden surface.** `npm test` also runs `GoldenTest`; if your change
   touched the *generated* output, you'll get a golden diff — read it with the guide
   above, re-pin if it's an expected addition, and note it in `CHANGELOG.md`.
6. **Format + verify.** `npm run format` (formats `tests/src/`), then `npm test` clean. The neutrality gate
   (`bash .github/neutrality-check.sh`) must also stay green — don't introduce a
   design-system-specific mention outside the allowlist.

## Config keys (the override layer)

The generator's behaviour is driven by config, decoded in `Generate/Config.elm` and
always **loud on invalid input**. Add new mechanisms as config keys, never as
hard-coded component names.

The output shape is driven by the **phantom config primitives** — a brand is *data* in
this vocabulary and each module is a projection of it. The authoritative catalog (with
worked examples and the emission rules) is [`docs/config-primitives.md`](docs/config-primitives.md);
the phantom pipeline itself is opt-in via top-level **`_phantom: true`**.

**Phantom primitives** — top-level `kind`/`admits`/`parents`/`_sets`/`_atoms`/`_coerce`/
`_renames` plus the carried-over per-element curation keys below. Decoded and validated
loudly in `Generate/Phantom/Model.elm` (unknown kind/set refs, the shared-admittedBy R1
discipline, identifier collisions).

**Per-component curation keys** (each under a component's entry in `_config`, see
`componentDecoder`): `slots`, `required`, `group`, `examples`, `docMeta`,
`requiredAttrs`, `attrTypes`, `idWiring`, `events`, `staticAttrs`, `syntheticAttrs`.

`syntheticAttrs` injects settable attributes that are **not in the CEM**, each
carrying a real phantom capability so it only type-checks on the component(s) it is
declared on. Keyed by the Elm-facing setter name; each value gives the stamped
`htmlName`, an optional `type` (reusing the `attrTypes` scalar/enum vocabulary,
defaulting to a presence boolean), and an optional `description`. It flows through
the same classification → capability-stamping → `Token` pipeline as a real
attribute (injected in `Generate.Normalize.applySyntheticAttrs`), so the setter,
its phantom row, and its raw emission come for free. The motivating case is
`m3e-toc-ignore`, a heading-scoped marker the `m3e-toc` component reads from heading
elements.

**Top-level reserved keys** (recognised alongside the per-component entries, each
`_`-prefixed so it can never collide with a component module name): `_phantom`, `_sets`,
`_atoms`, `_coerce`, `_renames`, `_variants`, `_exclude` — see
[`docs/config-primitives.md`](docs/config-primitives.md) and _The CLI↔codegen contract_
below.

## The CLI↔codegen contract (reserved flag keys)

`bin/elm-cem.js` and `Generate.elm` communicate through a single JSON blob — the CEM
manifest passed to elm-codegen as `--flags-from`. The CLI injects two **reserved
top-level keys** into that blob, and `Generate.elm` is the **single decoder** for both
(look for `Json.Decode.field "_config"` / `"_runtime"`):

- **`_config`** — the deep-merged override layer. `injectConfig` reads every
  `--config-from=<json>` file, deep-merges them (per component: component key, then
  each component's field object; later files override individual fields), and stores
  the result here. Absent ⇒ empty config (the manifest-agnostic path for other
  libraries); **present-but-malformed must fail loud**, never silently collapse.

Note: the `_runtime` key and `injectRuntime` pass were retired in the elm-phantom
refactor (pass 1). Generated brands now **import** the published `HtmlIr.*` IR
package as a peer dependency; no runtime source is injected into the output dir.

Inside `_config`, the generator recognises its own reserved keys alongside the
per-component entries: **`_phantom`** (opt into the phantom pipeline), the phantom
primitives **`_sets`** / **`_atoms`** / **`_coerce`** / **`_renames`**, and
**`_exclude`** (a base-class component curation list). Every reserved key is prefixed
with `_` so it can never collide with a component module name. Add a new reserved key
only in the config decoders (`Generate/Config.elm`, `Generate/Phantom/Model.elm`) — that
keeps the contract in one place.

## Reporting bugs

Open an issue with the CEM snippet (or a minimal manifest), the config used, and the
generated-vs-expected Elm. A failing `GoldenTest`-style fixture is the ideal repro.

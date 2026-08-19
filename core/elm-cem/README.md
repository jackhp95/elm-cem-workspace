# elm-cem

[![CI](https://github.com/jackhp95/elm-cem/actions/workflows/ci.yml/badge.svg)](https://github.com/jackhp95/elm-cem/actions/workflows/ci.yml)

Generate **type-safe, phantom-typed Elm bindings** from a web component library's
[Custom Elements Manifest](https://github.com/webcomponents/custom-elements-manifest)
(CEM). One repo, one function: the CEM → Elm **generator** (a Node CLI driving an
elm-codegen app).

elm-cem is **design-system agnostic**. Point it at any library that ships (or can
produce) a `custom-elements.json` — [Shoelace](https://shoelace.style),
[Carbon](https://web-components.carbondesignsystem.com),
[Spectrum](https://opensource.adobe.com/spectrum-web-components/), Ionic, and so on —
and it emits a typed Elm layer named after that library's own tag prefix. It knows
nothing about any particular component library; all library-specific opinion lives in
a consumer-supplied config.

## What it does NOT do

- It does **not** ship a component library. It generates *bindings* from a manifest;
  you still install the underlying web components yourself.
- It does **not** produce a runtime, and it does **not** copy any runtime source into
  your output directory. The generated modules import two published Elm packages (see
  [Generated dependencies](#generated-dependencies)).
- It does **not** guess semantics the manifest doesn't state — the config is where you
  add the containment/enum/ARIA refinements the CEM can't express.

## Install

```bash
npm install -g elm-cem      # global — exposes the `elm-cem` command
# or, no install:
npx elm-cem --help
```

The package declares a single bin, `elm-cem`. Inside a project you can also add it as a
dev dependency (`npm install --save-dev elm-cem`) and reach it as `npx elm-cem` or
`node_modules/.bin/elm-cem`.

> **Pre-release:** until the first tagged npm release, install from git:
> `npm install --save-dev github:jackhp95/elm-cem`.

## Prerequisites

At runtime the CLI invokes `elm-codegen run`, which compiles the generator app with the
**Elm 0.19.1 compiler**. `elm-codegen` ships as a dependency of this package; the `elm`
binary does **not** — you supply it. You need:

- **Node.js ≥ 18** (to run the CLI).
- The **`elm` 0.19.1 compiler** on your `PATH`. Any of:
  - install it globally — `npm install -g elm@latest-0.19.1`; or
  - manage it per-project with
    [elm-tooling](https://elm-tooling.github.io/elm-tooling-cli/) (this repo does exactly
    that for local development — `npm run setup`); or
  - any existing elm-codegen-capable toolchain that already has `elm` available.

If `elm` is missing, `elm-codegen` fails to compile the generator.

## End-to-end example

A complete, verified run. The generator's phantom output is opt-in: **you must pass a
config that sets `"_phantom": true`** (see [Config](#config)). The smallest possible
config is exactly that one flag.

**1. Get a `custom-elements.json`.** Most libraries ship one inside their npm package —
e.g. Shoelace publishes it at `@shoelace-style/shoelace/dist/custom-elements.json`:

```bash
npm install --save-dev @shoelace-style/shoelace
```

> If a library does **not** ship a manifest, produce one with
> [`@custom-elements-manifest/analyzer`](https://github.com/open-wc/custom-elements-manifest)
> — this repo ships ready-made analyzer configs under [`cem-configs/`](cem-configs/)
> (see [below](#cem-configs--analyzer-configs-for-producing-manifests)).

**2. Write the minimal config** and run the generator:

```bash
echo '{ "_phantom": true }' > elm-cem.config.json

npx elm-cem \
  --flags-from=node_modules/@shoelace-style/shoelace/dist/custom-elements.json \
  --config-from=elm-cem.config.json \
  --output=src/Generated
```

**3. What you get.** Modules are emitted under the library's own top-level namespace
(`<Lib>`, derived from the component tag prefix). Here is the **actual** output of that
command run against a real manifest whose tags are `w-*` (→ brand `W`), lightly
abbreviated:

```
src/Generated/
├── W.elm                 -- general surface: every component in the elm/html call shape
├── W/
│   ├── Button.elm        -- one strict module per component (view / build / setters)
│   ├── Card.elm
│   ├── Select.elm
│   ├── …
│   ├── Attributes.elm    -- the canonical shared attribute vocabulary
│   ├── Events.elm        -- capability-gated event handlers
│   ├── Values.elm        -- the enum token vocabulary (filled, large, …)
│   ├── Kind.elm          -- the library's private phantom markers + named kind sets
│   └── Review/
│       └── Facts.elm     -- generated metadata for the elm-review-cem rules
```

```
elm-cem: recorded+resolved 8 TS type-alias reference(s) from .d.ts
elm-cem: merged --config-from
    32 files generated in src/Generated!
```

**4. Use it** in your Elm code — import the general surface for the terse elm/html shape,
or a component module for the compile-tight surface:

```elm
import W

view =
    W.button [ W.Attributes.variant W.Values.primary ] [ W.text "Go" ]
```

## The generated brand

Each run emits a single **brand** (`<Lib>`) as a set of modules. The shape is the same
for every library — the difference is data, not structure:

| Module | Role |
| --- | --- |
| `<Lib>` | **general surface** — every component constructor in the `elm/html` call shape (`view`-shaped producers), one import. Signatures reference each component's aliases. |
| `<Lib>.<Component>` (e.g. `W.Button`) | **strict per-component surface** — `view`, `el` (when the component has required content/attrs), the `build`/`Builder` phantom pipe-builder, narrowed value setters, and `with*` pipe setters. |
| `<Lib>.Attributes` | the **canonical shared attribute vocabulary** — open producers (`{ c \| attr : Supported }`); enum setters here close over the library-wide *union* (cross-component misuse is caught by elm-review). |
| `<Lib>.Events` | **capability-gated** event handlers — an event only type-checks on the component(s) that declare it; `delegate` is the loud bubbling escape. |
| `<Lib>.Values` | the **enum token vocabulary**, minted once with open rows (`primary`, `large`, …). |
| `<Lib>.Kind` | the library's **private phantom markers** (`Brand`/`Ctx`, `Available`/`Used`) and named kind/context sets. Nominal and private — a foreign brand's markers never unify with them. |
| `<Lib>.Review.Facts` | **generated metadata** for the [elm-review-cem](#generated-dependencies) rules (valid values, required slots, singular attrs, slot kinds, …). |

Configuration can add further axes — `<Lib>.Aria`, `<Lib>.Action` — which appear only
when the relevant config is present.

The **two surfaces come from the same data**: the terse general `<Lib>` module and the
strict `<Lib>.<Component>` modules are two projections of one brand model, so they can
never drift. There is no separate "raw" or "html" layer to fall back to — dropping a
layer of strictness is a matter of which module you import, and the escapes (`delegate`,
`recast`) are explicit.

### Generated dependencies

The generated modules are not self-contained; they import two published Elm packages:

- **the HTML IR** (`HtmlIr.*`) — the phantom-typed HTML intermediate representation the
  whole family is built on. `HtmlIr.Element` carries two phantom rows (`accepts` /
  `admittedBy`) that encode the containment relation; `HtmlIr.Attribute` carries the
  capability rows. The generator emits `import HtmlIr.*` — it never copies IR source into
  your output.
- **elm-cem-facts** (`Cem.Facts`) — the shared fact schema that `<Lib>.Review.Facts`
  populates and that the elm-review-cem rules consume.

Add both to your generated package's `elm.json`. See
[`docs/packaging-decay.md`](docs/packaging-decay.md) for the current publishing status of
these packages and the vendoring→published-package migration ("packaging decay") that a
downstream brand goes through.

## Footgun — `--output` deletes existing `.elm` files first

Before generating, elm-cem **removes every `.elm` file in the `--output` directory** so a
module that is no longer emitted (after a rename or an upstream change) can't linger.
**Point `--output` at a directory that holds only generated modules** — never at a
hand-written source dir. Non-`.elm` files are left alone, but any `.elm` you authored
there will be **deleted**. The recommended pattern is a dedicated subdir like
`src/Generated/` that you regenerate wholesale.

## Recipes

### Regenerate after an upstream bump

Bindings are generated artifacts. Wire a `"gen"` script so a regeneration is one command,
and **commit the generated tree** so consumers of *your* project don't need the toolchain:

```jsonc
// package.json
{
  "scripts": {
    "gen": "elm-cem --flags-from=node_modules/@shoelace-style/shoelace/dist/custom-elements.json --config-from=elm-cem.config.json --output=src/Generated"
  }
}
```

```bash
npm install @shoelace-style/shoelace@latest   # bump the component library
npm run gen                                   # regenerate
git add src/Generated                         # review the diff, then commit
```

The diff of `src/Generated/` is your review surface: an expected change (new component,
new attribute) shows up as added modules/setters; an unexpected signature change is a red
flag worth investigating before you commit.

### Generate for a manifest-less library (analyzer)

If a library does not publish a `custom-elements.json`, produce one with
[`@custom-elements-manifest/analyzer`](https://github.com/open-wc/custom-elements-manifest)
using an analyzer config, then feed the result to `--flags-from`:

```bash
npx @custom-elements-manifest/analyzer analyze --config cem-configs/carbon.config.json
npx elm-cem --flags-from=custom-elements.json --config-from=elm-cem.config.json --output=src/Generated
```

## Config

`--flags-from` names the manifest; `--config-from=<json>` layers curation the CEM can't
express. Pass `--config-from` **multiple times** and the files are deep-merged (per
component key, then each component's field object; later files override individual
fields).

The generator's output shape is driven by a small set of **composable config
primitives** — a brand is *data* in this vocabulary, and each generated module is a
*projection* of that data. The full catalog with worked examples lives in
[`docs/config-primitives.md`](docs/config-primitives.md); the essentials:

- **`_phantom: true`** (top level) — opt into the phantom pipeline. **Required** to emit
  the brand described above; without it the CLI reports that the legacy pipeline is
  retired and stops.
- **`kind`** (per component) — what the element *is*: `"private"` (the default — the
  brand's own marker) or `"shared:<role>"` (a cross-library shared atom, e.g.
  `"shared:icon"`).
- **`admits`** (per component) — the containment relation: which child *kinds* each slot
  accepts, with `multi` / `required`. Kinds are `"any"`, `"shared:<role>"`, another
  component's constructor name, or a set reference `"@<name>"`.
- **`parents`** (per component) — where the element is valid. Absent ⇒ valid anywhere
  (the default); a closed list restricts it to those containers.
- **`_sets`** (top level) — named kind/context sets, referenced as `"@name"` from any
  `admits` / `parents` list.
- **`_atoms`** (top level) — declares the shared atoms this brand re-exposes (e.g.
  `text`).
- **`require`** (per component) — cardinality and required shape; drives which components
  get an `el` entry point and the `build` capability record.
- **`_renames`** (top level) — an identifier-override escape hatch for collision
  resolution (fails loud on an unknown source).

There is no config-declared kind-crossing primitive: every generated brand ships a
`<Lib>.Unsafe.recast` (general, unrestricted re-kind) as part of its escape surface —
see [`docs/config-primitives.md`](docs/config-primitives.md#retired-outright) for why a
narrower, config-declared `_coerce` primitive was tried and then removed.

Per-element CEM curation keys (`_exclude`, `syntheticAttrs`, `attrTypes`, `staticAttrs`,
`events`, `group`, `idWiring`, `_actions`) carry over unchanged; see the catalog.

## `cem-configs/` — analyzer configs for producing manifests

The files under [`cem-configs/`](cem-configs/) are **not** elm-cem configs — they are
[`@custom-elements-manifest/analyzer`](https://github.com/open-wc/custom-elements-manifest)
configs (globs / exclude / litelement / plugins) for *producing* a library's
`custom-elements.json` upstream, which you then pass to `--flags-from`. Ready-made configs
ship for **Carbon** (`carbon.config.json`), **Ionic** (`ionic.config.json`), and
**Spectrum** (`spectrum.config.mjs`). Nothing in `bin/` or `codegen/` reads them — they
preserve the analyzer setup for each library, ready for the day those libraries get
elm-cem bindings.

## Versions

- **CLI dependency:** `elm-codegen ^0.6.3` (the npm package; ships with this package).
- **Elm compiler:** `elm 0.19.1` (you supply it — see [Prerequisites](#prerequisites)).
- **Generator app:** pins `mdgriffith/elm-codegen 6.0.3` in `codegen/elm.json`.

## Versioning & reporting

elm-cem follows [Semantic Versioning](https://semver.org/). It has **two public
surfaces**, and a change to either is a breaking change:

1. **The CLI + exposed Elm modules** (`Cem`, `Generate`) — the generator's own API,
   including the flags (`--flags-from` / `--config-from` / `--output`).
2. **The generated output** — the emitted module/function/phantom-row names are a
   contract for downstream packages. A rename or type change there is breaking even though
   it lives in another repo. The golden suite (`tests/`) pins it.

See [`CHANGELOG.md`](CHANGELOG.md) for release notes and the full stability policy.

- **Bug reports / feature requests:** [open an issue](https://github.com/jackhp95/elm-cem/issues).
  A minimal CEM snippet + the config used + generated-vs-expected Elm is the ideal repro.
- **Security issues:** report privately — see [`SECURITY.md`](SECURITY.md). Do not open a
  public issue.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for setup (`npm run setup`), the verify gates
(`npm test`, `npm run format`), and a first-PR walkthrough.

## Releasing

- [`RELEASE-CHECKLIST.md`](RELEASE-CHECKLIST.md) — the ordered, owner-only steps.
- The [`releasing-elm-cem`](skills/releasing-elm-cem/) skill — the operational companion
  (the *why* and the gates behind the checklist).

Extracted from the original `elm-custom-elements-manifest` monorepo (now archived).

# `review/` — elm-review for `elm-m3e`

The `elm-review` configuration for the `elm-m3e` library (the `M3e.*` package at `src/`, the
generated wrapper over `@m3e/web`) and the `docs/` app. Alongside the
standard `jfmengels/*` rule packs it holds the project's **codegen-aware** custom
rules — see [`docs/DESIGN.md` §5](../docs/DESIGN.md) for the design.

## Running

From the **`docs/`** directory (elm + elm-review live in the docs install), against
`docs/elm.json` (whose source-dirs cover `app`, `src`, `.elm-pages`,
`../src`, `../docs/kit`):

```bash
cd docs
node_modules/.bin/elm-review --config ../review --compiler node_modules/.bin/elm
```

> **Sibling checkout required.** The config's codegen-aware rules come from the
> unpublished [`jackhp95/elm-review-cem`](https://github.com/jackhp95/elm-review-cem)
> package. `review/elm.json` pulls them in through a `../../elm-review-cem/src`
> source directory, so that repo must be checked out alongside `elm-m3e` (as a
> sibling `../elm-review-cem`) for `elm-review` to resolve. Until the package is
> published this local checkout is the only way to run the config (see the TODO in
> `ReviewConfig.elm`).

## Custom rules

Exactly one rule is **repo-local**: `NoProprietaryDsClasses`, in `review/src/`, built
test-first with its `Review.Test` suite under `review/tests/` (7 cases). Every other
codegen-aware rule in the table below is imported from the sibling
`jackhp95/elm-review-cem` package (see [Running](#running)). No `elm-test` binary
ships with this repo, but `elm-cem/node_modules/.bin/elm-test-rs` runs the local suite:

```bash
cd review
../elm-cem/node_modules/.bin/elm-test-rs --compiler ../docs/node_modules/.bin/elm tests/*.elm
```

| Rule | Kind | Source | Enabled in `ReviewConfig`? |
|---|---|---|---|
| `ValidEnumValue` | facts-driven | `elm-review-cem` | ✅ — flags a loose enum setter given a token the component rejects |
| `SingularSlot` | facts-driven, advisory | `elm-review-cem` | ✅ — a singular content slot filled twice |
| `RequireSlot` | facts-driven, advisory | `elm-review-cem` | ✅ — a required-multi slot absent from content |
| `NoProprietaryDsClasses` | hand-written | repo-local | ✅ — `ds-`/`t-` class tokens in `Attr.class` literals |
| `NoSeamOutsideAllowedModules` | hand-written, configurable | `elm-review-cem` | ⬚ `CodegenReviewConfig` only — docs use `Seam` for Tailwind by design |
| `NoInternalImportOutsideAllowed` | hand-written, configurable | `elm-review-cem` | ⬚ `CodegenReviewConfig` only — the opaque-IR backstop |

### Codegen-aware rules + `M3e.Review.Facts`

`ValidEnumValue` / `SingularSlot` / `RequireSlot` read `M3e.Review.Facts` — a data
module generated from the CEM alongside the library (per-component valid enums,
required slots, multi slots). The rule *logic* is hand-written and tested; a
`@m3e/web` bump only regenerates the facts. `review/elm.json` lists
`../src` as a source dir so the config can import the facts (it has no
dependencies of its own, so nothing else from the library is pulled in).

### Two configs

- **`ReviewConfig.elm`** — what this repo gates on. Includes the three facts-driven
  rules (verified clean against the whole docs app) + the standard packs.
- **`CodegenReviewConfig.elm`** — the full reusable facts-driven rule set for *consumers*,
  including `NoActionlessButton` and the configurable `NoSeamOutsideAllowedModules`
  Seam gate. These two correctly fire on this repo's docs (demo buttons; intentional
  `Seam` use for Tailwind), so they're opt-in rather than gating this repo.

## Retired rules

The Ui-era material-discipline rules the facts-driven rules made obsolete were removed
(details in `docs/DESIGN.md` §5): `NoUntypedSlot` (phantom-typed slots enforce it),
`NoRawAttributeInUi` and `NoRawLayoutOutsideLayoutModule` (both generalized into
`NoSeamOutsideAllowedModules`), `PreferBadgeCount` (`M3e.Badge` has no `count`), and
`NoMissingFacadeEntry` (facade epic #52 closed).

## Relaxations

Deliberate, documented adjustments (not blind suppression) live as commented
`ignore*` helpers in `ReviewConfig.elm`: `.elm-pages/` is never linted (generated
routing); the library's public surface (`src/M3e/`) is exempt from `NoUnused.Exports`
/ `.Modules` / `NoMissingTypeExpose` (a library's exports are unused *by itself*); and
`M3e.Node.toHtml` is gated to `Shared` + `M3e.Node` (the single render escape hatch).

# `jackhp95/elm-shoelace` has moved — the monolith is now five packages

**Status: the single-package `jackhp95/elm-shoelace` identity is RETIRED.** The
library was split into five concern-separated sibling packages, the same treatment
`elm-m3e` and `elm-typed-html` already received. The directory
`brands/shoelace/generated/package/elm-shoelace/` still exists, but **only as the
generation-staging root** — it owns the flat `src/` source-of-truth (regenerated
from the vendored Shoelace CEM) and the `split`/`gen` scripts. Its published Elm
identity is gone; the five packages below are the product.

`jackhp95/elm-shoelace` was a **prerelease that was never published to the Elm
registry**, so there is nothing to un-publish. If you consume the package by source
(git checkout or vendored `source-directories`), this note is your migration path.

## Why the split — the docs.json size cap

A single published Elm package's `docs.json` must stay under the registry's
**700 KB** cap. As a monolith, `elm-shoelace` blew past it: the DAG rework added a
degenerate per-element `Sl.Component.*` façade tier (58 modules), pushing the
monolith `docs.json` to **947,500 B (135.4 % of cap)**. Doc-trimming cannot fix a
structural size problem — the surface itself is too big for one package. Splitting
along the (already-linear) `Build → Components → Elements → Core` DAG puts each tier
in its own package, and every one lands comfortably under cap.

## Where each namespace went

`elm-shoelace`'s module namespaces and package tiers **already align** (no rename
was needed, unlike `elm-m3e`). Point your `source-directories` (or, once published,
your `elm.json` dependencies) at the package that owns each namespace you import:

| Namespace(s) you import | New package |
| --- | --- |
| `Sl` (barrel), `Sl.Html`, `Sl.Attributes`, `Sl.Events`, `Sl.Kind`, `Sl.Values`, `Sl.Forge.Internal`, `Sl.Internal.Types.*` | `jackhp95/elm-shoelace-core` |
| `Sl.Element.*` (strict per-component surfaces) | `jackhp95/elm-shoelace-elements` |
| `Sl.Component.*` (element-family groupings) | `jackhp95/elm-shoelace-components` |
| `Sl.Build.*` (composed builder DSL) | `jackhp95/elm-shoelace-build` |
| `Sl.Review.Facts` | `jackhp95/elm-shoelace-facts` |

The dependency DAG is `core` ← `elements` ← `components` ← `build`, with `facts`
depending only on `jackhp95/elm-cem-facts`. Depend on the tiers you actually import;
`core` is the floor (it carries the `Sl` barrel and the internal types every other
tier references). Shoelace has no `Sl.Icon` tier, so — unlike `elm-m3e`'s six-way
split — there is no `-icons` package; five tiers is shoelace's real ceiling.

## Migrating a consumer's `elm.json`

Replace the single `…/package/elm-shoelace/src` source-directory (or the
`jackhp95/elm-shoelace` dependency, once these publish) with the specific packages
you use. Most apps need at least `-core` + `-elements`; add `-components`, `-build`,
`-facts` as your imports require. Example (`source-directories` form):

```json
"source-directories": [
  "…/package/elm-shoelace-core/src",
  "…/package/elm-shoelace-elements/src",
  "…/package/elm-shoelace-components/src",
  "…/package/elm-shoelace-build/src"
]
```

## Registry publishing

Putting the five packages on the Elm registry (GitHub mirrors +
`publish-mirror-state.json` entries + `elm publish`) is **out of scope of this shape
landing** but is the immediate next priority — same status as `elm-m3e` and
`elm-typed-html` (design OQ-6). Until then, consume by source-directory or git.

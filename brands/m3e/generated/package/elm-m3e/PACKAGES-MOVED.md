# `jackhp95/elm-m3e` has moved — the monolith is now six packages

**Status: the single-package `jackhp95/elm-m3e` identity is RETIRED.** The library
was split into six concern-separated sibling packages (the "package explosion",
design `docs/superpowers/specs/2026-08-20-package-explosion-design.md`, OQ-5). The
directory `brands/m3e/generated/package/elm-m3e/` still exists, but **only as the
generation-staging root** (it owns the flat `src/` source-of-truth and the
`split`/`gen` scripts). Its published Elm identity is gone — the six packages below
are the product.

`jackhp95/elm-m3e` was a **prerelease that was never published to the Elm registry**,
so there is nothing to un-publish. If you consume the package by source (git checkout
or vendored `source-directories`), this note is your migration path.

## Where each namespace went

Module namespaces are **unchanged at this release** — only the package boundaries
moved. Point your `source-directories` (or, once published, your `elm.json`
dependencies) at the package that owns each namespace you import:

| Namespace(s) you import | New package |
| --- | --- |
| `M3e` (barrel), `M3e.Html`, `M3e.Attributes`, `M3e.Action`, `M3e.Events`, `M3e.Kind`, `M3e.Values`, `M3e.Unsafe`, `M3e.Forge`, `M3e.Internal.*` | `jackhp95/elm-m3e-core` |
| `M3e.Component.*` (per-element surfaces) | `jackhp95/elm-m3e-elements` |
| `M3e.Build.*` (builder DSL) | `jackhp95/elm-m3e-build` |
| `M3e.Family.*` (element-family groupings) | `jackhp95/elm-m3e-components` |
| `M3e.Icon` | `jackhp95/elm-m3e-icons` |
| `M3e.Review.Facts` | `jackhp95/elm-m3e-facts` |

The dependency DAG is `facts` ← `core` ← `elements` ← `build`, with `components`
(family) and `icons` depending on `core`/`elements`. Depend on the tiers you
actually import; `core` is the floor (it carries the `M3e` barrel and the internal
types every other tier references).

## Migrating a consumer's `elm.json`

Replace the single `../…/package/elm-m3e/src` source-directory (or the
`jackhp95/elm-m3e` dependency, once these publish) with the specific packages you
use. Most apps need at least `-core` + `-elements`; add `-build`, `-components`,
`-icons`, `-facts` as your imports require. Example (`source-directories` form):

```json
"source-directories": [
  "…/package/elm-m3e-core/src",
  "…/package/elm-m3e-elements/src",
  "…/package/elm-m3e-build/src",
  "…/package/elm-m3e-icons/src"
]
```

## Note for `buildoc` (and other mid-migration consumers)

`buildoc` is the known external consumer currently building against the old
single-package import shape. Two independent changes are landing:

1. **This split (already landed).** Repoint your `M3e.*` imports to the package
   table above. Your *module imports* (`import M3e.Component.Button`, etc.) do **not**
   change — only which package/`src` they resolve from.
2. **A later namespace rename (NOT yet landed — design OQ-1 / plan Task 5).** A
   future release renames `M3e.Component.*` → `M3e.Element.*` and
   `M3e.Family.*` → `M3e.Component.*` so the package tier and the module namespace
   align (`elm-m3e-elements` ⇄ `M3e.Element.*`, `elm-m3e-components` ⇄
   `M3e.Component.*`). That release will **ship a `scripts/rename-namespaces.mjs`
   migration script** that applies the full old→new map in a single atomic pass over
   a target `.elm` tree — run it once against `buildoc` when it lands. Do **not**
   hand-rename ahead of it; a naive sequential `Component→Element` then
   `Family→Component` corrupts the result (the second pass re-captures the freshly
   written `Element`).

## Registry publishing

Putting the six packages on the Elm registry (GitHub mirrors +
`publish-mirror-state.json` entries + `elm publish`) is **out of scope of this shape
landing** but is the immediate next priority (design OQ-6). Until then, consume by
source-directory or git.

# DESIGN-NOTES — Phase 0 decisions (3-package skeleton)

## 0b — Module layout decisions

Three open questions from §3.1 of the consolidation plan, now locked:

### Q1. Does `elm-m3e-components` expose a convenience barrel?

**No (SUPERSEDED 2026-08-10, Jack → 2a worker).** An earlier draft said "Yes — `M3e.Components`". Jack ruled it **redundant**: the thin-core `M3e.elm` already delegates every `foo = M3e.Foo.view`, and a second identical delegation in `elm-m3e-components` is the same thing one directory over. The import tiers are therefore two, not three:

```
import M3e                          -- generic combos only (Element, text, toHtml, Attributes, Kind, Values)
import M3e.Button                   -- per-component strict surface (narrowed values, builder, required content)
```

The barrel role stays with the thin core; no `M3e.Components` module is emitted.

### Q2. Does the thin `M3e` core re-export anything component-shaped?

**No — the thin core is the elm/html-style barrel and owns ALL generic modules** (superseded on package roles 2026-08-10, Jack): `elm-m3e` exposes the generic namespace `M3e`, `M3e.Attributes`, **`M3e.Events`**, **`M3e.Action`**, **`M3e.Coerce`**, **`M3e.Unsafe`**, `M3e.Unsafe.Attributes`, **`M3e.Html`**, `M3e.Kind`, `M3e.Values`. It stays strictly generic — zero per-component type references (the type-leak invariant). `elm-m3e-components` holds per-component modules + the generated `M3e.Review.Facts`; `elm-m3e-builder` holds per-component `M3e.<Component>.Build`. Note: the three packages are named by what they gate for a *page author* — `elm-m3e` (elm/html feel), `elm-m3e-components` (fully-encompassed per-component surface), `elm-m3e-builder` (builder pattern). Support modules (`Events`/`Action`/`Unsafe`/`Coerce`/`Html`) are generic and live in the thin core; each component module re-aliases/re-exports the subset it needs on its own surface.

`M3e.Attributes` is already component-agnostic (confirmed in plan §1.2); it stays
as-is. `M3e.Kind` and `M3e.Values` stay as-is. The generic `M3e` module keeps
`text`, the substrate re-exports (`Element`, `Attr`, `Node`, `toHtml`, `toNode`,
`mapMsg`, `mapNode`), and — in Phase 1 — the Lazy/Keyed surface.

### Q3. Does the builder package want a flat `M3e.Build` alias-skin?

**Yes — scope confirmed 2026-08-10 (Jack → 2a worker).** `M3e.Build` is a thin annotation-skin:
re-export **ONE `Is` alias per component** — `type alias <Component>Is s = M3e.<Component>.Build.Is s`
(e.g. `ButtonIs`, `CardIs`) — **and nothing else per-component** (Jack: "we don't want
to re-export everything. We only want to re-export the relevant types for that specific
component"). The shared generic surface (`Builder`, `toElement`) stays too. A caller who
only needs to *name* a component's phantom type in an explicit annotation imports just
`M3e.Build`:

```elm
import M3e.Build exposing (ButtonIs)

-- annotate without importing M3e.Button or M3e.Button.Build
viewButton : List (Element (ButtonIs s) admittedBy msg) -> Element (ButtonIs s) admittedBy msg
```

This is the "cheap import" from §3.1 bullet 4 — pulls in only type aliases, not
the full component API. The true type definitions live in `M3e.Build.Internal`
(non-exposed, absent from `elm-m3e-builder`'s `exposed-modules`, hence invisible
to `docs.json`/cap); `M3e.Build` and each `M3e.<Component>.Build` expose only
thin `type alias` lines pointing at those internal defs.

---

## 0a — Per-package versioning/tagging + publish scheme

The one-repo cost from §3.1: three `elm.json` packages in one repo need
independent versioning and a CI path to publish each.

### Tag scheme

`<package-dir>/v<semver>`, e.g.:

- `elm-m3e/v1.0.0`      — thin core release
- `elm-m3e-components/v1.0.0`  — components release
- `elm-m3e-builder/v1.0.0`     — builder release

Each tag is a standard lightweight or annotated git tag. The directory prefix
disambiguates which `elm.json` the tag applies to. This is a well-established
monorepo convention (used by elm-json's own repo, Rust workspaces, changesets,
etc.).

### Version independence

Each package versions independently. A breaking change to the builder package
bumps only `elm-m3e-builder`'s version; a new component (non-breaking addition to
`elm-m3e-components`) bumps only that package's minor. The inter-package
dependency declarations in each `elm.json` express the range:

```
elm-m3e-builder ─depends on─> elm-m3e-components ─depends on─> elm-m3e (core)
```

A major bump in core means both downstream packages must widen their dep range
and bump accordingly if they consume the new APIs.

### CI publish mechanism

`elm publish` reads a package's own `elm.json` and requires a matching git tag
(`v<version>`). The tag-prefix scheme (above) means `elm publish` must be run
from each package directory individually, with its own tag. A CI workflow detects
which packages changed (via `git diff --name-only` against the merge-base or the
last release tag) and publishes each independently:

```yaml
# sketch — for DESIGN-NOTES only, not yet implemented
jobs:
  publish:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        pkg: [elm-m3e, elm-m3e-components, elm-m3e-builder]
    if: ${{ contains(steps.changed.outputs.all, matrix.pkg) }}
    steps:
      - run: cd ${{ matrix.pkg }} && elm publish
```

Because `elm publish` resolves the git tag by stripping the `v` prefix and
comparing against `elm.json`'s `version` field, the `<pkg>/v<semver>` tag must
match the package's own version. The tag `elm-m3e/v2.0.0` paired with
`elm-m3e/elm.json`'s `"version": "2.0.0"` satisfies this check.

### Deviation from one-package-per-repo convention

This is the deliberate deviation flagged in §3.1/§5/§6 of the plan. The family
convention is one package per GitHub repo (`elm-typed-html`, `elm-shoelace`,
`elm-web-awesome`). This repo adopts a monorepo workspace instead. The cost is
the tagging/publish scheme above; the benefit is keeping tight coupling between
core/component/builder types in lockstep during development without coordinating
releases across repos. The three `elm.json` directories simulate the per-package
isolation that `elm publish` requires while keeping the source co-located.

### Local development during transition

Until the generator emits the new layout (Phase 2), development still uses the
root `elm.json` with its single `exposed-modules` list. The three skeleton
`elm.json` files define the target package boundaries. When the generator is ready
to emit the split layout, the root `elm.json` will either become a development-only
config using `source-directories` to include all three packages' `src/` trees, or
be removed and replaced by per-package workflows.

### Post-emission package routing (REGENERATION CRITICAL, 2026-08-10)

The elm-cem generator emits a **single flat `<Lib>` layout** (`--output=src`). The
three-package split is applied as a deterministic POST-EMISSION routing step, NOT
inside `Emit.elm`. To regenerate without losing the package boundaries:

1. Regenerate into a temp/flat dir (or the root `src/`) as today.
2. Route each module by its role:
   - **`elm-m3e` (thin core, `elm-m3e/src`):** `M3e`, `M3e.Attributes`, `M3e.Events`, `M3e.Action`, `M3e.Coerce`, `M3e.Unsafe`, `M3e.Unsafe.Attributes`, `M3e.Html`, `M3e.Kind`, `M3e.Values`.
   - **`elm-m3e-components` (`elm-m3e-components/src`):** every `M3e.<Component>` (view/el/setters/strong types) + `M3e.Review.Facts`.
   - **`elm-m3e-builder` (`elm-m3e-builder/src`):** `M3e.Build`, `M3e.Build.Internal` (UNEXPOSED), every `M3e.<Component>.Build`.
3. `M3e.Build.Internal` stays ABSENT from `elm-m3e-builder`'s `exposed-modules`.
4. Update each package's `elm.json` `exposed-modules` from the routed file tree.

Implementation note: a future Phase should codify this routing as a script or
generator flag so regen-drift doesn't silently collapse the split.

---

## Friction log reference

- ~~`M3e.Action`, `M3e.Coerce`, `M3e.Events`, `M3e.Unsafe`, `M3e.Html` placement pending~~ **RESOLVED 2026-08-10** — all five + `M3e.Unsafe.Attributes` live in the thin core `elm-m3e` (first two bullets above + Q2). They are generic; per-component modules re-alias what they need.
- The builder package currently lists only 3 `exposed-modules` (sketch). When the
  generator emits, it will list all `M3e.<Component>.Build` modules (122+) plus
  `M3e.Build`. *(2a emitted 132 builder modules — done.)*

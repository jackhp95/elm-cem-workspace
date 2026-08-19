# Distribution model (1.0)

> How the elm-cem family ships. Supersedes the per-brand **decay ladder**
> (`docs/packaging-decay.md`) as the primary model: the component surface is a
> **codegen/eject target**, not a published package, because a phantom-typed
> N-component brand can never fit the Elm registry's 700 KB `docs.json` cap.

## What publishes to the Elm registry

Five small, cap-safe, stable packages — the substrate plus each brand's HTML-like
vocabulary. Nothing here is the cap-busting component layer.

| Package | Role |
|---|---|
| `jackhp95/elm-html-intermediate-representation` | the IR every generated tree imports — the load-bearing contract |
| `jackhp95/elm-typed-html` | typed `elm/html`, brand-agnostic, broad appeal |
| `jackhp95/elm-cem-facts` | `Cem.Facts` (elm/core only), consumed by the review rules |
| `jackhp95/elm-review-cem` | the `Cem.*` lint rules (must be a registry package — that's how elm-review consumes rules) |
| `jackhp95/elm-m3e` | the m3e **primitives + tokens** (`M3e.Html`, `.Attributes`, `.Values`, `.Events`, `.Kind`, `.Build`, `.Action`, `.Unsafe`) — usable on its own; **eject** for components |

The brand package exposes only its 8 general modules (`M3e.Action`, `.Attributes`,
`.Build`, `.Events`, `.Html`, `.Kind`, `.Unsafe`, `.Values` — the
primitives-only set). Its `docs.json` is ~186 KB, well under cap. No measurement,
no level selection.

> **`M3e.Html` is not plain HTML.** It is the brand's *loose component producer* —
> the `m3e-*` elements with open, unchecked attribute/child rows (each generated
> `M3e.<Component>` tightens it). Plain typed HTML (`div`, `span`, `button`, …) is
> the separate, brand-agnostic `elm-typed-html` package (`TypedHtml.*`).

## What publishes to npm

- `elm-cem` — the generator engine + the `eject` command.

## The component surface — eject, not publish

The full brand (`M3e.Button`, `M3e.Card`, … + the `M3e` barrel) is delivered by
**eject**: a single command that pulls the pre-generated `M3e.*` modules from the
brand repo into the consumer's tree (default), or regenerates them locally
against the consumer's own `@m3e/web` pin (advanced). The ejected code is a
**build artifact** — a separate dir, added to `source-directories`, never
hand-edited (regenerate/re-eject instead).

### `elm-cem eject <brand>` does

1. **Pull** the brand's `M3e.*` modules from GitHub (tag matching the target
   `@m3e/web` version) → `vendor/<Brand>` (configurable).
2. **elm.json:** add `vendor/<Brand>` to `source-directories`; **remove** the
   `jackhp95/elm-<brand>` dep (the vendored superset replaces it — no module
   collision); **promote** the family deps the vendored code imports
   (IR always; facts only if `Review.Facts` is kept) from indirect → direct.
   Detection is by import namespace via `bin/family-deps.js` (the same map `swap`
   used), never hardcoded.
3. **package.json:** pin `@m3e/web` to the exact version the bindings target, so
   the Elm bindings and the runtime web components cannot drift.
4. **Review (optional, `--with-review`):**
   - **No `review/` yet** → scaffold a complete, correct minimal setup:
     `review/elm.json` (deps: elm-review + elm-review-cem + elm-cem-facts;
     source-dirs include `../vendor/<Brand>` so `<Brand>.Review.Facts` resolves)
     and `review/src/ReviewConfig.elm` = `Cem.all <Brand>.Review.Facts.facts`.
   - **Existing `review/`** → safe-merge the two deps + source-dir into
     `review/elm.json` (structured JSON), and **print** the exact
     `ReviewConfig.elm` lines to add (never edit arbitrary Elm).

`--dry-run` (default) prints the full plan and writes nothing; `--write` applies.

### Why review wiring is cheap

`<Brand>.Review.Facts` imports **only** `Cem.Facts`, and `elm-review-cem` ships
`Cem.all facts` — a one-call preset. So the entire consumer `ReviewConfig` is:

```elm
config = Cem.all M3e.Review.Facts.facts
```

and the review env needs just that one generated module + the facts package, not
the 128-component brand.

## Retired

- **decay ladder** (`bin/decay.js` measure + level selection) — we always publish
  the primitives layer; there is nothing to measure or select. (The module
  classification helper is the only reusable part.)
- **`swap` command** (`bin/swap.js`) — it converted vendored dirs → published
  deps (the old cutover). The only direction now is published → vendored
  (**eject**). `family-deps.js` (its namespace→package map) is reused by eject.

## Two consumer paths, framed

- **Copy/eject (default):** pulls pre-generated modules pinned to the brand
  repo's `@m3e/web` version. Zero config on the consumer side.
- **Codegen (advanced, post-1.0 config distribution):** regenerate against a
  different `@m3e/web` pin. Needs the brand config; deferred.

Component API docs live on the **elm-pages docs site**, not the registry.

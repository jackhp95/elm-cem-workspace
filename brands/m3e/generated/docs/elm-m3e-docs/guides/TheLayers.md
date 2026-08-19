# The Surfaces

elm-m3e exposes **two coordinated surfaces** over one shared IR: a general,
`elm/html`-shaped surface and a strict per-component surface. This guide describes
those surfaces, the shared IR foundation they sit on, and the atom layer that bridges
raw content into the typed IR.

For the brand model and kind tiers, see [`Glossary`](Glossary.md) and
[`decisions.md CX2–CX3`](../decisions.md#cx2--brand-kind-rows-per-library).

## The foundation: elm-html-intermediate-representation

elm-m3e depends on `jackhp95/elm-html-intermediate-representation`. This package,
produced alongside the elm-cem generator, owns the phantom-typed HTML IR — a superset
of `elm/html`:

- The IR types (`HtmlIr.Element`, `HtmlIr.Node`, `HtmlIr.Attribute`, `HtmlIr.Value`).
- The kind vocabulary (`HtmlIr.Kind` with `Shared` and `Brand`).
- The interior constructors (`HtmlIr.Internal`) that seams build on — lint-guarded so
  they are not reachable from ordinary code.

The IR is the floor. Its `HtmlIr.Element.Element` type is the one nominal type every
generated brand shares. Because all brands import the same published package, the
nominal type system works across brand boundaries — an `HtmlIr.Kind.Shared`-typed atom
unifies with any m3e slot that opts in to that atom role. **The IR is imported, never
injected**: elm-m3e's generated code carries `import HtmlIr.*`, and the shared runtime
lives in exactly one place.

## The two m3e surfaces

The whole library ships as **one Elm package** (`jackhp95/elm-m3e`). Within it:

```
elm-html-intermediate-representation   HtmlIr.* — the shared phantom-typed HTML IR
  M3e (general)                        M3e.button [attrs] [content] + M3e.text;
                                       shared vocab in M3e.Attributes / M3e.Events / M3e.Values
  M3e.<Component> (per-component)      M3e.Button, M3e.Dialog, … — narrowed values,
                                       required-content view, and the build pipeline
  support                             M3e.Kind, M3e.Unsafe, M3e.Review.Facts
```

Both surfaces return the same `HtmlIr.Element.Element … msg`, so they nest and
interchange freely. Start on the general surface; reach for a per-component module when
you want the compiler (not `elm-review`) to enforce required content and placed-child
slot-kinds.

### The general surface

`M3e` exposes every component in the `elm/html` call shape — `M3e.button [attrs]
[content]`, lowercase names, one import — plus `M3e.text` for plain text content. The
shared vocabulary lives in three sibling modules:

- **`M3e.Attributes`** — the library-wide attribute setters (`disabled`, `value`,
  `name`, `checked`, the generic `class` / `id` / `slot` / `style`). Enum setters here
  close over the library-wide union of values.
- **`M3e.Events`** — the event setters (`onClick`, `onChange`, …).
- **`M3e.Values`** — the enum value tokens (`filled`, `outlined`, `title`, …).

On the general surface, element↔attr validity, enum tokens, and *direct* slot-kind are
compiler-checked. Three checks — missing-required content, duplicate-singular, and the
slot-kind of a child placed via a slot function — are `elm-review` guidance here.

### The per-component surface

`M3e.Button`, `M3e.Card`, … each expose the strict shape for one component:

- `view [attrs] [content]` — or `view { required } [attrs] [content]` where the
  component has required content, making missing-required a **compile** error.
- `build { req } |> setter |> … ` — the incremental pipeline where setting a singular
  attr twice fails to type-check.
- Narrowed value setters (`M3e.Button.variant : Value Variant -> …`) that admit only
  that component's tokens.

Everything the general surface leaves to `elm-review` is a compile error here.

```elm
M3e.Button.view
    [ M3e.Button.variant M3e.Values.filled ]
    [ M3e.text "Submit" ]
```

Slot-kind checking works at compile time. The kind rows of the children must unify with
the closed slot row of the component. An atom carrying `{ s | sharedText :
HtmlIr.Kind.Shared }` unifies with a slot that declares `shared:text`; a foreign-brand
element fails to unify and is rejected by the compiler.

### The support modules

- **`M3e.Kind`** — `Brand` (this library's opaque, nullary phantom marker; Elm's nominal
  type system gives it a distinct identity from `HtmlIr.Kind.Brand` and every other
  brand) and `Ctx` (the context-row marker). This is what makes kind segregation
  compile-time safe with zero runtime cost.
- **`M3e.Unsafe`** / **`M3e.Unsafe.Attributes`** — the published escape hatches:
  `fromHtml` / `fromHtmlAttribute` lift raw `Html`, `fromNode` re-asserts rows on an
  erased `Node`, `recast` / `recastAttr` (and their `*All` list forms) re-kind to free
  rows, and `customElement` / `customAttribute` forge a tag or attribute this library
  has no generated producer for. Every use is a grep target and a lint finding.
- **`M3e.Review.Facts`** — the generated component facts table, consumed by the
  `review/` app's `elm-review-cem` rules.

## The atom layer

Atoms bridge raw content into the typed IR, and there is no userland module in the
loop anymore. Plain text is built in — `M3e.text : String -> Element …` returns the
shared text atom directly, so it needs nothing extra. For native HTML, reach for the
standalone native brand `TypedHtml.*` (`elm-typed-html`) directly — `TypedHtml.text`
carries the same shared-text row natively, and elements like `TypedHtml.a` are
polymorphic enough in their own kind row to unify directly with any slot that
declares a matching `shared:<atom>` field, no adapter required:

| Atom | Kind field | Type produced |
|------|-----------|----------------|
| `M3e.text "…"` / `TypedHtml.text "…"` | `sharedText : HtmlIr.Kind.Shared` | `Element { s \| sharedText : HtmlIr.Kind.Shared } … msg` |
| `TypedHtml.a [ TypedHtml.Attributes.href … ] […]` | `sharedLink : HtmlIr.Kind.Shared` | unifies with any slot requiring it — `a`'s own kind row is open, not fixed |

An m3e component slot accepts an atom when its slot config declares `"shared:<atom>"` and
the generated slot row contains that field. The Elm type checker resolves the
unification — no cast, no coercion, no seam crossing required. Atoms are the only thing
that flows freely across brand boundaries; private-brand components are rejected by
default.

For native-HTML elements (`div`, `span`, `img`, …), use the native brand `TypedHtml.*`
(`elm-typed-html`) directly — there is no userland copy to maintain. ARIA setters come
from `TypedHtml.Aria` (the ARIA hybrid) — see the accessibility guide. For crossing raw
`Html` into the IR, `M3e.Unsafe.fromHtml` — shipped with the library, built on
`HtmlIr.Internal` — is the single sanctioned boundary; see [`Seams`](Seams.md).

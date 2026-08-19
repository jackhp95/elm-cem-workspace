# elm-typed-html

`jackhp95/elm-typed-html` — **type-safe native HTML for Elm, the `TypedHtml` brand.**

> Publishing is human-gated. Until this package lands on the Elm registry, install
> it by source (see [Install](#install) below).

## Install

This package is not yet published on the Elm registry. Add it as a local source
dependency alongside [`jackhp95/elm-html-intermediate-representation`][ir]:

```sh
# In your project's elm.json — add both source directories:
# "source-directories": [
#   "src",
#   "../elm-typed-html/src",
#   "../elm-html-intermediate-representation/src"
# ]
```

Once published, the standard install will be:

```sh
elm install jackhp95/elm-typed-html
```

## Quick start

```elm
import HtmlIr.Element
import HtmlIr.Node
import TypedHtml as H
import TypedHtml.Attributes as At
import TypedHtml.Aria as Aria

-- A nav landmark with a typed list inside it.
-- Invalid nesting (e.g. putting a <td> here) is a compile error.
myNav =
    H.nav [ Aria.label "Main" ]
        [ H.ul []
            [ H.li [] [ H.a [ At.href "/" ] [ H.text "Home" ] ]
            , H.li [] [ H.a [ At.href "/about" ] [ H.text "About" ] ]
            ]
        ]

-- Render to elm/html for use in Browser.element / Browser.document
view model =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode myNav)
```

Use `TypedHtml.<Component>` for the strict per-component surface (required
content, builder, narrowed values):

```elm
import TypedHtml.Input as Input

-- Input.input requires the typed Attrs surface; wrong attributes are compile errors.
-- `type_` is admitted by `input` (and `button`/`script`) but not by, say, `div`.
myInput =
    Input.input [ Input.type_ "email", Input.required True ] []
```

This is a **generated** package. Every module under `src/` is emitted by the
elm-cem phantom generator from two committed inputs (`manifest/native.cem.json`
and `config/config.json`); there are **zero post-codegen tweaks**, and that
contract is enforced by a gate (see [Regenerating](#regenerating)). Do not
hand-edit `src/` — edit the inputs (or the generator) and regenerate.

The `TypedHtml` surface mirrors the `elm/html` call shape (`div [] [ ... ]`) but
carries phantom types that make containment, attribute admissibility, enum
values, and required content checkable at compile time.

## What it is

`TypedHtml` is one **brand** produced by the elm-cem generator. Rather than
inlining its own runtime, it is generated **against a shared intermediate
representation** — the package
[`jackhp95/elm-html-intermediate-representation`][ir] (the `HtmlIr.*` modules).
The IR is a normal dependency: every generated module **imports** `HtmlIr.*`
(`HtmlIr.Element`, `HtmlIr.Node`, `HtmlIr.Attribute`, `HtmlIr.Value`,
`HtmlIr.Kind`, `HtmlIr.Internal`). The runtime is **not injected** into this
package's source.

### Its role: the typed HTML substrate

`TypedHtml` is the **native-HTML layer** of the elm-cem family. It gives you the
native element producers (`div`, `span`, `section`, `ul`, `a`, …) and the typed form
controls with events — all on the same
`HtmlIr.Element` substrate that component brands like
[`jackhp95/elm-m3e`](https://github.com/jackhp95/elm-m3e) are generated onto.

That shared substrate is what makes **heterogeneous, cross-brand composition**
work: an `M3e.button` drops straight into a `TypedHtml.div` child list, and a
`TypedHtml.input` drops into an `M3e` slot — no bridge, no `toHtml` round-trip
between them. Use `TypedHtml.*` for layout and forms instead of reaching back to
`Html.div` + `toHtml`. For the full pattern, see the
[**composition guide**](https://github.com/jackhp95/elm-m3e/blob/main/docs/composition.md)
in elm-m3e.

The pieces you reach for most:

- **Native producers** — `TypedHtml.div` / `span` / `section` / `ul` / … take
  mixed typed children directly.
- **Typed form controls** — `TypedHtml.input` / `textarea` / `select` with
  **payload-typed** events: `onInput` / `onChange : (String -> msg)` and
  `onCheck : (Bool -> msg)` hand you the value directly (like `elm/html`);
  `onInputWith` / `onChangeWith` / `onCheckWith` take a decoder for custom payloads.
- **`TypedHtml.Unsafe`** — `fromHtml` / `recast` / `recastAll`, the loud escapes
  for genuine raw `Html` (see below).
- **`TypedHtml.toHtml`** — the render exit; `TypedHtml.toHtml el` is the barrel
  shorthand for `HtmlIr.Node.toHtml (HtmlIr.Element.toNode el)`.

## Module surface

Two coordinated surfaces, both generated:

- **General surface** — the `elm/html` call shape in one import.
  - `TypedHtml` — every element constructor (`a`, `div`, `button`, … plus
    `text`). Signatures reference each component's aliases.
  - `TypedHtml.Attributes`, `TypedHtml.Events`, `TypedHtml.Values` — the shared
    attribute, event, and value vocabulary.
  - `TypedHtml.Aria` — the ARIA attribute surface.
  - `TypedHtml.Kind` — the containment-kind types.
  - `TypedHtml.Unsafe` — escape hatches (`fromHtml` / `recast` / `recastAll`)
    for legacy/raw HTML.

- **Specific per-component surface** — the strict per-component modules with
  required content, builder shapes, and narrowed values. These are grouped by
  composition family / `home`:
  - `TypedHtml.A`, `TypedHtml.Button`, `TypedHtml.Details`, `TypedHtml.Embedded`,
    `TypedHtml.Form`, `TypedHtml.Grouping`, `TypedHtml.Img`, `TypedHtml.Input`,
    `TypedHtml.Media`, `TypedHtml.Metadata`, `TypedHtml.Scripting`,
    `TypedHtml.Sectioning`, `TypedHtml.Select`, `TypedHtml.Table`,
    `TypedHtml.Text`, `TypedHtml.Textarea`.

The exact exposed-module list is the source of truth in [`elm.json`](elm.json).

There is also a generated **but not exposed** module, `TypedHtml.Review.Facts`,
which lives in `src/TypedHtml/Review/Facts.elm`. It is not a public API; it is
consumed by lint rules (see [elm-review-cem](#relationship-to-elm-review-cem)).

## Inputs

The generated `src/` is a pure function of two committed files:

- **`manifest/native.cem.json`** — the curated Custom-Elements-Manifest-style
  description of the native HTML elements (per-element attributes, slots/content
  models, enums, ARIA roles).
- **`config/config.json`** — the brand config: `"_brand": "TypedHtml"`,
  `"_phantom": true`, the `_sets` (named kind/context sets), the `_globals` (the
  WHATWG global attributes admitted on every element), and the per-element
  `home` / composition wiring that controls module placement and the typed
  surface.

## Regenerating

Regenerate `src/` from the inputs:

```sh
bash scripts/regen.sh
```

This runs the elm-cem generator (`elm-cem/bin/elm-cem.js`, overridable via the
`ELM_CEM_BIN` env var) with `--flags-from` pointing at
`manifest/native.cem.json`, `--config-from` pointing at `config/config.json`,
and `--output` at `src/`, then runs `elm-format`.

### The regen-diff gate

The committed `src/` **must be byte-identical** to a clean regeneration at the
current generator HEAD (the "zero post-codegen tweaks" contract). Enforce it:

```sh
bash scripts/regen-diff-gate.sh
```

A passing run prints:

```
regen-diff gate: OK — src/ is byte-identical to a clean regen
```

and exits 0. If `src/` has drifted from a clean regen, the gate prints the
differing files and exits 1. Treat a failure as a signal to regenerate (or to
fix the generator/inputs) — never to hand-patch `src/`.

> The gate and `regen.sh` both invoke the generator by absolute path. If you
> have the elm-cem checkout at a different location, set the `ELM_CEM_BIN`
> environment variable (both `scripts/regen.sh` and `scripts/regen-diff-gate.sh`
> honour it).

## Verifying the types

`verify/run.sh` is a compile-acid harness: `verify/src/Good.elm` **must**
compile, and every file under `verify/bad/` **must** fail to compile. It
exercises the generated types against the local `src/` and the local IR
checkout.

```sh
bash verify/run.sh
```

`npm run check:whatwg` (folded into `npm run gate`) is the curation-conformance gate:
it flags any WHATWG global attribute dropped from `config/_globals`, any global
that is curated but has no setter in the emitted `TypedHtml.Attributes` (i.e. is
not really *expressible*), any global re-flattened to a free string when its real
shape is a `bool` / `int` / enum, or a missing `type` content attribute on
`input`/`button`/`script` — the B4-class regression where the curated manifest
silently falls below the spec.

The type check is there because a `String -> Attr` setter INVERTS a boolean
content attribute: while `_globals` was a bare name list, `hidden "false"` HID the
element and `inert "false"` made it inert (every value at all is the true state).
`hidden`, `draggable`, `contenteditable`, `spellcheck` and `writingsuggestions`
are enums rather than `Bool`, because for those a literal `"false"` (or
`"until-found"`) means something absence does not.

### Two attributes have no setter, on purpose

`formaction` and `is` are declared by the manifest, are real HTML, and get **no
setter**. `elm/virtual-dom` cannot write either one, so a setter would compile,
render, raise nothing, and do something else:

- **`formaction`** — `_VirtualDom_noOnOrFormAction` rewrites every
  `VirtualDom.attribute` key matching `/^(on|formAction$)/i` to `data-` + key,
  and the `i` flag makes `^formAction$` match HTML's lowercase spelling. It would
  render `data-formaction`. The property path is closed too:
  `_VirtualDom_noInnerHtmlOrFormAction` rewrites the exact key `formAction`, and
  the lowercase key is an inert expando no element observes.
- **`is`** — a customized built-in element must be opted in at creation time via
  `document.createElement(tag, { is })`, and `_VirtualDom_render` calls
  `createElement(vNode.__tag)` with no options argument. The element already
  exists as its plain built-in self before any attribute fact is applied.

Both stay in the curated inputs, because those describe HTML. `npm run check:whatwg`
therefore still requires all 29 WHATWG globals in `config/_globals`, and
*separately* checks that these two are absent from the emitted surface — so
neither deleting `is` from the config nor restoring its setter can pass the gate.
The reasons live in that script's `KERNEL_BLOCKED` table and in
`Attr.kernelBlockedReason` in the generator. Use a port or a custom element.

## How the brand is typed (mechanisms)

The generator projects the manifest + config into phantom-typed Elm. The
relevant mechanisms, all visible in the generated `src/`:

- **Bidirectional `admittedBy` typing** — each element publishes what it admits
  as children and where it is itself admitted (the `ChildAdmittedBy` / kind
  machinery in `TypedHtml.Kind` and the per-component modules). This makes
  invalid nesting a type error.
- **ARIA hybrid** — roles/aria surfaced through `TypedHtml.Aria` and the
  per-component role types, gated by the manifest's `roles`.
- **`delegate` / `recast`** — the escape/adaptation primitives used where an
  attribute or value must cross a boundary (present in `TypedHtml.Attributes`,
  `TypedHtml.Events`, `TypedHtml.Scripting`).

The full config vocabulary — the nine primitives (`element`, `kind`, `admits`,
`parents`, `_sets`, `values`, `roles`, `require` + escape flags,
`home`) — is specified in the generator repo at
`elm-cem/docs/config-primitives.md`. This README describes only what this
generated brand exposes; the vocabulary and emission rules are owned by the
generator.

## Embedding plain `Html` — `TypedHtml.Unsafe.fromHtml`

`TypedHtml.Unsafe.fromHtml` is the **sanctioned plain-embed path**: the one
supported way to drop a raw `Html.Html msg` value into a `TypedHtml` tree.

```elm
import Html
import TypedHtml as H
import TypedHtml.Unsafe as Unsafe

-- Embed anything elm/html (or a third-party widget) can produce.
embedded =
    H.div []
        [ H.p [] [ H.text "typed" ]
        , Unsafe.fromHtml (Html.node "some-widget" [] [])
        ]
```

Its signature erases every phantom guarantee on purpose — the wrapped value
gets **free rows** (`Element accepts admittedBy msg`), so the compiler checks
nothing about its containment or attributes:

```elm
fromHtml : Html msg -> Element accepts admittedBy msg
fromHtml h =
    Ir.fromNode (Ir.fromHtml h)
```

**Do not hand-roll your own forge.** Consumers sometimes reach for a bespoke
`HtmlIr.Internal`-importing "seam" module to embed plain HTML. Every such forge
is **byte-for-byte redundant** with `Unsafe.fromHtml` — it produces the exact
same `Ir.fromNode (Ir.fromHtml …)` node while re-exposing `HtmlIr.Internal`
(which `elm-review-cem`'s `NoRedundantElementForge` / no-`Internal`-import
rules exist to shrink). Use `TypedHtml.Unsafe.fromHtml`; it is loud, greppable,
and the single lint-visible escape hatch. Reserve it for incremental migration
and genuinely un-typed third-party markup.

`TypedHtml.Unsafe` also carries **`recast`** / **`recastAll`** — re-kind an
existing `Element` (or a list of them) to free rows so it fits any slot. Same
loudness, same lint visibility. Reach for these only when a value must cross a
kind boundary you cannot express; if a value is *already* a typed `Element`,
compose it directly rather than recasting. The `elm-review-cem` rule
**`NoRedundantElementEscape`** flags a recast (or `fromHtml`) applied to
something the type system already accepts.

## Accessible form fields

An accessible field needs a `<label for="x">` whose `for` matches the control's
`id="x"`. This native a11y association is already expressible with the typed-html
primitives — pair a `label [ Attributes.for "x" ] [...]` with a control carrying
`Attributes.id "x"` (keep the two ids in sync):

```elm
H.label [ At.for "email" ] [ H.text "Email address" ]
H.input [ At.id "email", At.type_ "email" ] []
```

## Relationship to the elm-cem ecosystem

- **[elm-cem][elm-cem]** — the generator. `bin/elm-cem.js` reads this repo's
  manifest + config and emits `src/`. Regeneration is gated (above); the
  generator is the single source of truth for the emitted shape.
- **[elm-html-intermediate-representation][ir]** — the IR dependency. Provides
  the `HtmlIr.*` runtime (`Element` / `Node` / `Attribute` / `Value` / `Kind` /
  `Internal`) that every generated module imports. `TypedHtml` is a typed façade
  over this substrate; other elm-cem brands share the same IR.
- **[elm-review-cem][review]** — the lint layer. It consumes the generated
  `TypedHtml.Review.Facts` (via `Cem.Facts`) to know per-component enums, slots,
  and rewrites, and it guards against direct imports of `HtmlIr.Internal` in
  user code (the `Internal` module is an implementation detail of the IR, not a
  public API).

## Recipes / gotchas

- **Render boundary** — convert a `TypedHtml` element to `Html.Html msg` via
  `HtmlIr.Node.toHtml (HtmlIr.Element.toNode el)`. This is the only place the
  phantom types are erased; everything upstream is fully typed.
- **Legacy HTML escape hatch** — `TypedHtml.Unsafe.fromHtml` wraps a raw
  `Html.Html msg` value into the TypedHtml type system. Use sparingly; it
  bypasses all containment checks.
- **Transparent elements** — `<a>`, `<del>`, `<ins>`, `<canvas>`, `<map>`,
  `<object>`, `<slot>` are *transparent*: they inherit the content model of
  their parent, so `H.a [ At.href "/" ] [ H.p [] [ H.text "block" ] ]` is
  valid when `<a>` appears in a flow context.
- **ARIA** — import `TypedHtml.Aria` for roles and states. Roles are
  value-typed (not raw strings); invalid role strings are compile errors.
  Tristate attributes (`aria-checked`, `aria-pressed`) accept the
  `Aria.mixed` value.
- **Barrel vs. per-component** — `TypedHtml` (the barrel) is the canonical
  import for most use. `TypedHtml.<Component>` gives you the strict surface
  with narrowed types and builder helpers when you need it.

## Contributing

`src/` is **generated** — do not hand-edit it. Changes to the TypedHtml surface
go through the generator inputs:

- `manifest/native.cem.json` — per-element attributes, content models, enums, ARIA.
- `config/config.json` — brand config: `_brand`, `_phantom`, `_sets`, `home` wiring.

After editing an input, regenerate and verify:

```sh
npm run gen                    # regenerate src/ (bash scripts/regen.sh)
npm run check:drift            # confirm byte-identical output (bash scripts/regen-diff-gate.sh)
npm run gate                   # every check:* in parallel (drift, validate, acid, whatwg, format, review)
npm run check:format           # format check on hand-written files
npm run check:review           # elm-review
```

New behaviour should be driven by changes to the manifest/config and verified
by adding cases to `verify/src/Good.elm` (must compile) or `verify/bad/`
(must not compile).

## Status / publishing

Publishing is **human-gated**. This README, the scripts, and CI do **not**
publish, tag, or bump anything. Cutting a release (and choosing the version
bump against both the general and specific surfaces) is a manual, human-approved
step.

## License

BSD-3-Clause. See [`LICENSE`](LICENSE).

<!-- elm-cem and elm-review-cem resolve on GitHub; the IR repo and this repo
     are not published yet (publishing is human-gated), so their links may 404
     until release. -->
[elm-cem]: https://github.com/jackhp95/elm-cem
[ir]: https://github.com/jackhp95/elm-html-intermediate-representation
[review]: https://github.com/jackhp95/elm-review-cem

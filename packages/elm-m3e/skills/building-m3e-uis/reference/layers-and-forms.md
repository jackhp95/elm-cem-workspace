# Surfaces, enforcement, and a compilable starter

## The two surfaces (from `docs/DESIGN.md`)

- **General surface** — `M3e` (every component in the `elm/html` call shape) plus the
  shared vocabulary `M3e.Attributes` / `M3e.Events` / `M3e.Values`. Element↔attr, enum,
  and *direct* slot-kind are compiler-checked. The everyday default.
- **Per-component surface** — `M3e.Button`, `M3e.Dialog`, … Adds narrowed values, a
  `view { required … }` shape (required content), and a `build` pipeline. Everything the
  general surface leaves to `elm-review` is a compile error here.

Both return `HtmlIr.Element.Element … msg`; only `HtmlIr.Node.toHtml` is eager.

## Full surface table

| Surface | Namespace | Call form | Guarantee |
|---------|-----------|-----------|-----------|
| general (barrel) | `M3e` | `M3e.button [attrs] [content]` | one import; enum + *direct* slot-kind checked at compile |
| per-component (view) | `M3e.Button` | `M3e.Button.view [attrs] [content]` | same, qualified, narrowed values |
| per-component (required record) | `M3e.Button` | `M3e.Button.view { required } [attrs] [content]` | + missing-required is a compile error |
| per-component (build pipeline) | `M3e.Button` | `M3e.Button.build { req } \|> M3e.Button.setter \|> …` | + duplicate-singular is unwritable |

## Which mistake each surface catches

| Mistake | general | per-component |
|---------|:---:|:---:|
| Invalid enum token | compiler | compiler |
| Wrong attr on element | compiler | compiler |
| Wrong slot-kind (**direct** child) | compiler | compiler |
| Wrong slot-kind (child placed via slot fn) | **elm-review** | compiler |
| Missing **required** (label/action) | **elm-review** | compiler |
| **Duplicate singular** (`icon` twice) | **elm-review** | compiler (via `build`) |

Exactly three checks move to `elm-review` (the Cem rules) on the general surface;
the per-component surface converts them to type errors. Choose by which guarantee the
screen actually needs — do not blanket-adopt the per-component `build` pipeline "to be
safe"; it costs qualified imports and pipeline ceremony.

## Shared vocabulary

Shared setters live in `M3e.Attributes` (natural names: `M3e.Attributes.disabled`,
`.value`, `.name`, `.checked`, generic `.class` / `.id` / `.slot` / `.style`),
`M3e.Events` (`onClick`, `onChange`, …), and `M3e.Values` (enum tokens: `filled`,
`outlined`, `title`, …). Where an attribute's type conflicts across components, the value
setter is type-suffixed (e.g. `value` plus `valueFloat`), each with a distinct capability
so the wrong-typed setter cannot unify. Per-component modules re-expose narrowed versions
(`M3e.Button.variant : Value Variant -> …`) that only admit that component's tokens.

## Compilable starter

A `Browser.sandbox` counter with a filled button and an icon. `M3e.text` is built in; copy
`docs/kit/Native.elm` into your app's source directory only if you want native-HTML
elements like `div`.

```elm
module Main exposing (main)

import Browser
import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Node
import M3e
import M3e.Attributes
import M3e.Button
import M3e.Values as Value


type alias Model =
    { count : Int }


type Msg
    = Inc


init : Model
init =
    { count = 0 }


update : Msg -> Model -> Model
update Inc model =
    { model | count = model.count + 1 }


view : Model -> Html Msg
view model =
    -- The single eager exit: IR -> Node -> Html.
    screen model
        |> HtmlIr.Element.toNode
        |> HtmlIr.Node.toHtml


screen : Model -> HtmlIr.Element.Element accepts admittedBy Msg
screen model =
    M3e.button
        [ M3e.Button.variant Value.filled
        , M3e.Button.onClick Inc
        ]
        [ M3e.Button.icon (M3e.icon [ M3e.Attributes.name "add" ] [])
        , M3e.text ("Increment (" ++ String.fromInt model.count ++ ")")
        ]


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }
```

> **JS registration required.** This compiles, but renders nothing until the app's
> `index.js` does `import "@m3e/web";` before `Elm.Main.init`. See the SKILL body.

(Exact attribute/slot names per component — `M3e.Button.onClick`, `M3e.Button.icon`,
`M3e.Button.variant` — come from that component's `src/M3e/Button.elm` doc comment and the
generated implementation card; verify against them, don't guess.)

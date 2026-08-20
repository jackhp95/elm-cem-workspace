module Sample exposing (badge, main)

{-| A real, hand-written TypedSvg document — the human-authored proof that the
generated `TypedSvg` brand composes into a well-formed SVG tree and renders
through the namespaced IR (`Ir.nodeNS`). It exercises:

  - the `<svg>` root with a case-sensitive `viewBox`,
  - a `<defs>` holding a `<linearGradient>` with `<stop>` children (the
    gradient-only nesting the config's `[ "stop" ]` slot enforces),
  - filled/stroked shapes (`<rect>`, `<circle>`, `<path>`),
  - a `<text_>` node with a shared text-content atom child,
  - open-row presentation setters (`fill`, `stroke`, `strokeWidth`) composing
    onto every element without per-element row membership.

`main` renders it to `Html` so `verify`'s `elm make` proves the whole thing
type-checks and collapses to the DOM boundary; `tests/RenderTest.elm` asserts the
emitted structure is well-formed.

-}

import Html exposing (Html)
import TypedSvg exposing (circle, defs, linearGradient, path, rect, stop, svg, text, text_, toHtml)
import TypedSvg.Attributes as A
import TypedSvg.Values as V


badge : Html msg
badge =
    toHtml <|
        svg
            [ A.viewBox "0 0 120 120", A.width "120", A.height "120" ]
            [ defs []
                [ linearGradient [ A.id "grad", A.x1 "0", A.y1 "0", A.x2 "1", A.y2 "1" ]
                    [ stop [ A.offset "0", A.stopColor "#4f8cff" ] []
                    , stop [ A.offset "1", A.stopColor "#8a5cff" ] []
                    ]
                ]
            , rect
                [ A.x "4"
                , A.y "4"
                , A.width "112"
                , A.height "112"
                , A.rx "24"
                , A.fill "url(#grad)"
                ]
                []
            , circle
                [ A.cx "60", A.cy "52", A.r "28", A.fill "white", A.opacity "0.95" ]
                []
            , path
                [ A.d "M44 52 L56 66 L80 40"
                , A.fill "none"
                , A.stroke "#4f8cff"
                , A.strokeWidth "8"
                , A.strokeLinecap V.round
                , A.strokeLinejoin V.round
                ]
                []
            , text_
                [ A.x "60", A.y "104", A.textAnchor V.middle, A.fill "white", A.fontSize "16" ]
                [ text "OK" ]
            ]


main : Html msg
main =
    badge

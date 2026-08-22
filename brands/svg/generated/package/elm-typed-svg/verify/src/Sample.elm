module Sample exposing (badge, dropShadow, enumProof, main)

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
import TypedSvg
    exposing
        ( circle
        , defs
        , feBlend
        , feComposite
        , feFlood
        , feGaussianBlur
        , feMerge
        , feMergeNode
        , feOffset
        , filter
        , g
        , linearGradient
        , path
        , rect
        , stop
        , svg
        , text
        , text_
        , toHtml
        )
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


{-| Compile-time proof that every Task-3 presentation-enum win narrows to its
finite token domain: each setter below is applied with a token drawn from the
enum's own domain, so a token from the wrong enum (or a typo) is a COMPILE error.
The 15 typed enums (`display`, `pointer-events`, `vector-effect`,
`shape-rendering`, `dominant-baseline`, `alignment-baseline`,
`color-interpolation`, `color-rendering`, `direction`, `font-variant`,
`image-rendering`, `overflow`, `text-rendering`, `white-space`, `writing-mode`)
plus the six bare-`String` presentation-gap props (`baseline-shift`,
`glyph-orientation-vertical`, `line-height`, `marker-start`, `marker-mid`,
`marker-end`) are all exercised here.
-}
enumProof : Html msg
enumProof =
    toHtml <|
        svg
            [ A.viewBox "0 0 10 10" ]
            [ g
                [ A.display V.displayBlock
                , A.pointerEvents V.pointerEventsAll
                , A.vectorEffect V.vectorEffectNonScalingStroke
                , A.shapeRendering V.shapeRenderingCrispedges
                , A.colorInterpolation V.colorInterpolationLinearrgb
                , A.colorRendering V.colorRenderingOptimizequality
                , A.imageRendering V.imageRenderingOptimizespeed
                , A.overflow V.overflowHidden
                , A.direction V.directionLtr
                ]
                [ text_
                    [ A.dominantBaseline V.dominantBaselineCentral
                    , A.alignmentBaseline V.alignmentBaselineBaseline
                    , A.fontVariant V.fontVariantSmallCaps
                    , A.textRendering V.textRenderingOptimizelegibility
                    , A.whiteSpace V.whiteSpacePre
                    , A.writingMode V.writingModeLrTb
                    , A.baselineShift "super"
                    , A.glyphOrientationVertical "auto"
                    , A.lineHeight "1.4"
                    , A.markerStart "url(#m)"
                    , A.markerMid "none"
                    , A.markerEnd "url(#m)"
                    ]
                    [ text "enums" ]
                ]
            ]


{-| A Task-5 filter graph, built end-to-end: a classic drop-shadow composed from
the primitives that must all compose through the `Filter` home module and the
namespaced IR. The `<filter>` lives in `<defs>`; a shape references it via the
`filter` presentation property (`filter="url(#shadow)"`).

Exercises: `filter` (the container, admitting `any` filter primitive),
`feGaussianBlur` (typed `edgeMode` enum), `feOffset`, `feFlood` (flood-color /
flood-opacity presentation props), `feComposite` (typed `operator` enum drawn
from the filter domain — `V.filterIn`? no: a real composite op), `feBlend`
(typed `mode` enum), and `feMerge` admitting only `feMergeNode` layers (a wrong
child there is a compile error, per the config's tight slot).

-}
dropShadow : Html msg
dropShadow =
    toHtml <|
        svg
            [ A.viewBox "0 0 100 100" ]
            [ defs []
                [ filter [ A.id "shadow", A.x "-20%", A.y "-20%", A.width "140%", A.height "140%" ]
                    [ feGaussianBlur
                        [ A.in_ "SourceAlpha", A.stdDeviation "3", A.edgeMode V.duplicate, A.result "blur" ]
                        []
                    , feOffset [ A.in_ "blur", A.dx "2", A.dy "2", A.result "off" ] []
                    , feFlood [ A.floodColor "#000000", A.floodOpacity "0.5", A.result "color" ] []
                    , feComposite
                        [ A.in_ "color", A.in2 "off", A.operator V.in_, A.result "shadow" ]
                        []
                    , feBlend
                        [ A.in_ "SourceGraphic", A.in2 "shadow", A.mode V.normal ]
                        []
                    , feMerge []
                        [ feMergeNode [ A.in_ "shadow" ] []
                        , feMergeNode [ A.in_ "SourceGraphic" ] []
                        ]
                    ]
                ]
            , circle [ A.cx "50", A.cy "50", A.r "24", A.fill "#4f8cff", A.filter "url(#shadow)" ] []
            ]


main : Html msg
main =
    Html.div [] [ badge, enumProof, dropShadow ]

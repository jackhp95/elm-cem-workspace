module RenderTest exposing (suite)

{-| The render proof for the generated `TypedSvg` brand: build a real SVG tree
with the public API and assert the collapsed DOM is well-formed. This is the
runtime half of the package gate (`verify/` is the compile half). It confirms
the namespaced IR path (`Ir.nodeNS`) carries the tag, the case-sensitive
`viewBox` attribute survives verbatim, gradient nesting composes, an enum token
renders to its string, and a shared text-content atom lands inside `<text>`.
-}

import Expect
import Html
import Html.Attributes as HtmlAttr
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import TypedSvg exposing (circle, defs, foreignObject, linearGradient, metadata, rect, stop, svg, switch, text, textPath, text_, toHtml, view)
import TypedSvg.Attributes as A
import TypedSvg.Values as V


doc : Html.Html msg
doc =
    toHtml <|
        svg
            [ A.viewBox "0 0 100 100", A.width "100", A.height "100" ]
            [ defs []
                [ linearGradient [ A.id "g", A.x1 "0", A.y1 "0", A.x2 "1", A.y2 "1" ]
                    [ stop [ A.offset "0", A.stopColor "#4f8cff" ] []
                    , stop [ A.offset "1", A.stopColor "#8a5cff" ] []
                    ]
                ]
            , rect [ A.x "0", A.y "0", A.width "100", A.height "100", A.fill "url(#g)" ] []
            , circle [ A.cx "50", A.cy "50", A.r "30", A.fill "white" ] []
            , text_ [ A.x "50", A.y "55", A.textAnchor V.middle ] [ text "OK" ]
            ]


{-| The Task-4 static-surface additions: `foreignObject` (the typed HTML bridge,
here rendered with an empty flow slot), `view` (a named viewport), `metadata`, a
`switch` carrying its conditional-processing selectors, and a `textPath` carrying
its layout attributes. Rendered inside the SVG root so each collapses through the
namespaced IR path (`createElementNS`).
-}
task4Doc : Html.Html msg
task4Doc =
    toHtml <|
        svg
            [ A.viewBox "0 0 10 10" ]
            [ view [ A.id "v", A.viewBox "0 0 5 5" ] []
            , metadata [] []
            , switch
                [ A.systemLanguage "en", A.requiredExtensions "" ]
                [ text_ [ A.x "0", A.y "0" ] [ text "en" ] ]
            , text_ [ A.x "0", A.y "0" ]
                [ textPath [ A.href "#p", A.method "align", A.side "left", A.spacing "auto" ]
                    [ text "curve" ]
                ]
            , foreignObject [ A.x "0", A.y "0", A.width "10", A.height "10" ] []
            ]


suite : Test
suite =
    describe "TypedSvg renders a well-formed SVG document"
        [ test "the <svg> root carries a verbatim, case-sensitive viewBox" <|
            \_ ->
                doc
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "viewBox" "0 0 100 100") ]
        , test "a <circle> renders with its geometry attributes" <|
            \_ ->
                doc
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "circle" ]
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "r" "30") ]
        , test "gradient nesting: two <stop>s render inside the <linearGradient>" <|
            \_ ->
                doc
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "stop" ]
                    |> Query.count (Expect.equal 2)
        , test "an enum token renders to its string (text-anchor=middle)" <|
            \_ ->
                doc
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "text" ]
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "text-anchor" "middle") ]
        , test "a shared text atom lands as text content" <|
            \_ ->
                doc
                    |> Query.fromHtml
                    |> Query.has [ Selector.text "OK" ]
        , test "Task 4: a <foreignObject> renders (the typed HTML bridge) with its geometry" <|
            \_ ->
                task4Doc
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "foreignObject" ]
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "width" "10") ]
        , test "Task 4: a named <view> renders with its viewBox" <|
            \_ ->
                task4Doc
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "view" ]
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "viewBox" "0 0 5 5") ]
        , test "Task 4: a <metadata> element renders" <|
            \_ ->
                task4Doc
                    |> Query.fromHtml
                    |> Query.findAll [ Selector.tag "metadata" ]
                    |> Query.count (Expect.equal 1)
        , test "Task 4: <switch> carries its conditional-processing selectors" <|
            \_ ->
                task4Doc
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "switch" ]
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "systemLanguage" "en") ]
        , test "Task 4: <textPath> carries its layout attributes (method)" <|
            \_ ->
                task4Doc
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "textPath" ]
                    |> Query.has [ Selector.attribute (HtmlAttr.attribute "method" "align") ]
        ]

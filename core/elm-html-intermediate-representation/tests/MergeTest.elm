module MergeTest exposing (suite)

{-| Behavioural pins for the `class` / `style` merge.

elm/virtual-dom merges `class` in its own fact accumulator but silently reduces
two `style` attributes to the last one. These tests hold the line on both, and
on the absent attribute (`none`) rendering nothing at all.

-}

import Expect
import Html.Attributes
import HtmlIr.Internal as Ir
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


div : List (Ir.Attr c msg) -> Query.Single msg
div attrs =
    Query.fromHtml (Ir.toHtml (Ir.node "div" attrs []))


hasAttribute : String -> String -> Query.Single msg -> Expect.Expectation
hasAttribute name value =
    Query.has [ Selector.attribute (Html.Attributes.attribute name value) ]


suite : Test
suite =
    describe "attribute merge"
        [ describe "class"
            [ test "two class setters concatenate, in authoring order" <|
                \_ ->
                    div [ Ir.attribute "class" "a", Ir.attribute "class" "b" ]
                        |> hasAttribute "class" "a b"
            , test "three concatenate" <|
                \_ ->
                    div
                        [ Ir.attribute "class" "a"
                        , Ir.attribute "class" "b"
                        , Ir.attribute "class" "c"
                        ]
                        |> hasAttribute "class" "a b c"
            , test "no dedupe — HTML does not dedupe either" <|
                \_ ->
                    div [ Ir.attribute "class" "a", Ir.attribute "class" "a" ]
                        |> hasAttribute "class" "a a"
            , test "an empty class contributes nothing" <|
                \_ ->
                    div [ Ir.attribute "class" "", Ir.attribute "class" "b" ]
                        |> hasAttribute "class" "b"
            , test "a single class is emitted unjoined" <|
                \_ ->
                    div [ Ir.attribute "class" "only" ]
                        |> hasAttribute "class" "only"
            ]
        , describe "style"
            [ test "declarations from separate setters merge" <|
                \_ ->
                    div
                        [ Ir.styles [ ( "color", "red" ) ]
                        , Ir.styles [ ( "padding", "1px" ) ]
                        ]
                        |> hasAttribute "style" "color:red;padding:1px"
            , test "later wins per property, keeping first-appearance order" <|
                \_ ->
                    div
                        [ Ir.styles [ ( "color", "red" ), ( "padding", "1px" ) ]
                        , Ir.styles [ ( "color", "blue" ) ]
                        ]
                        |> hasAttribute "style" "color:blue;padding:1px"
            , test "custom properties survive (the kernel style path drops these)" <|
                \_ ->
                    div [ Ir.styles [ ( "--m3e-x", "1" ) ] ]
                        |> hasAttribute "style" "--m3e-x:1"
            , test "!important survives (CSSOM property setters drop it)" <|
                \_ ->
                    div [ Ir.styles [ ( "color", "red !important" ) ] ]
                        |> hasAttribute "style" "color:red !important"
            , test "a ; in a value cannot inject a sibling declaration" <|
                \_ ->
                    div [ Ir.styles [ ( "color", "red;background:url(x)" ) ] ]
                        |> hasAttribute "style" "color:redbackground:url(x)"
            , test "a declaration with no property is dropped" <|
                \_ ->
                    div [ Ir.styles [ ( "", "red" ), ( "color", "blue" ) ] ]
                        |> hasAttribute "style" "color:blue"
            , test "an empty declaration list contributes no stray separator" <|
                \_ ->
                    div [ Ir.styles [], Ir.styles [ ( "color", "red" ) ], Ir.styles [] ]
                        |> hasAttribute "style" "color:red"
            ]
        , describe "none"
            [ test "contributes no declaration to a style it sits beside" <|
                \_ ->
                    div [ Ir.none, Ir.styles [ ( "color", "red" ) ], Ir.none ]
                        |> hasAttribute "style" "color:red"
            , test "does not disturb a merge it sits between" <|
                \_ ->
                    div [ Ir.attribute "class" "a", Ir.none, Ir.attribute "class" "b" ]
                        |> hasAttribute "class" "a b"
            ]
        , describe "addAttribute"
            [ test "a class added to an existing node merges with it" <|
                \_ ->
                    Ir.node "div" [ Ir.attribute "class" "base" ] []
                        |> Ir.addAttribute (Ir.attribute "class" "extra")
                        |> Ir.toHtml
                        |> Query.fromHtml
                        |> hasAttribute "class" "extra base"
            , test "an absent attribute does not promote a text leaf to a span" <|
                \_ ->
                    Ir.text "x"
                        |> Ir.addAttribute Ir.none
                        |> Ir.toHtml
                        |> Query.fromHtml
                        |> Query.hasNot [ Selector.tag "span" ]
            , test "a present attribute still promotes a text leaf" <|
                \_ ->
                    Ir.text "x"
                        |> Ir.addAttribute (Ir.attribute "slot" "s")
                        |> Ir.toHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.tag "span" ]
            ]
        , describe "multi-fact Attr"
            [ test "one setter can carry several attributes" <|
                \_ ->
                    div
                        [ Ir.fromHtmlAttributes
                            [ Html.Attributes.attribute "data-a" "1"
                            , Html.Attributes.attribute "data-b" "2"
                            ]
                        ]
                        |> Expect.all
                            [ hasAttribute "data-a" "1"
                            , hasAttribute "data-b" "2"
                            ]
            , test "toHtmlAttributes round-trips every fact" <|
                \_ ->
                    Ir.fromHtmlAttributes
                        [ Html.Attributes.attribute "data-a" "1"
                        , Html.Attributes.attribute "data-b" "2"
                        ]
                        |> Ir.toHtmlAttributes
                        |> List.length
                        |> Expect.equal 2
            , test "toHtmlAttributes of an absent attribute is empty" <|
                \_ ->
                    Ir.none
                        |> Ir.toHtmlAttributes
                        |> List.length
                        |> Expect.equal 0
            ]
        ]

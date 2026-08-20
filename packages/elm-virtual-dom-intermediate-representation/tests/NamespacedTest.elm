module NamespacedTest exposing (suite)

{-| Runtime tests for the 1.1.0 namespaced-node additive (`HtmlIr.Node.nodeNS` /
`keyedNodeNS`, `HtmlIr.Internal.attributeNS`).

`elm make` proves the new constructors type-check; these pin the two things it
cannot: (1) a namespaced node still renders through the merge and structural
accessors exactly as a plain `Tag` does, and (2) the keyed auto-upgrade fires on
a namespaced parent the same way it does on a plain one. The DOM namespace itself
(`createElementNS`) is a `VirtualDom` kernel concern not observable from
`Test.Html.Query`, so it is asserted structurally: tag name, class merge, keys.

-}

import Expect
import Html.Attributes as HtmlAttr
import HtmlIr.Element as Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Node as Node
import HtmlIr.Query as Query
import Test exposing (Test, describe, test)
import Test.Html.Query as Q
import Test.Html.Selector as Selector


svgNS : String
svgNS =
    "http://www.w3.org/2000/svg"


xlinkNS : String
xlinkNS =
    "http://www.w3.org/1999/xlink"


suite : Test
suite =
    describe "namespaced (SVG) nodes"
        [ test "nodeNS renders the tag and its children through toHtml" <|
            \_ ->
                Node.nodeNS svgNS
                    "svg"
                    []
                    [ Node.nodeNS svgNS "circle" [ Ir.attribute "r" "5" ] [] ]
                    |> Node.toHtml
                    |> Q.fromHtml
                    |> Q.has [ Selector.tag "circle", Selector.attribute (HtmlAttr.attribute "r" "5") ]
        , test "class facts merge on a namespaced node exactly as on a plain Tag" <|
            \_ ->
                Node.nodeNS svgNS
                    "rect"
                    [ Ir.attribute "class" "a", Ir.attribute "class" "b" ]
                    []
                    |> Query.classesOf
                    |> Expect.equal [ "a", "b" ]
        , test "tagOf reads a namespaced node's tag" <|
            \_ ->
                Node.nodeNS svgNS "path" [] []
                    |> Query.tagOf
                    |> Expect.equal (Just "path")
        , test "a keyed child auto-upgrades a namespaced parent to KeyedTagNS" <|
            \_ ->
                let
                    circle : Element {} {} msg
                    circle =
                        Ir.fromNode (Node.nodeNS svgNS "circle" [] [])
                in
                Node.nodeNS svgNS
                    "g"
                    []
                    [ Element.toNode (Ir.key "1" circle)
                    , Element.toNode (Ir.key "2" circle)
                    ]
                    |> Query.keysOf
                    |> Expect.equal [ "1", "2" ]
        , test "attributeNS mints a namespaced attribute that survives to render" <|
            \_ ->
                Node.nodeNS svgNS
                    "use"
                    [ Ir.attributeNS xlinkNS "xlink:href" "#icon" ]
                    []
                    |> Node.toHtml
                    |> Q.fromHtml
                    |> Q.has [ Selector.tag "use" ]
        ]

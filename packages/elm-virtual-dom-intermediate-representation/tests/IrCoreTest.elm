module IrCoreTest exposing (suite)

{-| Runtime tests for the hand-written IR-core reductions in `HtmlIr.Internal`
and `HtmlIr.Node` — the footguns `elm make` cannot catch.

Two reductions that a pre-IR, eagerly-rendering component-node runtime would
need pinned do not exist on this substrate at all, so there is no behaviour here
to test for them:

  - **append-to-an-existing-node** (`addChild`, whose classic footgun is a silent
    no-op when the parent turns out to be a leaf) has no equivalent — the IR
    takes its children at `node`/`keyedNode` construction time, so there is no
    post-hoc append that could no-op.
  - **`map` collapsing a node to `Raw`** cannot happen: `mapNode` / `mapElement`
    (re-exported as `HtmlIr.Node.map` / `HtmlIr.Element.map`) are structural —
    the doc comment on `mapElement` explicitly contrasts a runtime "which
    rendered eagerly on map" — so a `map` never turns a node opaque.

The two reductions that DO bite are pinned below:

1.  `HtmlIr.Internal.addAttribute` on a `Text`/`Raw` leaf **promotes it to a
    `<span>`** carrying the attribute rather than silently dropping it.
2.  The for/id auto-wiring composition (named-slot placement, then a raw
    `for=`/`id=` attribute via `HtmlIr.Internal.addAttribute`) stamps BOTH
    `slot=` and the second attribute, and the empty slot name adds no `slot=`.

`verify/` cannot cover either one: it is a compile-time suite (type-safety
attacks that must, or must not, compile), and these are runtime output shapes.
This file and `MergeTest` are the IR's runtime half. `MergeTest` pins the
`class`/`style` merge and the `Text`-leaf side of the promotion; this file adds
the `Raw`-leaf side (issue #79's leaf case, otherwise uncovered) and the slot
composition, whose named-slot case is all issue #79 originally exercised.

-}

import Expect
import Html
import Html.Attributes as HtmlAttr
import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Node as Node
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


{-| Named-slot placement — the `slotAs` composition from the README's
composition table (`fromNode << addAttribute (attribute "slot" name) << toNode`).

It is a composition **over** IR levers, not a lever, so it is deliberately not
part of this package's API; a suite that needs it rebuilds it locally, exactly
as a generated brand package would. An empty name is the identity placement:
the default slot is raw children, so there is no `slot=` to stamp.

-}
slotAs : String -> Element accepts admittedBy msg -> Element other otherAdm msg
slotAs name element =
    if name == "" then
        Ir.fromNode (Element.toNode element)

    else
        Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" name) (Element.toNode element))


{-| A `Raw`-backed element, the kind the for/id composition promotes on the way
in — the raw-`Html` escape (`fromNode << fromHtml`) a native brand exposes as its
one loud crossing.
-}
labelEl : Element accepts admittedBy msg
labelEl =
    Ir.fromNode (Ir.fromHtml (Html.span [] [ Html.text "Name" ]))


{-| A plain (non-slot) class attribute, as an `Attr` with a fully-open row.

Minted through `fromHtmlAttribute` rather than `attribute` on purpose: that is
the opaque-`VirtualDom.Attribute` escape, and it must survive leaf promotion too
— promotion re-attaches whatever facts the `Attr` carries, inspectable or not.

-}
promotedClass : Attr capability msg
promotedClass =
    Ir.fromHtmlAttribute (HtmlAttr.class "promoted")


{-| Render a node inside a wrapper `<div>` so `findAll` (which searches
descendants only) can see the node itself.
-}
wrapped : Node.Node msg -> Query.Single msg
wrapped node =
    Html.div [] [ Node.toHtml node ]
        |> Query.fromHtml


{-| The for/id auto-wiring composition, built from the surviving IR primitives:
an empty slot name adds no `slot=` (the default slot is raw children), a named
slot stamps `slot="name"`, and both stamp the extra attribute (the for/id
association). This is the composition brand packages build above the IR.
-}
slotWithAttr : String -> String -> String -> Element accepts admittedBy msg -> Element other otherAdm msg
slotWithAttr slotName attrName attrValue el =
    slotAs slotName el
        |> Element.toNode
        |> Ir.addAttribute (Ir.attribute attrName attrValue)
        |> Ir.fromNode


suite : Test
suite =
    describe "IR-core runtime reductions"
        [ describe "Text/Raw -> <span> attribute promotion (non-slot attr)"
            [ test "a Text leaf given an attribute is promoted to a <span> carrying it" <|
                \_ ->
                    Ir.addAttribute promotedClass (Node.text "hi")
                        |> Node.toHtml
                        |> Query.fromHtml
                        |> Query.has
                            [ Selector.tag "span"
                            , Selector.class "promoted"
                            , Selector.text "hi"
                            ]
            , test "a Raw leaf given an attribute is promoted to a <span> wrapping it" <|
                \_ ->
                    Ir.addAttribute promotedClass (Ir.fromHtml (Html.node "raw-leaf" [] []))
                        |> Node.toHtml
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.tag "span", Selector.class "promoted" ]
                            , Query.findAll [ Selector.tag "raw-leaf" ] >> Query.count (Expect.equal 1)
                            ]
            ]
        , describe "slotWithAttr (slot + raw attr) — for/id auto-wiring"
            [ test "stamps BOTH slot= and the extra attribute (for/id association)" <|
                \_ ->
                    slotWithAttr "label" "for" "field-1" labelEl
                        |> Element.toNode
                        |> Node.toHtml
                        |> Query.fromHtml
                        |> Query.has
                            [ Selector.attribute (HtmlAttr.attribute "slot" "label")
                            , Selector.attribute (HtmlAttr.attribute "for" "field-1")
                            ]
            , test "the default (unnamed) slot stamps only the attribute, no slot=" <|
                \_ ->
                    slotWithAttr "" "id" "field-1" labelEl
                        |> Element.toNode
                        |> wrapped
                        |> Expect.all
                            [ Query.has [ Selector.attribute (HtmlAttr.attribute "id" "field-1") ]
                            , Query.findAll [ Selector.attribute (HtmlAttr.attribute "slot" "") ]
                                >> Query.count (Expect.equal 0)
                            ]
            ]
        ]

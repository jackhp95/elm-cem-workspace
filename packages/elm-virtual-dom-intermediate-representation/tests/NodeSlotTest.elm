module NodeSlotTest exposing (suite)

{-| Regression tests for issue #79: placing content into a named slot must not
silently drop the `slot=` attribute when the underlying node is a `Raw` escape
(produced by `HtmlIr.Internal.fromHtml`, or by `HtmlIr.Element.map`, which
maps a `Raw`'s payload with `VirtualDom.map` and hands back another `Raw`).
Before the fix the `Raw` branch of `addAttribute` returned the node unchanged,
so escape-hatched or mapped content silently landed in the component's default
slot instead of the named slot it was assigned to.

The guard that keeps that from happening is `HtmlIr.Internal.addAttribute`'s
**leaf promotion**: a `Text` or `Raw` leaf handed an attribute is promoted to a
`<span>` that carries it. `MergeTest` pins the `Text` side of that promotion;
this file is the `Raw` side — the leaf case issue #79 was actually filed
against, and the one a `Raw` payload is easiest to lose, because a `Raw` is
opaque and cannot be given facts in place.

These tests were originally written in `elm-m3e` against the retired
`M3e.Element`/`M3e.Node` component-node runtime, where named-slot placement was
a `Seam.slot` primitive. Neither the runtime nor that primitive exists any more,
and what is left under test — leaf promotion — is IR-core behaviour with no
brand in it, so the suite lives here next to the code it pins.

-}

import Html
import Html.Attributes as Attr
import HtmlIr.Element as Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Node as Node
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


{-| Named-slot placement — the `slotAs` composition from the README's
composition table (`fromNode << addAttribute (attribute "slot" name) << toNode`).

It is a composition **over** IR levers, not a lever, so it is deliberately not
part of this package's API; each suite that needs it rebuilds it locally (see
the twin in `IrCoreTest`), exactly as a generated brand package would. An empty
name is the identity placement: the default slot is raw children, so there is no
`slot=` to stamp.

-}
slotAs : String -> Element accepts admittedBy msg -> Element other otherAdm msg
slotAs name element =
    if name == "" then
        Ir.fromNode (Element.toNode element)

    else
        Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" name) (Element.toNode element))


{-| The raw-`Html` escape (`fromNode << fromHtml`) a native brand exposes as its
one loud crossing — and the node shape issue #79 lost the `slot=` on, since a
`Raw` cannot carry facts itself.
-}
rawEl : Html.Html msg -> Element accepts admittedBy msg
rawEl html =
    Ir.fromNode (Ir.fromHtml html)


{-| Render slot-tagged content down to `Html` so we can query it. `slotAs ""` is
the identity placement (no `slot=`); a named slot stamps `slot="name"`.
-}
renderSlotted : String -> Element accepts admittedBy msg -> Html.Html msg
renderSlotted name el =
    slotAs name el
        |> Element.toNode
        |> Node.toHtml


suite : Test
suite =
    describe "issue #79 — named-slot survives on Raw nodes"
        [ test "a fromHtml escape placed in a named slot renders slot=\"name\"" <|
            \_ ->
                renderSlotted "trailing"
                    (rawEl (Html.span [] [ Html.text "hi" ]))
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "slot" "trailing") ]
        , test "Element.map'd content keeps its slot=\"name\"" <|
            \_ ->
                renderSlotted "leading"
                    (Element.map identity
                        (rawEl (Html.span [] [ Html.text "mapped" ]))
                    )
                    |> Query.fromHtml
                    |> Query.has [ Selector.attribute (Attr.attribute "slot" "leading") ]
        , test "the default (unnamed) slot adds no slot attribute" <|
            \_ ->
                renderSlotted ""
                    (rawEl (Html.span [] [ Html.text "plain" ]))
                    |> Query.fromHtml
                    |> Query.hasNot [ Selector.attribute (Attr.attribute "slot" "") ]
        ]

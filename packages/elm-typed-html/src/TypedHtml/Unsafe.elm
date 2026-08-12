module TypedHtml.Unsafe exposing
    ( fromHtml
    , fromNode
    , recast, recastAll
    , customElement
    )

{-| THE loud legacy-interop escapes: wrap raw `Html` as an `Element`,
re-assert rows on an erased `Node`, re-kind an existing `Element`, or forge
an element from a tag name this library has no generated producer for — all
with FREE phantom rows, so the compiler checks nothing about the result. For
incremental migration and slot-fit only; every use site is a grep target and
a lint finding.

@docs fromHtml
@docs fromNode
@docs recast, recastAll
@docs customElement

-}

import Html exposing (Html)
import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Node exposing (Node)


{-| Wrap raw `Html` with FREE rows. Loud on purpose.
-}
fromHtml : Html msg -> Element accepts admittedBy msg
fromHtml h =
    Ir.fromNode (Ir.fromHtml h)


{-| Re-assert FREE rows on an erased [`Node`](HtmlIr-Node#Node) — the exact dual of the safe `HtmlIr.Element.toNode`. For the boundary where a typed tree was flattened to the IR and must be lifted back (a framework `View` record, a cache). Loud on purpose: the rows it re-asserts were never checked.
-}
fromNode : Node msg -> Element accepts admittedBy msg
fromNode =
    Ir.fromNode


{-| Re-kind an `Element` to FREE rows so it fits any slot — the blessed form of the hand-forged `Ir.fromNode << HtmlIr.Element.toNode` recast. Loud on purpose.
-}
recast : Element aAccepts aAdmittedBy msg -> Element bAccepts bAdmittedBy msg
recast element =
    Ir.fromNode (HtmlIr.Element.toNode element)


{-| `recast` mapped over a list of elements.
-}
recastAll : List (Element aAccepts aAdmittedBy msg) -> List (Element bAccepts bAdmittedBy msg)
recastAll =
    List.map recast


{-| Forge an element from a raw tag name, with FREE rows — for a CUSTOM ELEMENT this library has no generated producer for (`<model-viewer>`, `<slide-panels>`). Loud on purpose: for a standard HTML tag reach for the native brand's typed constructor instead, and for a component this library already ships, use that.
-}
customElement : String -> List (Attr capability msg) -> List (Element childAccepts childAdmittedBy msg) -> Element accepts admittedBy msg
customElement tagName attrs children =
    Ir.fromNode (Ir.node tagName attrs (List.map HtmlIr.Element.toNode children))

module M3e.Component.Toc exposing
    ( view
    , Is, Attrs, OverlineSlot, TitleSlot, ChildAdmittedBy
    , for, maxDepth
    , overline, title, child
    )

{-| The `m3e-toc` component — strict per-component surface.

A table of contents that provides in-page scroll navigation.

@docs view
@docs Is, Attrs, OverlineSlot, TitleSlot, ChildAdmittedBy
@docs for, maxDepth
@docs overline, title, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Toc
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-toc` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Toc.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Toc.Attrs


{-| The kinds the `overline` slot admits.
-}
type alias OverlineSlot =
    M3e.Internal.Types.Toc.OverlineSlot


{-| The kinds the `title` slot admits.
-}
type alias TitleSlot =
    M3e.Internal.Types.Toc.TitleSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Toc.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.toc


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.maxDepth`.
-}
maxDepth : Float -> Attr { c | maxDepth : Supported } msg
maxDepth =
    A.maxDepth


{-| Place an element into the named `overline` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
overline : Element OverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
overline element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "overline") (El.toNode element))


{-| Place an element into the named `title` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
title : Element TitleSlot admittedBy msg -> Element free freeAdmittedBy msg
title element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "title") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)

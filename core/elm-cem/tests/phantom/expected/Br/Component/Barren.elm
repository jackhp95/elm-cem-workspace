module Br.Component.Barren exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , count, label
    , child
    )

{-| The `br-barren` component — strict per-component surface.

A component with zero enum types (K6: no closed enums, no enum tokens).

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs count, label
@docs child

-}

import Br.Attributes as A
import Br.Html as H
import Br.Internal.Types.Barren
import Br.Kind exposing (Available, Brand, Ctx, Used)
import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)


{-| The kind row `br-barren` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Br.Internal.Types.Barren.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Br.Internal.Types.Barren.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Br.Internal.Types.Barren.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Br.Internal.Types.Barren.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Br.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Br.Internal.Types.Barren.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Br.Internal.Types.Barren.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.barren


{-| See `Br.Attributes.count`.
-}
count : Float -> Attr { c | count : Supported } msg
count =
    A.count


{-| See `Br.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)

module Or.Element.Widget exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , label
    , child
    )

{-| The `or-widget` component — strict per-component surface.

An element with one attribute of its own, so its `Attrs` row is a mix of global and CEM fields.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs label
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Or.Attributes as A
import Or.Html as H
import Or.Internal.Types.Widget
import Or.Kind exposing (Available, Brand, Ctx, Used)
import Or.Values


{-| The kind row `or-widget` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Or.Internal.Types.Widget.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Or.Internal.Types.Widget.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Or.Internal.Types.Widget.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Or.Internal.Types.Widget.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Or.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Or.Internal.Types.Widget.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Or.Internal.Types.Widget.AttrCaps


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
    H.widget


{-| See `Or.Attributes.label`.
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

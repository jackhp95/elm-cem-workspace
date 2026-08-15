module Hz.Component.Placement exposing
    ( view
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Position, position
    , child
    )

{-| The `hz-placement` component — strict per-component surface.

Tests K1: enum with both \_top and top tokens.

@docs view
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Position, position
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Hz.Attributes as A
import Hz.Html as H
import Hz.Internal.Types.Placement
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-placement` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.Placement.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.Placement.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Hz.Internal.Types.Placement.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.Placement.ChildAdmittedBy childAdm


{-| The `position` values valid on this component (compile-tight narrowing).
-}
type alias Position =
    Hz.Internal.Types.Placement.Position


{-| The narrowed pipe-builder this component's `Hz.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Hz.Internal.Types.Placement.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Hz.Internal.Types.Placement.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.placement


{-| Position enum with leading-underscore and plain tokens.
-}
position : Value Position -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (Val.toString value_)


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)

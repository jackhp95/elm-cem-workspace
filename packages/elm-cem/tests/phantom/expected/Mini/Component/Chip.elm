module Mini.Component.Chip exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Size, size
    , disabled
    , child
    )

{-| The `mini-chip` component — strict per-component surface.

A compact labelled element.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Size, size
@docs disabled
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Attributes as A
import Mini.Html as H
import Mini.Internal.Types.Chip
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-chip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Mini.Internal.Types.Chip.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Mini.Internal.Types.Chip.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Mini.Internal.Types.Chip.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Chip.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    Mini.Internal.Types.Chip.Size


{-| The narrowed pipe-builder this component's `Mini.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Mini.Internal.Types.Chip.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Mini.Internal.Types.Chip.AttrCaps


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
    H.chip


{-| Chip size.
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| See `Mini.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)

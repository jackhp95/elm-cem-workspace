module Sl.Component.Tag exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Size, size, Variant, variant
    , pill, removable, onRemove
    )

{-| The `sl-tag` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Size, size, Variant, variant
@docs pill, removable, onRemove

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Tag
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-tag` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Tag.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Tag.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Tag.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    Sl.Internal.Types.Tag.Size


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    Sl.Internal.Types.Tag.Variant


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Tag.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Tag.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.tag


{-| The tag's size. (default: `'medium'`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The tag's theme variant. (default: `'neutral'`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `Sl.Attributes.pill`.
-}
pill : Bool -> Attr { c | pill : Supported } msg
pill =
    A.pill


{-| See `Sl.Attributes.removable`.
-}
removable : Bool -> Attr { c | removable : Supported } msg
removable =
    A.removable


{-| See `Sl.Events.onRemove`.
-}
onRemove : msg -> Attr { c | onRemove : Supported } msg
onRemove =
    Ev.onRemove

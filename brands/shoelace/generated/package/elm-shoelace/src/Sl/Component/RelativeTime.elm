module Sl.Component.RelativeTime exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Format, format, Numeric, numeric
    , date, sync
    )

{-| The `sl-relative-time` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Format, format, Numeric, numeric
@docs date, sync

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.RelativeTime
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-relative-time` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.RelativeTime.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.RelativeTime.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.RelativeTime.ChildAdmittedBy childAdm


{-| The `format` values valid on this component (compile-tight narrowing).
-}
type alias Format =
    Sl.Internal.Types.RelativeTime.Format


{-| The `numeric` values valid on this component (compile-tight narrowing).
-}
type alias Numeric =
    Sl.Internal.Types.RelativeTime.Numeric


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.RelativeTime.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.RelativeTime.AttrCaps


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
    H.relativeTime


{-| The formatting style to use. (default: `'long'`)
-}
format : Value Format -> Attr { c | format : Supported } msg
format value_ =
    Ir.attribute "format" (Val.toString value_)


{-| When `auto`, values such as "yesterday" and "tomorrow" will be shown when possible. When `always`, values such as
"1 day ago" and "in 1 day" will be shown. (default: `'auto'`)
-}
numeric : Value Numeric -> Attr { c | numeric : Supported } msg
numeric value_ =
    Ir.attribute "numeric" (Val.toString value_)


{-| See `Sl.Attributes.date`.
-}
date : String -> Attr { c | date : Supported } msg
date =
    A.date


{-| Keep the displayed value up to date as time passes. (default: `false`)
-}
sync : Bool -> Attr { c | sync : Supported } msg
sync value_ =
    if value_ then
        Ir.attribute "sync" ""

    else
        Ir.none

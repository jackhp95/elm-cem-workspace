module Sl.Element.FormatBytes exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Display, display, Unit, unit
    , value, defaultValue
    )

{-| The `sl-format-bytes` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Display, display, Unit, unit
@docs value, defaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.FormatBytes
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-format-bytes` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.FormatBytes.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.FormatBytes.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.FormatBytes.ChildAdmittedBy childAdm


{-| The `display` values valid on this component (compile-tight narrowing).
-}
type alias Display =
    Sl.Internal.Types.FormatBytes.Display


{-| The `unit` values valid on this component (compile-tight narrowing).
-}
type alias Unit =
    Sl.Internal.Types.FormatBytes.Unit


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.FormatBytes.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.FormatBytes.AttrCaps


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
    H.formatBytes


{-| Determines how to display the result, e.g. "100 bytes", "100 b", or "100b". (default: `'short'`)
-}
display : Value Display -> Attr { c | display : Supported } msg
display value_ =
    Ir.attribute "display" (Val.toString value_)


{-| The type of unit to display. (default: `'byte'`)
-}
unit : Value Unit -> Attr { c | unit : Supported } msg
unit value_ =
    Ir.attribute "unit" (Val.toString value_)


{-| The number to format in bytes. (default: `0`)

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : Float -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.float value_)


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : Float -> Attr { c | value : Supported } msg
defaultValue value_ =
    Ir.attribute "value" (String.fromFloat value_)

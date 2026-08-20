module Sl.Component.FormatNumber exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , CurrencyDisplay, currencyDisplay, Type, type_
    , currency, maximumFractionDigits, maximumSignificantDigits, minimumFractionDigits, minimumIntegerDigits, minimumSignificantDigits, noGrouping, value, defaultValue
    )

{-| The `sl-format-number` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs CurrencyDisplay, currencyDisplay, Type, type_
@docs currency, maximumFractionDigits, maximumSignificantDigits, minimumFractionDigits, minimumIntegerDigits, minimumSignificantDigits, noGrouping, value, defaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.FormatNumber
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-format-number` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.FormatNumber.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.FormatNumber.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.FormatNumber.ChildAdmittedBy childAdm


{-| The `currencyDisplay` values valid on this component (compile-tight narrowing).
-}
type alias CurrencyDisplay =
    Sl.Internal.Types.FormatNumber.CurrencyDisplay


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    Sl.Internal.Types.FormatNumber.Type


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.FormatNumber.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.FormatNumber.AttrCaps


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
    H.formatNumber


{-| How to display the currency. (default: `'symbol'`)
-}
currencyDisplay : Value CurrencyDisplay -> Attr { c | currencyDisplay : Supported } msg
currencyDisplay value_ =
    Ir.attribute "currency-display" (Val.toString value_)


{-| The formatting style to use. (default: `'decimal'`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| See `Sl.Attributes.currency`.
-}
currency : String -> Attr { c | currency : Supported } msg
currency =
    A.currency


{-| See `Sl.Attributes.maximumFractionDigits`.
-}
maximumFractionDigits : Float -> Attr { c | maximumFractionDigits : Supported } msg
maximumFractionDigits =
    A.maximumFractionDigits


{-| See `Sl.Attributes.maximumSignificantDigits`.
-}
maximumSignificantDigits : Float -> Attr { c | maximumSignificantDigits : Supported } msg
maximumSignificantDigits =
    A.maximumSignificantDigits


{-| See `Sl.Attributes.minimumFractionDigits`.
-}
minimumFractionDigits : Float -> Attr { c | minimumFractionDigits : Supported } msg
minimumFractionDigits =
    A.minimumFractionDigits


{-| See `Sl.Attributes.minimumIntegerDigits`.
-}
minimumIntegerDigits : Float -> Attr { c | minimumIntegerDigits : Supported } msg
minimumIntegerDigits =
    A.minimumIntegerDigits


{-| See `Sl.Attributes.minimumSignificantDigits`.
-}
minimumSignificantDigits : Float -> Attr { c | minimumSignificantDigits : Supported } msg
minimumSignificantDigits =
    A.minimumSignificantDigits


{-| See `Sl.Attributes.noGrouping`.
-}
noGrouping : Bool -> Attr { c | noGrouping : Supported } msg
noGrouping =
    A.noGrouping


{-| The number to format. (default: `0`)

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

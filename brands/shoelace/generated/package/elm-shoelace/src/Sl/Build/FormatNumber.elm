module Sl.Build.FormatNumber exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withCurrency, withCurrencyDisplay, withId, withMaximumFractionDigits, withMaximumSignificantDigits, withMinimumFractionDigits, withMinimumIntegerDigits, withMinimumSignificantDigits, withNoGrouping, withSlot, withStyle, withType, withValue)

{-| The **FormatNumber** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.FormatNumber`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withCurrency, withCurrencyDisplay, withId, withMaximumFractionDigits, withMaximumSignificantDigits, withMinimumFractionDigits, withMinimumIntegerDigits, withMinimumSignificantDigits, withNoGrouping, withSlot, withStyle, withType, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Component.FormatNumber as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.FormatNumberIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.FormatNumberBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.FormatNumberAttrCaps


{-| -}
type alias SlotCaps =
    Component.FormatNumberSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.FormatNumberChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-format-number" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.FormatNumberIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withCurrency : String -> Builder { a | currency : Available } slotCaps msg kind -> Builder { a | currency : Used } slotCaps msg kind
withCurrency value_ =
    B.withAttribute (A.currency value_)


{-| -}
withCurrencyDisplay : Value Component.FormatNumberCurrencyDisplay -> Builder { a | currencyDisplay : Available } slotCaps msg kind -> Builder { a | currencyDisplay : Used } slotCaps msg kind
withCurrencyDisplay value_ =
    B.withAttribute (Component.formatNumberCurrencyDisplay value_)


{-| -}
withMaximumFractionDigits : Float -> Builder { a | maximumFractionDigits : Available } slotCaps msg kind -> Builder { a | maximumFractionDigits : Used } slotCaps msg kind
withMaximumFractionDigits value_ =
    B.withAttribute (A.maximumFractionDigits value_)


{-| -}
withMaximumSignificantDigits : Float -> Builder { a | maximumSignificantDigits : Available } slotCaps msg kind -> Builder { a | maximumSignificantDigits : Used } slotCaps msg kind
withMaximumSignificantDigits value_ =
    B.withAttribute (A.maximumSignificantDigits value_)


{-| -}
withMinimumFractionDigits : Float -> Builder { a | minimumFractionDigits : Available } slotCaps msg kind -> Builder { a | minimumFractionDigits : Used } slotCaps msg kind
withMinimumFractionDigits value_ =
    B.withAttribute (A.minimumFractionDigits value_)


{-| -}
withMinimumIntegerDigits : Float -> Builder { a | minimumIntegerDigits : Available } slotCaps msg kind -> Builder { a | minimumIntegerDigits : Used } slotCaps msg kind
withMinimumIntegerDigits value_ =
    B.withAttribute (A.minimumIntegerDigits value_)


{-| -}
withMinimumSignificantDigits : Float -> Builder { a | minimumSignificantDigits : Available } slotCaps msg kind -> Builder { a | minimumSignificantDigits : Used } slotCaps msg kind
withMinimumSignificantDigits value_ =
    B.withAttribute (A.minimumSignificantDigits value_)


{-| -}
withNoGrouping : Bool -> Builder { a | noGrouping : Available } slotCaps msg kind -> Builder { a | noGrouping : Used } slotCaps msg kind
withNoGrouping value_ =
    B.withAttribute (A.noGrouping value_)


{-| -}
withType : Value Component.FormatNumberType -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.formatNumberType_ value_)


{-| -}
withValue : Float -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))

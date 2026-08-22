module Sl.Component.FormatNumber exposing (FormatNumberIs, FormatNumberAttrs, FormatNumberBuilder, FormatNumberAttrCaps, FormatNumberSlotCaps, FormatNumberChildAdmittedBy, FormatNumberCurrencyDisplay, FormatNumberType, formatNumber, formatNumberCurrencyDisplay, formatNumberType_, formatNumberCurrency, formatNumberMaximumFractionDigits, formatNumberMaximumSignificantDigits, formatNumberMinimumFractionDigits, formatNumberMinimumIntegerDigits, formatNumberMinimumSignificantDigits, formatNumberNoGrouping, formatNumberValue, formatNumberDefaultValue)

{-| The **FormatNumber** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.FormatNumber`](Sl.Element.FormatNumber) as `formatNumber`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FormatNumberIs, FormatNumberAttrs, FormatNumberBuilder, FormatNumberAttrCaps, FormatNumberSlotCaps, FormatNumberChildAdmittedBy, FormatNumberCurrencyDisplay, FormatNumberType, formatNumber, formatNumberCurrencyDisplay, formatNumberType_, formatNumberCurrency, formatNumberMaximumFractionDigits, formatNumberMaximumSignificantDigits, formatNumberMinimumFractionDigits, formatNumberMinimumIntegerDigits, formatNumberMinimumSignificantDigits, formatNumberNoGrouping, formatNumberValue, formatNumberDefaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.FormatNumber as FormatNumber_


{-| The `formatNumber` element of this family — delegates to [`Sl.Element.FormatNumber.component`](Sl.Element.FormatNumber#component).
-}
formatNumber :
    List (Attr FormatNumberAttrs msg)
    -> List (Element childAccepts (FormatNumberChildAdmittedBy childAdm) msg)
    -> Element (FormatNumberIs s) admittedBy msg
formatNumber =
    FormatNumber_.component


{-| See [`Sl.Element.FormatNumber.Is`](Sl.Element.FormatNumber#Is).
-}
type alias FormatNumberIs s =
    FormatNumber_.Is s


{-| See [`Sl.Element.FormatNumber.Attrs`](Sl.Element.FormatNumber#Attrs).
-}
type alias FormatNumberAttrs =
    FormatNumber_.Attrs


{-| See [`Sl.Element.FormatNumber.Builder`](Sl.Element.FormatNumber#Builder).
-}
type alias FormatNumberBuilder attrCaps slotCaps msg kind =
    FormatNumber_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.FormatNumber.AttrCaps`](Sl.Element.FormatNumber#AttrCaps).
-}
type alias FormatNumberAttrCaps =
    FormatNumber_.AttrCaps


{-| See [`Sl.Element.FormatNumber.SlotCaps`](Sl.Element.FormatNumber#SlotCaps).
-}
type alias FormatNumberSlotCaps =
    FormatNumber_.SlotCaps


{-| See [`Sl.Element.FormatNumber.ChildAdmittedBy`](Sl.Element.FormatNumber#ChildAdmittedBy).
-}
type alias FormatNumberChildAdmittedBy childAdm =
    FormatNumber_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.FormatNumber.CurrencyDisplay`](Sl.Element.FormatNumber#CurrencyDisplay).
-}
type alias FormatNumberCurrencyDisplay =
    FormatNumber_.CurrencyDisplay


{-| See [`Sl.Element.FormatNumber.currencyDisplay`](Sl.Element.FormatNumber#currencyDisplay).
-}
formatNumberCurrencyDisplay : Value FormatNumberCurrencyDisplay -> Attr { c | currencyDisplay : Supported } msg
formatNumberCurrencyDisplay =
    FormatNumber_.currencyDisplay


{-| See [`Sl.Element.FormatNumber.Type`](Sl.Element.FormatNumber#Type).
-}
type alias FormatNumberType =
    FormatNumber_.Type


{-| See [`Sl.Element.FormatNumber.type_`](Sl.Element.FormatNumber#type_).
-}
formatNumberType_ : Value FormatNumberType -> Attr { c | type_ : Supported } msg
formatNumberType_ =
    FormatNumber_.type_


{-| See [`Sl.Element.FormatNumber.currency`](Sl.Element.FormatNumber#currency).
-}
formatNumberCurrency : String -> Attr { c | currency : Supported } msg
formatNumberCurrency =
    FormatNumber_.currency


{-| See [`Sl.Element.FormatNumber.maximumFractionDigits`](Sl.Element.FormatNumber#maximumFractionDigits).
-}
formatNumberMaximumFractionDigits : Float -> Attr { c | maximumFractionDigits : Supported } msg
formatNumberMaximumFractionDigits =
    FormatNumber_.maximumFractionDigits


{-| See [`Sl.Element.FormatNumber.maximumSignificantDigits`](Sl.Element.FormatNumber#maximumSignificantDigits).
-}
formatNumberMaximumSignificantDigits : Float -> Attr { c | maximumSignificantDigits : Supported } msg
formatNumberMaximumSignificantDigits =
    FormatNumber_.maximumSignificantDigits


{-| See [`Sl.Element.FormatNumber.minimumFractionDigits`](Sl.Element.FormatNumber#minimumFractionDigits).
-}
formatNumberMinimumFractionDigits : Float -> Attr { c | minimumFractionDigits : Supported } msg
formatNumberMinimumFractionDigits =
    FormatNumber_.minimumFractionDigits


{-| See [`Sl.Element.FormatNumber.minimumIntegerDigits`](Sl.Element.FormatNumber#minimumIntegerDigits).
-}
formatNumberMinimumIntegerDigits : Float -> Attr { c | minimumIntegerDigits : Supported } msg
formatNumberMinimumIntegerDigits =
    FormatNumber_.minimumIntegerDigits


{-| See [`Sl.Element.FormatNumber.minimumSignificantDigits`](Sl.Element.FormatNumber#minimumSignificantDigits).
-}
formatNumberMinimumSignificantDigits : Float -> Attr { c | minimumSignificantDigits : Supported } msg
formatNumberMinimumSignificantDigits =
    FormatNumber_.minimumSignificantDigits


{-| See [`Sl.Element.FormatNumber.noGrouping`](Sl.Element.FormatNumber#noGrouping).
-}
formatNumberNoGrouping : Bool -> Attr { c | noGrouping : Supported } msg
formatNumberNoGrouping =
    FormatNumber_.noGrouping


{-| See [`Sl.Element.FormatNumber.value`](Sl.Element.FormatNumber#value).
-}
formatNumberValue : Float -> Attr { c | value : Supported } msg
formatNumberValue =
    FormatNumber_.value


{-| See [`Sl.Element.FormatNumber.defaultValue`](Sl.Element.FormatNumber#defaultValue).
-}
formatNumberDefaultValue : Float -> Attr { c | value : Supported } msg
formatNumberDefaultValue =
    FormatNumber_.defaultValue

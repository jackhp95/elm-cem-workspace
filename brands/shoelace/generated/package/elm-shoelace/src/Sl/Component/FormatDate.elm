module Sl.Component.FormatDate exposing (FormatDateIs, FormatDateAttrs, FormatDateBuilder, FormatDateAttrCaps, FormatDateSlotCaps, FormatDateChildAdmittedBy, FormatDateDay, FormatDateEra, FormatDateHour, FormatDateHourFormat, FormatDateMinute, FormatDateMonth, FormatDateSecond, FormatDateTimeZoneName, FormatDateWeekday, FormatDateYear, formatDate, formatDateDay, formatDateEra, formatDateHour, formatDateHourFormat, formatDateMinute, formatDateMonth, formatDateSecond, formatDateTimeZoneName, formatDateWeekday, formatDateYear, formatDateDate, formatDateTimeZone)

{-| The **FormatDate** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.FormatDate`](Sl.Element.FormatDate) as `formatDate`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FormatDateIs, FormatDateAttrs, FormatDateBuilder, FormatDateAttrCaps, FormatDateSlotCaps, FormatDateChildAdmittedBy, FormatDateDay, FormatDateEra, FormatDateHour, FormatDateHourFormat, FormatDateMinute, FormatDateMonth, FormatDateSecond, FormatDateTimeZoneName, FormatDateWeekday, FormatDateYear, formatDate, formatDateDay, formatDateEra, formatDateHour, formatDateHourFormat, formatDateMinute, formatDateMonth, formatDateSecond, formatDateTimeZoneName, formatDateWeekday, formatDateYear, formatDateDate, formatDateTimeZone

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.FormatDate as FormatDate_


{-| The `formatDate` element of this family — delegates to [`Sl.Element.FormatDate.component`](Sl.Element.FormatDate#component).
-}
formatDate :
    List (Attr FormatDateAttrs msg)
    -> List (Element childAccepts (FormatDateChildAdmittedBy childAdm) msg)
    -> Element (FormatDateIs s) admittedBy msg
formatDate =
    FormatDate_.component


{-| See [`Sl.Element.FormatDate.Is`](Sl.Element.FormatDate#Is).
-}
type alias FormatDateIs s =
    FormatDate_.Is s


{-| See [`Sl.Element.FormatDate.Attrs`](Sl.Element.FormatDate#Attrs).
-}
type alias FormatDateAttrs =
    FormatDate_.Attrs


{-| See [`Sl.Element.FormatDate.Builder`](Sl.Element.FormatDate#Builder).
-}
type alias FormatDateBuilder attrCaps slotCaps msg kind =
    FormatDate_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.FormatDate.AttrCaps`](Sl.Element.FormatDate#AttrCaps).
-}
type alias FormatDateAttrCaps =
    FormatDate_.AttrCaps


{-| See [`Sl.Element.FormatDate.SlotCaps`](Sl.Element.FormatDate#SlotCaps).
-}
type alias FormatDateSlotCaps =
    FormatDate_.SlotCaps


{-| See [`Sl.Element.FormatDate.ChildAdmittedBy`](Sl.Element.FormatDate#ChildAdmittedBy).
-}
type alias FormatDateChildAdmittedBy childAdm =
    FormatDate_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.FormatDate.Day`](Sl.Element.FormatDate#Day).
-}
type alias FormatDateDay =
    FormatDate_.Day


{-| See [`Sl.Element.FormatDate.day`](Sl.Element.FormatDate#day).
-}
formatDateDay : Value FormatDateDay -> Attr { c | day : Supported } msg
formatDateDay =
    FormatDate_.day


{-| See [`Sl.Element.FormatDate.Era`](Sl.Element.FormatDate#Era).
-}
type alias FormatDateEra =
    FormatDate_.Era


{-| See [`Sl.Element.FormatDate.era`](Sl.Element.FormatDate#era).
-}
formatDateEra : Value FormatDateEra -> Attr { c | era : Supported } msg
formatDateEra =
    FormatDate_.era


{-| See [`Sl.Element.FormatDate.Hour`](Sl.Element.FormatDate#Hour).
-}
type alias FormatDateHour =
    FormatDate_.Hour


{-| See [`Sl.Element.FormatDate.hour`](Sl.Element.FormatDate#hour).
-}
formatDateHour : Value FormatDateHour -> Attr { c | hour : Supported } msg
formatDateHour =
    FormatDate_.hour


{-| See [`Sl.Element.FormatDate.HourFormat`](Sl.Element.FormatDate#HourFormat).
-}
type alias FormatDateHourFormat =
    FormatDate_.HourFormat


{-| See [`Sl.Element.FormatDate.hourFormat`](Sl.Element.FormatDate#hourFormat).
-}
formatDateHourFormat : Value FormatDateHourFormat -> Attr { c | hourFormat : Supported } msg
formatDateHourFormat =
    FormatDate_.hourFormat


{-| See [`Sl.Element.FormatDate.Minute`](Sl.Element.FormatDate#Minute).
-}
type alias FormatDateMinute =
    FormatDate_.Minute


{-| See [`Sl.Element.FormatDate.minute`](Sl.Element.FormatDate#minute).
-}
formatDateMinute : Value FormatDateMinute -> Attr { c | minute : Supported } msg
formatDateMinute =
    FormatDate_.minute


{-| See [`Sl.Element.FormatDate.Month`](Sl.Element.FormatDate#Month).
-}
type alias FormatDateMonth =
    FormatDate_.Month


{-| See [`Sl.Element.FormatDate.month`](Sl.Element.FormatDate#month).
-}
formatDateMonth : Value FormatDateMonth -> Attr { c | month : Supported } msg
formatDateMonth =
    FormatDate_.month


{-| See [`Sl.Element.FormatDate.Second`](Sl.Element.FormatDate#Second).
-}
type alias FormatDateSecond =
    FormatDate_.Second


{-| See [`Sl.Element.FormatDate.second`](Sl.Element.FormatDate#second).
-}
formatDateSecond : Value FormatDateSecond -> Attr { c | second : Supported } msg
formatDateSecond =
    FormatDate_.second


{-| See [`Sl.Element.FormatDate.TimeZoneName`](Sl.Element.FormatDate#TimeZoneName).
-}
type alias FormatDateTimeZoneName =
    FormatDate_.TimeZoneName


{-| See [`Sl.Element.FormatDate.timeZoneName`](Sl.Element.FormatDate#timeZoneName).
-}
formatDateTimeZoneName : Value FormatDateTimeZoneName -> Attr { c | timeZoneName : Supported } msg
formatDateTimeZoneName =
    FormatDate_.timeZoneName


{-| See [`Sl.Element.FormatDate.Weekday`](Sl.Element.FormatDate#Weekday).
-}
type alias FormatDateWeekday =
    FormatDate_.Weekday


{-| See [`Sl.Element.FormatDate.weekday`](Sl.Element.FormatDate#weekday).
-}
formatDateWeekday : Value FormatDateWeekday -> Attr { c | weekday : Supported } msg
formatDateWeekday =
    FormatDate_.weekday


{-| See [`Sl.Element.FormatDate.Year`](Sl.Element.FormatDate#Year).
-}
type alias FormatDateYear =
    FormatDate_.Year


{-| See [`Sl.Element.FormatDate.year`](Sl.Element.FormatDate#year).
-}
formatDateYear : Value FormatDateYear -> Attr { c | year : Supported } msg
formatDateYear =
    FormatDate_.year


{-| See [`Sl.Element.FormatDate.date`](Sl.Element.FormatDate#date).
-}
formatDateDate : String -> Attr { c | date : Supported } msg
formatDateDate =
    FormatDate_.date


{-| See [`Sl.Element.FormatDate.timeZone`](Sl.Element.FormatDate#timeZone).
-}
formatDateTimeZone : String -> Attr { c | timeZone : Supported } msg
formatDateTimeZone =
    FormatDate_.timeZone

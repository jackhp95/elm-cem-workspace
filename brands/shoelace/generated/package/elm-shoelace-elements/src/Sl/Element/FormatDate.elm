module Sl.Element.FormatDate exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Day, day, Era, era, Hour, hour, HourFormat, hourFormat, Minute, minute, Month, month, Second, second, TimeZoneName, timeZoneName, Weekday, weekday, Year, year
    , date, timeZone
    )

{-| The `sl-format-date` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Day, day, Era, era, Hour, hour, HourFormat, hourFormat, Minute, minute, Month, month, Second, second, TimeZoneName, timeZoneName, Weekday, weekday, Year, year
@docs date, timeZone

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.FormatDate
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-format-date` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.FormatDate.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.FormatDate.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.FormatDate.ChildAdmittedBy childAdm


{-| The `day` values valid on this component (compile-tight narrowing).
-}
type alias Day =
    Sl.Internal.Types.FormatDate.Day


{-| The `era` values valid on this component (compile-tight narrowing).
-}
type alias Era =
    Sl.Internal.Types.FormatDate.Era


{-| The `hour` values valid on this component (compile-tight narrowing).
-}
type alias Hour =
    Sl.Internal.Types.FormatDate.Hour


{-| The `hourFormat` values valid on this component (compile-tight narrowing).
-}
type alias HourFormat =
    Sl.Internal.Types.FormatDate.HourFormat


{-| The `minute` values valid on this component (compile-tight narrowing).
-}
type alias Minute =
    Sl.Internal.Types.FormatDate.Minute


{-| The `month` values valid on this component (compile-tight narrowing).
-}
type alias Month =
    Sl.Internal.Types.FormatDate.Month


{-| The `second` values valid on this component (compile-tight narrowing).
-}
type alias Second =
    Sl.Internal.Types.FormatDate.Second


{-| The `timeZoneName` values valid on this component (compile-tight narrowing).
-}
type alias TimeZoneName =
    Sl.Internal.Types.FormatDate.TimeZoneName


{-| The `weekday` values valid on this component (compile-tight narrowing).
-}
type alias Weekday =
    Sl.Internal.Types.FormatDate.Weekday


{-| The `year` values valid on this component (compile-tight narrowing).
-}
type alias Year =
    Sl.Internal.Types.FormatDate.Year


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.FormatDate.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.FormatDate.AttrCaps


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
    H.formatDate


{-| The format for displaying the day.
-}
day : Value Day -> Attr { c | day : Supported } msg
day value_ =
    Ir.attribute "day" (Val.toString value_)


{-| The format for displaying the era.
-}
era : Value Era -> Attr { c | era : Supported } msg
era value_ =
    Ir.attribute "era" (Val.toString value_)


{-| The format for displaying the hour.
-}
hour : Value Hour -> Attr { c | hour : Supported } msg
hour value_ =
    Ir.attribute "hour" (Val.toString value_)


{-| The format for displaying the hour. (default: `'auto'`)
-}
hourFormat : Value HourFormat -> Attr { c | hourFormat : Supported } msg
hourFormat value_ =
    Ir.attribute "hour-format" (Val.toString value_)


{-| The format for displaying the minute.
-}
minute : Value Minute -> Attr { c | minute : Supported } msg
minute value_ =
    Ir.attribute "minute" (Val.toString value_)


{-| The format for displaying the month.
-}
month : Value Month -> Attr { c | month : Supported } msg
month value_ =
    Ir.attribute "month" (Val.toString value_)


{-| The format for displaying the second.
-}
second : Value Second -> Attr { c | second : Supported } msg
second value_ =
    Ir.attribute "second" (Val.toString value_)


{-| The format for displaying the time.
-}
timeZoneName : Value TimeZoneName -> Attr { c | timeZoneName : Supported } msg
timeZoneName value_ =
    Ir.attribute "time-zone-name" (Val.toString value_)


{-| The format for displaying the weekday.
-}
weekday : Value Weekday -> Attr { c | weekday : Supported } msg
weekday value_ =
    Ir.attribute "weekday" (Val.toString value_)


{-| The format for displaying the year.
-}
year : Value Year -> Attr { c | year : Supported } msg
year value_ =
    Ir.attribute "year" (Val.toString value_)


{-| See `Sl.Attributes.date`.
-}
date : String -> Attr { c | date : Supported } msg
date =
    A.date


{-| See `Sl.Attributes.timeZone`.
-}
timeZone : String -> Attr { c | timeZone : Supported } msg
timeZone =
    A.timeZone

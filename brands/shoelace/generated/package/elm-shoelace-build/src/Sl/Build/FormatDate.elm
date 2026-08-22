module Sl.Build.FormatDate exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDate, withDay, withEra, withHour, withHourFormat, withId, withMinute, withMonth, withSecond, withSlot, withStyle, withTimeZone, withTimeZoneName, withWeekday, withYear)

{-| The **FormatDate** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.FormatDate`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDate, withDay, withEra, withHour, withHourFormat, withId, withMinute, withMonth, withSecond, withSlot, withStyle, withTimeZone, withTimeZoneName, withWeekday, withYear

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.FormatDate as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.FormatDateIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.FormatDateBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.FormatDateAttrCaps


{-| -}
type alias SlotCaps =
    Component.FormatDateSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.FormatDateChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-format-date" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.FormatDateIs kind) admittedBy msg
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
withDate : String -> Builder { a | date : Available } slotCaps msg kind -> Builder { a | date : Used } slotCaps msg kind
withDate value_ =
    B.withAttribute (A.date value_)


{-| -}
withDay : Value Component.FormatDateDay -> Builder { a | day : Available } slotCaps msg kind -> Builder { a | day : Used } slotCaps msg kind
withDay value_ =
    B.withAttribute (Component.formatDateDay value_)


{-| -}
withEra : Value Component.FormatDateEra -> Builder { a | era : Available } slotCaps msg kind -> Builder { a | era : Used } slotCaps msg kind
withEra value_ =
    B.withAttribute (Component.formatDateEra value_)


{-| -}
withHour : Value Component.FormatDateHour -> Builder { a | hour : Available } slotCaps msg kind -> Builder { a | hour : Used } slotCaps msg kind
withHour value_ =
    B.withAttribute (Component.formatDateHour value_)


{-| -}
withHourFormat : Value Component.FormatDateHourFormat -> Builder { a | hourFormat : Available } slotCaps msg kind -> Builder { a | hourFormat : Used } slotCaps msg kind
withHourFormat value_ =
    B.withAttribute (Component.formatDateHourFormat value_)


{-| -}
withMinute : Value Component.FormatDateMinute -> Builder { a | minute : Available } slotCaps msg kind -> Builder { a | minute : Used } slotCaps msg kind
withMinute value_ =
    B.withAttribute (Component.formatDateMinute value_)


{-| -}
withMonth : Value Component.FormatDateMonth -> Builder { a | month : Available } slotCaps msg kind -> Builder { a | month : Used } slotCaps msg kind
withMonth value_ =
    B.withAttribute (Component.formatDateMonth value_)


{-| -}
withSecond : Value Component.FormatDateSecond -> Builder { a | second : Available } slotCaps msg kind -> Builder { a | second : Used } slotCaps msg kind
withSecond value_ =
    B.withAttribute (Component.formatDateSecond value_)


{-| -}
withTimeZone : String -> Builder { a | timeZone : Available } slotCaps msg kind -> Builder { a | timeZone : Used } slotCaps msg kind
withTimeZone value_ =
    B.withAttribute (A.timeZone value_)


{-| -}
withTimeZoneName : Value Component.FormatDateTimeZoneName -> Builder { a | timeZoneName : Available } slotCaps msg kind -> Builder { a | timeZoneName : Used } slotCaps msg kind
withTimeZoneName value_ =
    B.withAttribute (Component.formatDateTimeZoneName value_)


{-| -}
withWeekday : Value Component.FormatDateWeekday -> Builder { a | weekday : Available } slotCaps msg kind -> Builder { a | weekday : Used } slotCaps msg kind
withWeekday value_ =
    B.withAttribute (Component.formatDateWeekday value_)


{-| -}
withYear : Value Component.FormatDateYear -> Builder { a | year : Available } slotCaps msg kind -> Builder { a | year : Used } slotCaps msg kind
withYear value_ =
    B.withAttribute (Component.formatDateYear value_)

module M3e.Build.Calendar exposing (CalendarBuilder, CalendarAttrCaps, CalendarSlotCaps, CalendarIs, CalendarChildAdmittedBy, calendarBuild, calendarToElement, calendarWithClass, calendarWithDate, calendarWithId, calendarWithMaxDate, calendarWithMinDate, calendarWithNextMonthLabel, calendarWithNextMultiYearLabel, calendarWithNextYearLabel, calendarWithOnChange, calendarWithPreviousMonthLabel, calendarWithPreviousMultiYearLabel, calendarWithPreviousYearLabel, calendarWithRangeEnd, calendarWithRangeStart, calendarWithSlot, calendarWithStartAt, calendarWithStartView, calendarWithStyle, calendarHeader, calendarWithHeader, MonthViewBuilder, MonthViewAttrCaps, MonthViewSlotCaps, MonthViewIs, MonthViewChildAdmittedBy, monthViewBuild, monthViewToElement, monthViewWithActive, monthViewWithActiveDate, monthViewWithClass, monthViewWithDate, monthViewWithId, monthViewWithMaxDate, monthViewWithMinDate, monthViewWithOnActiveChange, monthViewWithOnChange, monthViewWithRangeEnd, monthViewWithRangeStart, monthViewWithSlot, monthViewWithStyle, monthViewWithToday, YearViewBuilder, YearViewAttrCaps, YearViewSlotCaps, YearViewIs, YearViewChildAdmittedBy, yearViewBuild, yearViewToElement, yearViewWithActive, yearViewWithActiveDate, yearViewWithClass, yearViewWithDate, yearViewWithId, yearViewWithMaxDate, yearViewWithMinDate, yearViewWithOnActiveChange, yearViewWithOnChange, yearViewWithSlot, yearViewWithStyle, yearViewWithToday, MultiYearViewBuilder, MultiYearViewAttrCaps, MultiYearViewSlotCaps, MultiYearViewIs, MultiYearViewChildAdmittedBy, multiYearViewBuild, multiYearViewToElement, multiYearViewWithActive, multiYearViewWithActiveDate, multiYearViewWithClass, multiYearViewWithDate, multiYearViewWithId, multiYearViewWithMaxDate, multiYearViewWithMinDate, multiYearViewWithOnActiveChange, multiYearViewWithOnChange, multiYearViewWithSlot, multiYearViewWithStyle, multiYearViewWithToday)

{-| The **Calendar** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Calendar`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs CalendarBuilder, CalendarAttrCaps, CalendarSlotCaps, CalendarIs, CalendarChildAdmittedBy, calendarBuild, calendarToElement, calendarWithClass, calendarWithDate, calendarWithId, calendarWithMaxDate, calendarWithMinDate, calendarWithNextMonthLabel, calendarWithNextMultiYearLabel, calendarWithNextYearLabel, calendarWithOnChange, calendarWithPreviousMonthLabel, calendarWithPreviousMultiYearLabel, calendarWithPreviousYearLabel, calendarWithRangeEnd, calendarWithRangeStart, calendarWithSlot, calendarWithStartAt, calendarWithStartView, calendarWithStyle, calendarHeader, calendarWithHeader, MonthViewBuilder, MonthViewAttrCaps, MonthViewSlotCaps, MonthViewIs, MonthViewChildAdmittedBy, monthViewBuild, monthViewToElement, monthViewWithActive, monthViewWithActiveDate, monthViewWithClass, monthViewWithDate, monthViewWithId, monthViewWithMaxDate, monthViewWithMinDate, monthViewWithOnActiveChange, monthViewWithOnChange, monthViewWithRangeEnd, monthViewWithRangeStart, monthViewWithSlot, monthViewWithStyle, monthViewWithToday, YearViewBuilder, YearViewAttrCaps, YearViewSlotCaps, YearViewIs, YearViewChildAdmittedBy, yearViewBuild, yearViewToElement, yearViewWithActive, yearViewWithActiveDate, yearViewWithClass, yearViewWithDate, yearViewWithId, yearViewWithMaxDate, yearViewWithMinDate, yearViewWithOnActiveChange, yearViewWithOnChange, yearViewWithSlot, yearViewWithStyle, yearViewWithToday, MultiYearViewBuilder, MultiYearViewAttrCaps, MultiYearViewSlotCaps, MultiYearViewIs, MultiYearViewChildAdmittedBy, multiYearViewBuild, multiYearViewToElement, multiYearViewWithActive, multiYearViewWithActiveDate, multiYearViewWithClass, multiYearViewWithDate, multiYearViewWithId, multiYearViewWithMaxDate, multiYearViewWithMinDate, multiYearViewWithOnActiveChange, multiYearViewWithOnChange, multiYearViewWithSlot, multiYearViewWithStyle, multiYearViewWithToday

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Calendar as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias CalendarIs s =
    Component.CalendarIs s


{-| -}
type alias CalendarBuilder attrCaps slotCaps msg kind =
    Component.CalendarBuilder attrCaps slotCaps msg kind


{-| -}
type alias CalendarAttrCaps =
    Component.CalendarAttrCaps


{-| -}
type alias CalendarSlotCaps =
    Component.CalendarSlotCaps


{-| -}
type alias CalendarChildAdmittedBy childAdm =
    Component.CalendarChildAdmittedBy childAdm


{-| -}
calendarBuild : CalendarBuilder CalendarAttrCaps CalendarSlotCaps msg kind
calendarBuild =
    B.init "m3e-calendar" [] []


{-| -}
calendarToElement : CalendarBuilder attrCaps slotCaps msg kind -> Element (Component.CalendarIs kind) admittedBy msg
calendarToElement =
    B.toElement


{-| -}
calendarHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
calendarHeader builder =
    Component.calendarHeader (B.toElement builder)


{-| -}
calendarWithHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> CalendarBuilder attrCaps { s | header : Available } msg kind
    -> CalendarBuilder attrCaps { s | header : Used } msg kind
calendarWithHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.calendarHeader (B.toElement slotBuilder))) builder_


{-| -}
calendarWithClass : String -> CalendarBuilder { a | class : Available } slotCaps msg kind -> CalendarBuilder { a | class : Used } slotCaps msg kind
calendarWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
calendarWithId : String -> CalendarBuilder { a | id : Available } slotCaps msg kind -> CalendarBuilder { a | id : Used } slotCaps msg kind
calendarWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
calendarWithSlot : String -> CalendarBuilder { a | slot : Available } slotCaps msg kind -> CalendarBuilder { a | slot : Used } slotCaps msg kind
calendarWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
calendarWithStyle : String -> String -> CalendarBuilder { a | style : Available } slotCaps msg kind -> CalendarBuilder { a | style : Used } slotCaps msg kind
calendarWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
calendarWithDate : String -> CalendarBuilder { a | date : Available } slotCaps msg kind -> CalendarBuilder { a | date : Used } slotCaps msg kind
calendarWithDate value_ =
    B.withAttribute (A.date value_)


{-| -}
calendarWithMaxDate : String -> CalendarBuilder { a | maxDate : Available } slotCaps msg kind -> CalendarBuilder { a | maxDate : Used } slotCaps msg kind
calendarWithMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
calendarWithMinDate : String -> CalendarBuilder { a | minDate : Available } slotCaps msg kind -> CalendarBuilder { a | minDate : Used } slotCaps msg kind
calendarWithMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
calendarWithNextMonthLabel : String -> CalendarBuilder { a | nextMonthLabel : Available } slotCaps msg kind -> CalendarBuilder { a | nextMonthLabel : Used } slotCaps msg kind
calendarWithNextMonthLabel value_ =
    B.withAttribute (A.nextMonthLabel value_)


{-| -}
calendarWithNextMultiYearLabel : String -> CalendarBuilder { a | nextMultiYearLabel : Available } slotCaps msg kind -> CalendarBuilder { a | nextMultiYearLabel : Used } slotCaps msg kind
calendarWithNextMultiYearLabel value_ =
    B.withAttribute (A.nextMultiYearLabel value_)


{-| -}
calendarWithNextYearLabel : String -> CalendarBuilder { a | nextYearLabel : Available } slotCaps msg kind -> CalendarBuilder { a | nextYearLabel : Used } slotCaps msg kind
calendarWithNextYearLabel value_ =
    B.withAttribute (A.nextYearLabel value_)


{-| -}
calendarWithPreviousMonthLabel : String -> CalendarBuilder { a | previousMonthLabel : Available } slotCaps msg kind -> CalendarBuilder { a | previousMonthLabel : Used } slotCaps msg kind
calendarWithPreviousMonthLabel value_ =
    B.withAttribute (A.previousMonthLabel value_)


{-| -}
calendarWithPreviousMultiYearLabel : String -> CalendarBuilder { a | previousMultiYearLabel : Available } slotCaps msg kind -> CalendarBuilder { a | previousMultiYearLabel : Used } slotCaps msg kind
calendarWithPreviousMultiYearLabel value_ =
    B.withAttribute (A.previousMultiYearLabel value_)


{-| -}
calendarWithPreviousYearLabel : String -> CalendarBuilder { a | previousYearLabel : Available } slotCaps msg kind -> CalendarBuilder { a | previousYearLabel : Used } slotCaps msg kind
calendarWithPreviousYearLabel value_ =
    B.withAttribute (A.previousYearLabel value_)


{-| -}
calendarWithRangeEnd : String -> CalendarBuilder { a | rangeEnd : Available } slotCaps msg kind -> CalendarBuilder { a | rangeEnd : Used } slotCaps msg kind
calendarWithRangeEnd value_ =
    B.withAttribute (A.rangeEnd value_)


{-| -}
calendarWithRangeStart : String -> CalendarBuilder { a | rangeStart : Available } slotCaps msg kind -> CalendarBuilder { a | rangeStart : Used } slotCaps msg kind
calendarWithRangeStart value_ =
    B.withAttribute (A.rangeStart value_)


{-| -}
calendarWithStartAt : String -> CalendarBuilder { a | startAt : Available } slotCaps msg kind -> CalendarBuilder { a | startAt : Used } slotCaps msg kind
calendarWithStartAt value_ =
    B.withAttribute (A.startAt value_)


{-| -}
calendarWithStartView : Value Component.CalendarStartView -> CalendarBuilder { a | startView : Available } slotCaps msg kind -> CalendarBuilder { a | startView : Used } slotCaps msg kind
calendarWithStartView value_ =
    B.withAttribute (Component.calendarStartView value_)


{-| -}
calendarWithOnChange : (String -> msg) -> CalendarBuilder { a | onChange : Available } slotCaps msg kind -> CalendarBuilder { a | onChange : Used } slotCaps msg kind
calendarWithOnChange value_ =
    B.withAttribute (Component.calendarOnChange value_)


{-| -}
type alias MonthViewIs s =
    Component.MonthViewIs s


{-| -}
type alias MonthViewBuilder attrCaps slotCaps msg kind =
    Component.MonthViewBuilder attrCaps slotCaps msg kind


{-| -}
type alias MonthViewAttrCaps =
    Component.MonthViewAttrCaps


{-| -}
type alias MonthViewSlotCaps =
    Component.MonthViewSlotCaps


{-| -}
type alias MonthViewChildAdmittedBy childAdm =
    Component.MonthViewChildAdmittedBy childAdm


{-| -}
monthViewBuild : MonthViewBuilder MonthViewAttrCaps MonthViewSlotCaps msg kind
monthViewBuild =
    B.init "m3e-month-view" [] []


{-| -}
monthViewToElement : MonthViewBuilder attrCaps slotCaps msg kind -> Element (Component.MonthViewIs kind) admittedBy msg
monthViewToElement =
    B.toElement


{-| -}
monthViewWithClass : String -> MonthViewBuilder { a | class : Available } slotCaps msg kind -> MonthViewBuilder { a | class : Used } slotCaps msg kind
monthViewWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
monthViewWithId : String -> MonthViewBuilder { a | id : Available } slotCaps msg kind -> MonthViewBuilder { a | id : Used } slotCaps msg kind
monthViewWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
monthViewWithSlot : String -> MonthViewBuilder { a | slot : Available } slotCaps msg kind -> MonthViewBuilder { a | slot : Used } slotCaps msg kind
monthViewWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
monthViewWithStyle : String -> String -> MonthViewBuilder { a | style : Available } slotCaps msg kind -> MonthViewBuilder { a | style : Used } slotCaps msg kind
monthViewWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
monthViewWithActive : Bool -> MonthViewBuilder { a | active : Available } slotCaps msg kind -> MonthViewBuilder { a | active : Used } slotCaps msg kind
monthViewWithActive value_ =
    B.withAttribute (A.active value_)


{-| -}
monthViewWithActiveDate : String -> MonthViewBuilder { a | activeDate : Available } slotCaps msg kind -> MonthViewBuilder { a | activeDate : Used } slotCaps msg kind
monthViewWithActiveDate value_ =
    B.withAttribute (A.activeDate value_)


{-| -}
monthViewWithDate : String -> MonthViewBuilder { a | date : Available } slotCaps msg kind -> MonthViewBuilder { a | date : Used } slotCaps msg kind
monthViewWithDate value_ =
    B.withAttribute (A.date value_)


{-| -}
monthViewWithMaxDate : String -> MonthViewBuilder { a | maxDate : Available } slotCaps msg kind -> MonthViewBuilder { a | maxDate : Used } slotCaps msg kind
monthViewWithMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
monthViewWithMinDate : String -> MonthViewBuilder { a | minDate : Available } slotCaps msg kind -> MonthViewBuilder { a | minDate : Used } slotCaps msg kind
monthViewWithMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
monthViewWithRangeEnd : String -> MonthViewBuilder { a | rangeEnd : Available } slotCaps msg kind -> MonthViewBuilder { a | rangeEnd : Used } slotCaps msg kind
monthViewWithRangeEnd value_ =
    B.withAttribute (A.rangeEnd value_)


{-| -}
monthViewWithRangeStart : String -> MonthViewBuilder { a | rangeStart : Available } slotCaps msg kind -> MonthViewBuilder { a | rangeStart : Used } slotCaps msg kind
monthViewWithRangeStart value_ =
    B.withAttribute (A.rangeStart value_)


{-| -}
monthViewWithToday : String -> MonthViewBuilder { a | today : Available } slotCaps msg kind -> MonthViewBuilder { a | today : Used } slotCaps msg kind
monthViewWithToday value_ =
    B.withAttribute (A.today value_)


{-| -}
monthViewWithOnChange : msg -> MonthViewBuilder { a | onChange : Available } slotCaps msg kind -> MonthViewBuilder { a | onChange : Used } slotCaps msg kind
monthViewWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
monthViewWithOnActiveChange : msg -> MonthViewBuilder { a | onActiveChange : Available } slotCaps msg kind -> MonthViewBuilder { a | onActiveChange : Used } slotCaps msg kind
monthViewWithOnActiveChange value_ =
    B.withAttribute (Ev.onActiveChange value_)


{-| -}
type alias YearViewIs s =
    Component.YearViewIs s


{-| -}
type alias YearViewBuilder attrCaps slotCaps msg kind =
    Component.YearViewBuilder attrCaps slotCaps msg kind


{-| -}
type alias YearViewAttrCaps =
    Component.YearViewAttrCaps


{-| -}
type alias YearViewSlotCaps =
    Component.YearViewSlotCaps


{-| -}
type alias YearViewChildAdmittedBy childAdm =
    Component.YearViewChildAdmittedBy childAdm


{-| -}
yearViewBuild : YearViewBuilder YearViewAttrCaps YearViewSlotCaps msg kind
yearViewBuild =
    B.init "m3e-year-view" [] []


{-| -}
yearViewToElement : YearViewBuilder attrCaps slotCaps msg kind -> Element (Component.YearViewIs kind) admittedBy msg
yearViewToElement =
    B.toElement


{-| -}
yearViewWithClass : String -> YearViewBuilder { a | class : Available } slotCaps msg kind -> YearViewBuilder { a | class : Used } slotCaps msg kind
yearViewWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
yearViewWithId : String -> YearViewBuilder { a | id : Available } slotCaps msg kind -> YearViewBuilder { a | id : Used } slotCaps msg kind
yearViewWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
yearViewWithSlot : String -> YearViewBuilder { a | slot : Available } slotCaps msg kind -> YearViewBuilder { a | slot : Used } slotCaps msg kind
yearViewWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
yearViewWithStyle : String -> String -> YearViewBuilder { a | style : Available } slotCaps msg kind -> YearViewBuilder { a | style : Used } slotCaps msg kind
yearViewWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
yearViewWithActive : Bool -> YearViewBuilder { a | active : Available } slotCaps msg kind -> YearViewBuilder { a | active : Used } slotCaps msg kind
yearViewWithActive value_ =
    B.withAttribute (A.active value_)


{-| -}
yearViewWithActiveDate : String -> YearViewBuilder { a | activeDate : Available } slotCaps msg kind -> YearViewBuilder { a | activeDate : Used } slotCaps msg kind
yearViewWithActiveDate value_ =
    B.withAttribute (A.activeDate value_)


{-| -}
yearViewWithDate : String -> YearViewBuilder { a | date : Available } slotCaps msg kind -> YearViewBuilder { a | date : Used } slotCaps msg kind
yearViewWithDate value_ =
    B.withAttribute (A.date value_)


{-| -}
yearViewWithMaxDate : String -> YearViewBuilder { a | maxDate : Available } slotCaps msg kind -> YearViewBuilder { a | maxDate : Used } slotCaps msg kind
yearViewWithMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
yearViewWithMinDate : String -> YearViewBuilder { a | minDate : Available } slotCaps msg kind -> YearViewBuilder { a | minDate : Used } slotCaps msg kind
yearViewWithMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
yearViewWithToday : String -> YearViewBuilder { a | today : Available } slotCaps msg kind -> YearViewBuilder { a | today : Used } slotCaps msg kind
yearViewWithToday value_ =
    B.withAttribute (A.today value_)


{-| -}
yearViewWithOnChange : msg -> YearViewBuilder { a | onChange : Available } slotCaps msg kind -> YearViewBuilder { a | onChange : Used } slotCaps msg kind
yearViewWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
yearViewWithOnActiveChange : msg -> YearViewBuilder { a | onActiveChange : Available } slotCaps msg kind -> YearViewBuilder { a | onActiveChange : Used } slotCaps msg kind
yearViewWithOnActiveChange value_ =
    B.withAttribute (Ev.onActiveChange value_)


{-| -}
type alias MultiYearViewIs s =
    Component.MultiYearViewIs s


{-| -}
type alias MultiYearViewBuilder attrCaps slotCaps msg kind =
    Component.MultiYearViewBuilder attrCaps slotCaps msg kind


{-| -}
type alias MultiYearViewAttrCaps =
    Component.MultiYearViewAttrCaps


{-| -}
type alias MultiYearViewSlotCaps =
    Component.MultiYearViewSlotCaps


{-| -}
type alias MultiYearViewChildAdmittedBy childAdm =
    Component.MultiYearViewChildAdmittedBy childAdm


{-| -}
multiYearViewBuild : MultiYearViewBuilder MultiYearViewAttrCaps MultiYearViewSlotCaps msg kind
multiYearViewBuild =
    B.init "m3e-multi-year-view" [] []


{-| -}
multiYearViewToElement : MultiYearViewBuilder attrCaps slotCaps msg kind -> Element (Component.MultiYearViewIs kind) admittedBy msg
multiYearViewToElement =
    B.toElement


{-| -}
multiYearViewWithClass : String -> MultiYearViewBuilder { a | class : Available } slotCaps msg kind -> MultiYearViewBuilder { a | class : Used } slotCaps msg kind
multiYearViewWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
multiYearViewWithId : String -> MultiYearViewBuilder { a | id : Available } slotCaps msg kind -> MultiYearViewBuilder { a | id : Used } slotCaps msg kind
multiYearViewWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
multiYearViewWithSlot : String -> MultiYearViewBuilder { a | slot : Available } slotCaps msg kind -> MultiYearViewBuilder { a | slot : Used } slotCaps msg kind
multiYearViewWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
multiYearViewWithStyle : String -> String -> MultiYearViewBuilder { a | style : Available } slotCaps msg kind -> MultiYearViewBuilder { a | style : Used } slotCaps msg kind
multiYearViewWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
multiYearViewWithActive : Bool -> MultiYearViewBuilder { a | active : Available } slotCaps msg kind -> MultiYearViewBuilder { a | active : Used } slotCaps msg kind
multiYearViewWithActive value_ =
    B.withAttribute (A.active value_)


{-| -}
multiYearViewWithActiveDate : String -> MultiYearViewBuilder { a | activeDate : Available } slotCaps msg kind -> MultiYearViewBuilder { a | activeDate : Used } slotCaps msg kind
multiYearViewWithActiveDate value_ =
    B.withAttribute (A.activeDate value_)


{-| -}
multiYearViewWithDate : String -> MultiYearViewBuilder { a | date : Available } slotCaps msg kind -> MultiYearViewBuilder { a | date : Used } slotCaps msg kind
multiYearViewWithDate value_ =
    B.withAttribute (A.date value_)


{-| -}
multiYearViewWithMaxDate : String -> MultiYearViewBuilder { a | maxDate : Available } slotCaps msg kind -> MultiYearViewBuilder { a | maxDate : Used } slotCaps msg kind
multiYearViewWithMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
multiYearViewWithMinDate : String -> MultiYearViewBuilder { a | minDate : Available } slotCaps msg kind -> MultiYearViewBuilder { a | minDate : Used } slotCaps msg kind
multiYearViewWithMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
multiYearViewWithToday : String -> MultiYearViewBuilder { a | today : Available } slotCaps msg kind -> MultiYearViewBuilder { a | today : Used } slotCaps msg kind
multiYearViewWithToday value_ =
    B.withAttribute (A.today value_)


{-| -}
multiYearViewWithOnChange : msg -> MultiYearViewBuilder { a | onChange : Available } slotCaps msg kind -> MultiYearViewBuilder { a | onChange : Used } slotCaps msg kind
multiYearViewWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
multiYearViewWithOnActiveChange : msg -> MultiYearViewBuilder { a | onActiveChange : Available } slotCaps msg kind -> MultiYearViewBuilder { a | onActiveChange : Used } slotCaps msg kind
multiYearViewWithOnActiveChange value_ =
    B.withAttribute (Ev.onActiveChange value_)

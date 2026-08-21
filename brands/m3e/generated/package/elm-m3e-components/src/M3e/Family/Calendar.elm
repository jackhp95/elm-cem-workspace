module M3e.Family.Calendar exposing (CalendarIs, CalendarAttrs, CalendarBuilder, CalendarAttrCaps, CalendarSlotCaps, CalendarChildAdmittedBy, CalendarStartView, MonthViewIs, MonthViewAttrs, MonthViewBuilder, MonthViewAttrCaps, MonthViewSlotCaps, MonthViewChildAdmittedBy, YearViewIs, YearViewAttrs, YearViewBuilder, YearViewAttrCaps, YearViewSlotCaps, YearViewChildAdmittedBy, MultiYearViewIs, MultiYearViewAttrs, MultiYearViewBuilder, MultiYearViewAttrCaps, MultiYearViewSlotCaps, MultiYearViewChildAdmittedBy, calendar, calendarStartView, calendarDate, calendarMaxDate, calendarMinDate, calendarNextMonthLabel, calendarNextMultiYearLabel, calendarNextYearLabel, calendarPreviousMonthLabel, calendarPreviousMultiYearLabel, calendarPreviousYearLabel, calendarRangeEnd, calendarRangeStart, calendarStartAt, calendarOnChange, calendarHeader, monthView, monthViewActive, monthViewActiveDate, monthViewDate, monthViewMaxDate, monthViewMinDate, monthViewRangeEnd, monthViewRangeStart, monthViewToday, monthViewOnChange, monthViewOnActiveChange, yearView, yearViewActive, yearViewActiveDate, yearViewDate, yearViewMaxDate, yearViewMinDate, yearViewToday, yearViewOnChange, yearViewOnActiveChange, multiYearView, multiYearViewActive, multiYearViewActiveDate, multiYearViewDate, multiYearViewMaxDate, multiYearViewMinDate, multiYearViewToday, multiYearViewOnChange, multiYearViewOnActiveChange)

{-| The **Calendar** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Calendar`](M3e.Component.Calendar) as `calendar`, [`M3e.Component.MonthView`](M3e.Component.MonthView) as `monthView`, [`M3e.Component.YearView`](M3e.Component.YearView) as `yearView`, [`M3e.Component.MultiYearView`](M3e.Component.MultiYearView) as `multiYearView`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs CalendarIs, CalendarAttrs, CalendarBuilder, CalendarAttrCaps, CalendarSlotCaps, CalendarChildAdmittedBy, CalendarStartView, MonthViewIs, MonthViewAttrs, MonthViewBuilder, MonthViewAttrCaps, MonthViewSlotCaps, MonthViewChildAdmittedBy, YearViewIs, YearViewAttrs, YearViewBuilder, YearViewAttrCaps, YearViewSlotCaps, YearViewChildAdmittedBy, MultiYearViewIs, MultiYearViewAttrs, MultiYearViewBuilder, MultiYearViewAttrCaps, MultiYearViewSlotCaps, MultiYearViewChildAdmittedBy, calendar, calendarStartView, calendarDate, calendarMaxDate, calendarMinDate, calendarNextMonthLabel, calendarNextMultiYearLabel, calendarNextYearLabel, calendarPreviousMonthLabel, calendarPreviousMultiYearLabel, calendarPreviousYearLabel, calendarRangeEnd, calendarRangeStart, calendarStartAt, calendarOnChange, calendarHeader, monthView, monthViewActive, monthViewActiveDate, monthViewDate, monthViewMaxDate, monthViewMinDate, monthViewRangeEnd, monthViewRangeStart, monthViewToday, monthViewOnChange, monthViewOnActiveChange, yearView, yearViewActive, yearViewActiveDate, yearViewDate, yearViewMaxDate, yearViewMinDate, yearViewToday, yearViewOnChange, yearViewOnActiveChange, multiYearView, multiYearViewActive, multiYearViewActiveDate, multiYearViewDate, multiYearViewMaxDate, multiYearViewMinDate, multiYearViewToday, multiYearViewOnChange, multiYearViewOnActiveChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Calendar as Calendar_
import M3e.Component.MonthView as MonthView_
import M3e.Component.MultiYearView as MultiYearView_
import M3e.Component.YearView as YearView_


{-| The `calendar` element of this family — delegates to [`M3e.Component.Calendar.component`](M3e.Component.Calendar#component).
-}
calendar :
    List (Attr CalendarAttrs msg)
    -> List (Element childAccepts (CalendarChildAdmittedBy childAdm) msg)
    -> Element (CalendarIs s) admittedBy msg
calendar =
    Calendar_.component


{-| See [`M3e.Component.Calendar.Is`](M3e.Component.Calendar#Is).
-}
type alias CalendarIs s =
    Calendar_.Is s


{-| See [`M3e.Component.Calendar.Attrs`](M3e.Component.Calendar#Attrs).
-}
type alias CalendarAttrs =
    Calendar_.Attrs


{-| See [`M3e.Component.Calendar.Builder`](M3e.Component.Calendar#Builder).
-}
type alias CalendarBuilder attrCaps slotCaps msg kind =
    Calendar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Calendar.AttrCaps`](M3e.Component.Calendar#AttrCaps).
-}
type alias CalendarAttrCaps =
    Calendar_.AttrCaps


{-| See [`M3e.Component.Calendar.SlotCaps`](M3e.Component.Calendar#SlotCaps).
-}
type alias CalendarSlotCaps =
    Calendar_.SlotCaps


{-| See [`M3e.Component.Calendar.ChildAdmittedBy`](M3e.Component.Calendar#ChildAdmittedBy).
-}
type alias CalendarChildAdmittedBy childAdm =
    Calendar_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Calendar.StartView`](M3e.Component.Calendar#StartView).
-}
type alias CalendarStartView =
    Calendar_.StartView


{-| See [`M3e.Component.Calendar.startView`](M3e.Component.Calendar#startView).
-}
calendarStartView : Value CalendarStartView -> Attr { c | startView : Supported } msg
calendarStartView =
    Calendar_.startView


{-| See [`M3e.Component.Calendar.date`](M3e.Component.Calendar#date).
-}
calendarDate : String -> Attr { c | date : Supported } msg
calendarDate =
    Calendar_.date


{-| See [`M3e.Component.Calendar.maxDate`](M3e.Component.Calendar#maxDate).
-}
calendarMaxDate : String -> Attr { c | maxDate : Supported } msg
calendarMaxDate =
    Calendar_.maxDate


{-| See [`M3e.Component.Calendar.minDate`](M3e.Component.Calendar#minDate).
-}
calendarMinDate : String -> Attr { c | minDate : Supported } msg
calendarMinDate =
    Calendar_.minDate


{-| See [`M3e.Component.Calendar.nextMonthLabel`](M3e.Component.Calendar#nextMonthLabel).
-}
calendarNextMonthLabel : String -> Attr { c | nextMonthLabel : Supported } msg
calendarNextMonthLabel =
    Calendar_.nextMonthLabel


{-| See [`M3e.Component.Calendar.nextMultiYearLabel`](M3e.Component.Calendar#nextMultiYearLabel).
-}
calendarNextMultiYearLabel : String -> Attr { c | nextMultiYearLabel : Supported } msg
calendarNextMultiYearLabel =
    Calendar_.nextMultiYearLabel


{-| See [`M3e.Component.Calendar.nextYearLabel`](M3e.Component.Calendar#nextYearLabel).
-}
calendarNextYearLabel : String -> Attr { c | nextYearLabel : Supported } msg
calendarNextYearLabel =
    Calendar_.nextYearLabel


{-| See [`M3e.Component.Calendar.previousMonthLabel`](M3e.Component.Calendar#previousMonthLabel).
-}
calendarPreviousMonthLabel : String -> Attr { c | previousMonthLabel : Supported } msg
calendarPreviousMonthLabel =
    Calendar_.previousMonthLabel


{-| See [`M3e.Component.Calendar.previousMultiYearLabel`](M3e.Component.Calendar#previousMultiYearLabel).
-}
calendarPreviousMultiYearLabel : String -> Attr { c | previousMultiYearLabel : Supported } msg
calendarPreviousMultiYearLabel =
    Calendar_.previousMultiYearLabel


{-| See [`M3e.Component.Calendar.previousYearLabel`](M3e.Component.Calendar#previousYearLabel).
-}
calendarPreviousYearLabel : String -> Attr { c | previousYearLabel : Supported } msg
calendarPreviousYearLabel =
    Calendar_.previousYearLabel


{-| See [`M3e.Component.Calendar.rangeEnd`](M3e.Component.Calendar#rangeEnd).
-}
calendarRangeEnd : String -> Attr { c | rangeEnd : Supported } msg
calendarRangeEnd =
    Calendar_.rangeEnd


{-| See [`M3e.Component.Calendar.rangeStart`](M3e.Component.Calendar#rangeStart).
-}
calendarRangeStart : String -> Attr { c | rangeStart : Supported } msg
calendarRangeStart =
    Calendar_.rangeStart


{-| See [`M3e.Component.Calendar.startAt`](M3e.Component.Calendar#startAt).
-}
calendarStartAt : String -> Attr { c | startAt : Supported } msg
calendarStartAt =
    Calendar_.startAt


{-| See [`M3e.Component.Calendar.onChange`](M3e.Component.Calendar#onChange).
-}
calendarOnChange : (String -> msg) -> Attr { c | onChange : Supported } msg
calendarOnChange =
    Calendar_.onChange


{-| See [`M3e.Component.Calendar.header`](M3e.Component.Calendar#header).
-}
calendarHeader : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
calendarHeader =
    Calendar_.header


{-| The `monthView` element of this family — delegates to [`M3e.Component.MonthView.component`](M3e.Component.MonthView#component).
-}
monthView :
    List (Attr MonthViewAttrs msg)
    -> List (Element childAccepts (MonthViewChildAdmittedBy childAdm) msg)
    -> Element (MonthViewIs s) admittedBy msg
monthView =
    MonthView_.component


{-| See [`M3e.Component.MonthView.Is`](M3e.Component.MonthView#Is).
-}
type alias MonthViewIs s =
    MonthView_.Is s


{-| See [`M3e.Component.MonthView.Attrs`](M3e.Component.MonthView#Attrs).
-}
type alias MonthViewAttrs =
    MonthView_.Attrs


{-| See [`M3e.Component.MonthView.Builder`](M3e.Component.MonthView#Builder).
-}
type alias MonthViewBuilder attrCaps slotCaps msg kind =
    MonthView_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MonthView.AttrCaps`](M3e.Component.MonthView#AttrCaps).
-}
type alias MonthViewAttrCaps =
    MonthView_.AttrCaps


{-| See [`M3e.Component.MonthView.SlotCaps`](M3e.Component.MonthView#SlotCaps).
-}
type alias MonthViewSlotCaps =
    MonthView_.SlotCaps


{-| See [`M3e.Component.MonthView.ChildAdmittedBy`](M3e.Component.MonthView#ChildAdmittedBy).
-}
type alias MonthViewChildAdmittedBy childAdm =
    MonthView_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MonthView.active`](M3e.Component.MonthView#active).
-}
monthViewActive : Bool -> Attr { c | active : Supported } msg
monthViewActive =
    MonthView_.active


{-| See [`M3e.Component.MonthView.activeDate`](M3e.Component.MonthView#activeDate).
-}
monthViewActiveDate : String -> Attr { c | activeDate : Supported } msg
monthViewActiveDate =
    MonthView_.activeDate


{-| See [`M3e.Component.MonthView.date`](M3e.Component.MonthView#date).
-}
monthViewDate : String -> Attr { c | date : Supported } msg
monthViewDate =
    MonthView_.date


{-| See [`M3e.Component.MonthView.maxDate`](M3e.Component.MonthView#maxDate).
-}
monthViewMaxDate : String -> Attr { c | maxDate : Supported } msg
monthViewMaxDate =
    MonthView_.maxDate


{-| See [`M3e.Component.MonthView.minDate`](M3e.Component.MonthView#minDate).
-}
monthViewMinDate : String -> Attr { c | minDate : Supported } msg
monthViewMinDate =
    MonthView_.minDate


{-| See [`M3e.Component.MonthView.rangeEnd`](M3e.Component.MonthView#rangeEnd).
-}
monthViewRangeEnd : String -> Attr { c | rangeEnd : Supported } msg
monthViewRangeEnd =
    MonthView_.rangeEnd


{-| See [`M3e.Component.MonthView.rangeStart`](M3e.Component.MonthView#rangeStart).
-}
monthViewRangeStart : String -> Attr { c | rangeStart : Supported } msg
monthViewRangeStart =
    MonthView_.rangeStart


{-| See [`M3e.Component.MonthView.today`](M3e.Component.MonthView#today).
-}
monthViewToday : String -> Attr { c | today : Supported } msg
monthViewToday =
    MonthView_.today


{-| See [`M3e.Component.MonthView.onChange`](M3e.Component.MonthView#onChange).
-}
monthViewOnChange : msg -> Attr { c | onChange : Supported } msg
monthViewOnChange =
    MonthView_.onChange


{-| See [`M3e.Component.MonthView.onActiveChange`](M3e.Component.MonthView#onActiveChange).
-}
monthViewOnActiveChange : msg -> Attr { c | onActiveChange : Supported } msg
monthViewOnActiveChange =
    MonthView_.onActiveChange


{-| The `yearView` element of this family — delegates to [`M3e.Component.YearView.component`](M3e.Component.YearView#component).
-}
yearView :
    List (Attr YearViewAttrs msg)
    -> List (Element childAccepts (YearViewChildAdmittedBy childAdm) msg)
    -> Element (YearViewIs s) admittedBy msg
yearView =
    YearView_.component


{-| See [`M3e.Component.YearView.Is`](M3e.Component.YearView#Is).
-}
type alias YearViewIs s =
    YearView_.Is s


{-| See [`M3e.Component.YearView.Attrs`](M3e.Component.YearView#Attrs).
-}
type alias YearViewAttrs =
    YearView_.Attrs


{-| See [`M3e.Component.YearView.Builder`](M3e.Component.YearView#Builder).
-}
type alias YearViewBuilder attrCaps slotCaps msg kind =
    YearView_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.YearView.AttrCaps`](M3e.Component.YearView#AttrCaps).
-}
type alias YearViewAttrCaps =
    YearView_.AttrCaps


{-| See [`M3e.Component.YearView.SlotCaps`](M3e.Component.YearView#SlotCaps).
-}
type alias YearViewSlotCaps =
    YearView_.SlotCaps


{-| See [`M3e.Component.YearView.ChildAdmittedBy`](M3e.Component.YearView#ChildAdmittedBy).
-}
type alias YearViewChildAdmittedBy childAdm =
    YearView_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.YearView.active`](M3e.Component.YearView#active).
-}
yearViewActive : Bool -> Attr { c | active : Supported } msg
yearViewActive =
    YearView_.active


{-| See [`M3e.Component.YearView.activeDate`](M3e.Component.YearView#activeDate).
-}
yearViewActiveDate : String -> Attr { c | activeDate : Supported } msg
yearViewActiveDate =
    YearView_.activeDate


{-| See [`M3e.Component.YearView.date`](M3e.Component.YearView#date).
-}
yearViewDate : String -> Attr { c | date : Supported } msg
yearViewDate =
    YearView_.date


{-| See [`M3e.Component.YearView.maxDate`](M3e.Component.YearView#maxDate).
-}
yearViewMaxDate : String -> Attr { c | maxDate : Supported } msg
yearViewMaxDate =
    YearView_.maxDate


{-| See [`M3e.Component.YearView.minDate`](M3e.Component.YearView#minDate).
-}
yearViewMinDate : String -> Attr { c | minDate : Supported } msg
yearViewMinDate =
    YearView_.minDate


{-| See [`M3e.Component.YearView.today`](M3e.Component.YearView#today).
-}
yearViewToday : String -> Attr { c | today : Supported } msg
yearViewToday =
    YearView_.today


{-| See [`M3e.Component.YearView.onChange`](M3e.Component.YearView#onChange).
-}
yearViewOnChange : msg -> Attr { c | onChange : Supported } msg
yearViewOnChange =
    YearView_.onChange


{-| See [`M3e.Component.YearView.onActiveChange`](M3e.Component.YearView#onActiveChange).
-}
yearViewOnActiveChange : msg -> Attr { c | onActiveChange : Supported } msg
yearViewOnActiveChange =
    YearView_.onActiveChange


{-| The `multiYearView` element of this family — delegates to [`M3e.Component.MultiYearView.component`](M3e.Component.MultiYearView#component).
-}
multiYearView :
    List (Attr MultiYearViewAttrs msg)
    -> List (Element childAccepts (MultiYearViewChildAdmittedBy childAdm) msg)
    -> Element (MultiYearViewIs s) admittedBy msg
multiYearView =
    MultiYearView_.component


{-| See [`M3e.Component.MultiYearView.Is`](M3e.Component.MultiYearView#Is).
-}
type alias MultiYearViewIs s =
    MultiYearView_.Is s


{-| See [`M3e.Component.MultiYearView.Attrs`](M3e.Component.MultiYearView#Attrs).
-}
type alias MultiYearViewAttrs =
    MultiYearView_.Attrs


{-| See [`M3e.Component.MultiYearView.Builder`](M3e.Component.MultiYearView#Builder).
-}
type alias MultiYearViewBuilder attrCaps slotCaps msg kind =
    MultiYearView_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.MultiYearView.AttrCaps`](M3e.Component.MultiYearView#AttrCaps).
-}
type alias MultiYearViewAttrCaps =
    MultiYearView_.AttrCaps


{-| See [`M3e.Component.MultiYearView.SlotCaps`](M3e.Component.MultiYearView#SlotCaps).
-}
type alias MultiYearViewSlotCaps =
    MultiYearView_.SlotCaps


{-| See [`M3e.Component.MultiYearView.ChildAdmittedBy`](M3e.Component.MultiYearView#ChildAdmittedBy).
-}
type alias MultiYearViewChildAdmittedBy childAdm =
    MultiYearView_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.MultiYearView.active`](M3e.Component.MultiYearView#active).
-}
multiYearViewActive : Bool -> Attr { c | active : Supported } msg
multiYearViewActive =
    MultiYearView_.active


{-| See [`M3e.Component.MultiYearView.activeDate`](M3e.Component.MultiYearView#activeDate).
-}
multiYearViewActiveDate : String -> Attr { c | activeDate : Supported } msg
multiYearViewActiveDate =
    MultiYearView_.activeDate


{-| See [`M3e.Component.MultiYearView.date`](M3e.Component.MultiYearView#date).
-}
multiYearViewDate : String -> Attr { c | date : Supported } msg
multiYearViewDate =
    MultiYearView_.date


{-| See [`M3e.Component.MultiYearView.maxDate`](M3e.Component.MultiYearView#maxDate).
-}
multiYearViewMaxDate : String -> Attr { c | maxDate : Supported } msg
multiYearViewMaxDate =
    MultiYearView_.maxDate


{-| See [`M3e.Component.MultiYearView.minDate`](M3e.Component.MultiYearView#minDate).
-}
multiYearViewMinDate : String -> Attr { c | minDate : Supported } msg
multiYearViewMinDate =
    MultiYearView_.minDate


{-| See [`M3e.Component.MultiYearView.today`](M3e.Component.MultiYearView#today).
-}
multiYearViewToday : String -> Attr { c | today : Supported } msg
multiYearViewToday =
    MultiYearView_.today


{-| See [`M3e.Component.MultiYearView.onChange`](M3e.Component.MultiYearView#onChange).
-}
multiYearViewOnChange : msg -> Attr { c | onChange : Supported } msg
multiYearViewOnChange =
    MultiYearView_.onChange


{-| See [`M3e.Component.MultiYearView.onActiveChange`](M3e.Component.MultiYearView#onActiveChange).
-}
multiYearViewOnActiveChange : msg -> Attr { c | onActiveChange : Supported } msg
multiYearViewOnActiveChange =
    MultiYearView_.onActiveChange

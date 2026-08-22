module M3e.Build.Datepicker exposing (DatepickerBuilder, DatepickerAttrCaps, DatepickerSlotCaps, DatepickerIs, DatepickerChildAdmittedBy, datepickerBuild, datepickerToElement, datepickerWithClass, datepickerWithClearLabel, datepickerWithClearable, datepickerWithConfirmLabel, datepickerWithDate, datepickerWithDismissLabel, datepickerWithFor, datepickerWithId, datepickerWithLabel, datepickerWithMaxDate, datepickerWithMinDate, datepickerWithNextMonthLabel, datepickerWithNextMultiYearLabel, datepickerWithNextYearLabel, datepickerWithOnBeforetoggle, datepickerWithOnChange, datepickerWithOnToggle, datepickerWithPreviousMonthLabel, datepickerWithPreviousMultiYearLabel, datepickerWithPreviousYearLabel, datepickerWithRange, datepickerWithRangeEnd, datepickerWithRangeStart, datepickerWithSlot, datepickerWithStartAt, datepickerWithStartView, datepickerWithStyle, datepickerWithVariant, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle)

{-| The **Datepicker** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Datepicker`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs DatepickerBuilder, DatepickerAttrCaps, DatepickerSlotCaps, DatepickerIs, DatepickerChildAdmittedBy, datepickerBuild, datepickerToElement, datepickerWithClass, datepickerWithClearLabel, datepickerWithClearable, datepickerWithConfirmLabel, datepickerWithDate, datepickerWithDismissLabel, datepickerWithFor, datepickerWithId, datepickerWithLabel, datepickerWithMaxDate, datepickerWithMinDate, datepickerWithNextMonthLabel, datepickerWithNextMultiYearLabel, datepickerWithNextYearLabel, datepickerWithOnBeforetoggle, datepickerWithOnChange, datepickerWithOnToggle, datepickerWithPreviousMonthLabel, datepickerWithPreviousMultiYearLabel, datepickerWithPreviousYearLabel, datepickerWithRange, datepickerWithRangeEnd, datepickerWithRangeStart, datepickerWithSlot, datepickerWithStartAt, datepickerWithStartView, datepickerWithStyle, datepickerWithVariant, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleIs, ToggleChildAdmittedBy, toggleBuild, toggleToElement, toggleWithClass, toggleWithFor, toggleWithId, toggleWithSlot, toggleWithStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Datepicker as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias DatepickerIs s =
    Component.DatepickerIs s


{-| -}
type alias DatepickerBuilder attrCaps slotCaps msg kind =
    Component.DatepickerBuilder attrCaps slotCaps msg kind


{-| -}
type alias DatepickerAttrCaps =
    Component.DatepickerAttrCaps


{-| -}
type alias DatepickerSlotCaps =
    Component.DatepickerSlotCaps


{-| -}
type alias DatepickerChildAdmittedBy childAdm =
    Component.DatepickerChildAdmittedBy childAdm


{-| -}
datepickerBuild : DatepickerBuilder DatepickerAttrCaps DatepickerSlotCaps msg kind
datepickerBuild =
    B.init "m3e-datepicker" [] []


{-| -}
datepickerToElement : DatepickerBuilder attrCaps slotCaps msg kind -> Element (Component.DatepickerIs kind) admittedBy msg
datepickerToElement =
    B.toElement


{-| -}
datepickerWithClass : String -> DatepickerBuilder { a | class : Available } slotCaps msg kind -> DatepickerBuilder { a | class : Used } slotCaps msg kind
datepickerWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
datepickerWithId : String -> DatepickerBuilder { a | id : Available } slotCaps msg kind -> DatepickerBuilder { a | id : Used } slotCaps msg kind
datepickerWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
datepickerWithSlot : String -> DatepickerBuilder { a | slot : Available } slotCaps msg kind -> DatepickerBuilder { a | slot : Used } slotCaps msg kind
datepickerWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
datepickerWithStyle : String -> String -> DatepickerBuilder { a | style : Available } slotCaps msg kind -> DatepickerBuilder { a | style : Used } slotCaps msg kind
datepickerWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
datepickerWithClearLabel : String -> DatepickerBuilder { a | clearLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | clearLabel : Used } slotCaps msg kind
datepickerWithClearLabel value_ =
    B.withAttribute (A.clearLabel value_)


{-| -}
datepickerWithClearable : Bool -> DatepickerBuilder { a | clearable : Available } slotCaps msg kind -> DatepickerBuilder { a | clearable : Used } slotCaps msg kind
datepickerWithClearable value_ =
    B.withAttribute (A.clearable value_)


{-| -}
datepickerWithConfirmLabel : String -> DatepickerBuilder { a | confirmLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | confirmLabel : Used } slotCaps msg kind
datepickerWithConfirmLabel value_ =
    B.withAttribute (A.confirmLabel value_)


{-| -}
datepickerWithDate : String -> DatepickerBuilder { a | date : Available } slotCaps msg kind -> DatepickerBuilder { a | date : Used } slotCaps msg kind
datepickerWithDate value_ =
    B.withAttribute (A.date value_)


{-| -}
datepickerWithDismissLabel : String -> DatepickerBuilder { a | dismissLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | dismissLabel : Used } slotCaps msg kind
datepickerWithDismissLabel value_ =
    B.withAttribute (A.dismissLabel value_)


{-| -}
datepickerWithFor : String -> DatepickerBuilder { a | for : Available } slotCaps msg kind -> DatepickerBuilder { a | for : Used } slotCaps msg kind
datepickerWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
datepickerWithLabel : String -> DatepickerBuilder { a | label : Available } slotCaps msg kind -> DatepickerBuilder { a | label : Used } slotCaps msg kind
datepickerWithLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
datepickerWithMaxDate : String -> DatepickerBuilder { a | maxDate : Available } slotCaps msg kind -> DatepickerBuilder { a | maxDate : Used } slotCaps msg kind
datepickerWithMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
datepickerWithMinDate : String -> DatepickerBuilder { a | minDate : Available } slotCaps msg kind -> DatepickerBuilder { a | minDate : Used } slotCaps msg kind
datepickerWithMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
datepickerWithNextMonthLabel : String -> DatepickerBuilder { a | nextMonthLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | nextMonthLabel : Used } slotCaps msg kind
datepickerWithNextMonthLabel value_ =
    B.withAttribute (A.nextMonthLabel value_)


{-| -}
datepickerWithNextMultiYearLabel : String -> DatepickerBuilder { a | nextMultiYearLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | nextMultiYearLabel : Used } slotCaps msg kind
datepickerWithNextMultiYearLabel value_ =
    B.withAttribute (A.nextMultiYearLabel value_)


{-| -}
datepickerWithNextYearLabel : String -> DatepickerBuilder { a | nextYearLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | nextYearLabel : Used } slotCaps msg kind
datepickerWithNextYearLabel value_ =
    B.withAttribute (A.nextYearLabel value_)


{-| -}
datepickerWithPreviousMonthLabel : String -> DatepickerBuilder { a | previousMonthLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | previousMonthLabel : Used } slotCaps msg kind
datepickerWithPreviousMonthLabel value_ =
    B.withAttribute (A.previousMonthLabel value_)


{-| -}
datepickerWithPreviousMultiYearLabel : String -> DatepickerBuilder { a | previousMultiYearLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | previousMultiYearLabel : Used } slotCaps msg kind
datepickerWithPreviousMultiYearLabel value_ =
    B.withAttribute (A.previousMultiYearLabel value_)


{-| -}
datepickerWithPreviousYearLabel : String -> DatepickerBuilder { a | previousYearLabel : Available } slotCaps msg kind -> DatepickerBuilder { a | previousYearLabel : Used } slotCaps msg kind
datepickerWithPreviousYearLabel value_ =
    B.withAttribute (A.previousYearLabel value_)


{-| -}
datepickerWithRange : Bool -> DatepickerBuilder { a | range : Available } slotCaps msg kind -> DatepickerBuilder { a | range : Used } slotCaps msg kind
datepickerWithRange value_ =
    B.withAttribute (A.range value_)


{-| -}
datepickerWithRangeEnd : String -> DatepickerBuilder { a | rangeEnd : Available } slotCaps msg kind -> DatepickerBuilder { a | rangeEnd : Used } slotCaps msg kind
datepickerWithRangeEnd value_ =
    B.withAttribute (A.rangeEnd value_)


{-| -}
datepickerWithRangeStart : String -> DatepickerBuilder { a | rangeStart : Available } slotCaps msg kind -> DatepickerBuilder { a | rangeStart : Used } slotCaps msg kind
datepickerWithRangeStart value_ =
    B.withAttribute (A.rangeStart value_)


{-| -}
datepickerWithStartAt : String -> DatepickerBuilder { a | startAt : Available } slotCaps msg kind -> DatepickerBuilder { a | startAt : Used } slotCaps msg kind
datepickerWithStartAt value_ =
    B.withAttribute (A.startAt value_)


{-| -}
datepickerWithStartView : Value Component.DatepickerStartView -> DatepickerBuilder { a | startView : Available } slotCaps msg kind -> DatepickerBuilder { a | startView : Used } slotCaps msg kind
datepickerWithStartView value_ =
    B.withAttribute (Component.datepickerStartView value_)


{-| -}
datepickerWithVariant : Value Component.DatepickerVariant -> DatepickerBuilder { a | variant : Available } slotCaps msg kind -> DatepickerBuilder { a | variant : Used } slotCaps msg kind
datepickerWithVariant value_ =
    B.withAttribute (Component.datepickerVariant value_)


{-| -}
datepickerWithOnChange : (String -> msg) -> DatepickerBuilder { a | onChange : Available } slotCaps msg kind -> DatepickerBuilder { a | onChange : Used } slotCaps msg kind
datepickerWithOnChange value_ =
    B.withAttribute (Component.datepickerOnChange value_)


{-| -}
datepickerWithOnBeforetoggle : msg -> DatepickerBuilder { a | onBeforetoggle : Available } slotCaps msg kind -> DatepickerBuilder { a | onBeforetoggle : Used } slotCaps msg kind
datepickerWithOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
datepickerWithOnToggle : msg -> DatepickerBuilder { a | onToggle : Available } slotCaps msg kind -> DatepickerBuilder { a | onToggle : Used } slotCaps msg kind
datepickerWithOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)


{-| -}
type alias ToggleIs s =
    Component.ToggleIs s


{-| -}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Component.ToggleBuilder attrCaps slotCaps msg kind


{-| -}
type alias ToggleAttrCaps =
    Component.ToggleAttrCaps


{-| -}
type alias ToggleSlotCaps =
    Component.ToggleSlotCaps


{-| -}
type alias ToggleChildAdmittedBy childAdm =
    Component.ToggleChildAdmittedBy childAdm


{-| -}
toggleBuild : ToggleBuilder ToggleAttrCaps ToggleSlotCaps msg kind
toggleBuild =
    B.init "m3e-datepicker-toggle" [] []


{-| -}
toggleToElement : ToggleBuilder attrCaps slotCaps msg kind -> Element (Component.ToggleIs kind) admittedBy msg
toggleToElement =
    B.toElement


{-| -}
toggleWithClass : String -> ToggleBuilder { a | class : Available } slotCaps msg kind -> ToggleBuilder { a | class : Used } slotCaps msg kind
toggleWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
toggleWithId : String -> ToggleBuilder { a | id : Available } slotCaps msg kind -> ToggleBuilder { a | id : Used } slotCaps msg kind
toggleWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
toggleWithSlot : String -> ToggleBuilder { a | slot : Available } slotCaps msg kind -> ToggleBuilder { a | slot : Used } slotCaps msg kind
toggleWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
toggleWithStyle : String -> String -> ToggleBuilder { a | style : Available } slotCaps msg kind -> ToggleBuilder { a | style : Used } slotCaps msg kind
toggleWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
toggleWithFor : String -> ToggleBuilder { a | for : Available } slotCaps msg kind -> ToggleBuilder { a | for : Used } slotCaps msg kind
toggleWithFor value_ =
    B.withAttribute (A.for value_)

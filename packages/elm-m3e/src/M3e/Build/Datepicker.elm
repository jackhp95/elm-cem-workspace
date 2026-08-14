module M3e.Build.Datepicker exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withClearLabel, withClearable, withConfirmLabel, withDate, withDismissLabel, withFor, withId, withLabel, withMaxDate, withMinDate, withNextMonthLabel, withNextMultiYearLabel, withNextYearLabel, withOnBeforetoggle, withOnChange, withOnToggle, withPreviousMonthLabel, withPreviousMultiYearLabel, withPreviousYearLabel, withRange, withRangeEnd, withRangeStart, withSlot, withStartAt, withStartView, withStyle, withVariant
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withClearLabel, withClearable, withConfirmLabel, withDate, withDismissLabel, withFor, withId, withLabel, withMaxDate, withMinDate, withNextMonthLabel, withNextMultiYearLabel, withNextYearLabel, withOnBeforetoggle, withOnChange, withOnToggle, withPreviousMonthLabel, withPreviousMultiYearLabel, withPreviousYearLabel, withRange, withRangeEnd, withRangeStart, withSlot, withStartAt, withStartView, withStyle, withVariant

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.Datepicker as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Internal.Types.Datepicker
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.Datepicker.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Datepicker.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Datepicker.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Datepicker.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-datepicker" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
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
withClearLabel : String -> Builder { a | clearLabel : Available } slotCaps msg kind -> Builder { a | clearLabel : Used } slotCaps msg kind
withClearLabel value_ =
    B.withAttribute (A.clearLabel value_)


{-| -}
withClearable : Bool -> Builder { a | clearable : Available } slotCaps msg kind -> Builder { a | clearable : Used } slotCaps msg kind
withClearable value_ =
    B.withAttribute (A.clearable value_)


{-| -}
withConfirmLabel : String -> Builder { a | confirmLabel : Available } slotCaps msg kind -> Builder { a | confirmLabel : Used } slotCaps msg kind
withConfirmLabel value_ =
    B.withAttribute (A.confirmLabel value_)


{-| -}
withDate : String -> Builder { a | date : Available } slotCaps msg kind -> Builder { a | date : Used } slotCaps msg kind
withDate value_ =
    B.withAttribute (A.date value_)


{-| -}
withDismissLabel : String -> Builder { a | dismissLabel : Available } slotCaps msg kind -> Builder { a | dismissLabel : Used } slotCaps msg kind
withDismissLabel value_ =
    B.withAttribute (A.dismissLabel value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withMaxDate : String -> Builder { a | maxDate : Available } slotCaps msg kind -> Builder { a | maxDate : Used } slotCaps msg kind
withMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
withMinDate : String -> Builder { a | minDate : Available } slotCaps msg kind -> Builder { a | minDate : Used } slotCaps msg kind
withMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
withNextMonthLabel : String -> Builder { a | nextMonthLabel : Available } slotCaps msg kind -> Builder { a | nextMonthLabel : Used } slotCaps msg kind
withNextMonthLabel value_ =
    B.withAttribute (A.nextMonthLabel value_)


{-| -}
withNextMultiYearLabel : String -> Builder { a | nextMultiYearLabel : Available } slotCaps msg kind -> Builder { a | nextMultiYearLabel : Used } slotCaps msg kind
withNextMultiYearLabel value_ =
    B.withAttribute (A.nextMultiYearLabel value_)


{-| -}
withNextYearLabel : String -> Builder { a | nextYearLabel : Available } slotCaps msg kind -> Builder { a | nextYearLabel : Used } slotCaps msg kind
withNextYearLabel value_ =
    B.withAttribute (A.nextYearLabel value_)


{-| -}
withPreviousMonthLabel : String -> Builder { a | previousMonthLabel : Available } slotCaps msg kind -> Builder { a | previousMonthLabel : Used } slotCaps msg kind
withPreviousMonthLabel value_ =
    B.withAttribute (A.previousMonthLabel value_)


{-| -}
withPreviousMultiYearLabel : String -> Builder { a | previousMultiYearLabel : Available } slotCaps msg kind -> Builder { a | previousMultiYearLabel : Used } slotCaps msg kind
withPreviousMultiYearLabel value_ =
    B.withAttribute (A.previousMultiYearLabel value_)


{-| -}
withPreviousYearLabel : String -> Builder { a | previousYearLabel : Available } slotCaps msg kind -> Builder { a | previousYearLabel : Used } slotCaps msg kind
withPreviousYearLabel value_ =
    B.withAttribute (A.previousYearLabel value_)


{-| -}
withRange : Bool -> Builder { a | range : Available } slotCaps msg kind -> Builder { a | range : Used } slotCaps msg kind
withRange value_ =
    B.withAttribute (A.range value_)


{-| -}
withRangeEnd : String -> Builder { a | rangeEnd : Available } slotCaps msg kind -> Builder { a | rangeEnd : Used } slotCaps msg kind
withRangeEnd value_ =
    B.withAttribute (A.rangeEnd value_)


{-| -}
withRangeStart : String -> Builder { a | rangeStart : Available } slotCaps msg kind -> Builder { a | rangeStart : Used } slotCaps msg kind
withRangeStart value_ =
    B.withAttribute (A.rangeStart value_)


{-| -}
withStartAt : String -> Builder { a | startAt : Available } slotCaps msg kind -> Builder { a | startAt : Used } slotCaps msg kind
withStartAt value_ =
    B.withAttribute (A.startAt value_)


{-| -}
withStartView : Value Component.StartView -> Builder { a | startView : Available } slotCaps msg kind -> Builder { a | startView : Used } slotCaps msg kind
withStartView value_ =
    B.withAttribute (Component.startView value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| -}
withOnChange : (String -> msg) -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Component.onChange value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)

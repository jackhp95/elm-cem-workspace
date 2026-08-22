module M3e.Build.YearView exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withActive, withActiveDate, withClass, withDate, withId, withMaxDate, withMinDate, withOnActiveChange, withOnChange, withSlot, withStyle, withToday)

{-| The **YearView** element — the flat per-element builder surface,
sourced through the **Calendar** family façade
(`M3e.Component.Calendar`). This module and the aggregated
`M3e.Build.Calendar` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withActive, withActiveDate, withClass, withDate, withId, withMaxDate, withMinDate, withOnActiveChange, withOnChange, withSlot, withStyle, withToday

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
type alias Is s =
    Component.YearViewIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.YearViewBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.YearViewAttrCaps


{-| -}
type alias SlotCaps =
    Component.YearViewSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.YearViewChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-year-view" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.YearViewIs kind) admittedBy msg
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
withActive : Bool -> Builder { a | active : Available } slotCaps msg kind -> Builder { a | active : Used } slotCaps msg kind
withActive value_ =
    B.withAttribute (A.active value_)


{-| -}
withActiveDate : String -> Builder { a | activeDate : Available } slotCaps msg kind -> Builder { a | activeDate : Used } slotCaps msg kind
withActiveDate value_ =
    B.withAttribute (A.activeDate value_)


{-| -}
withDate : String -> Builder { a | date : Available } slotCaps msg kind -> Builder { a | date : Used } slotCaps msg kind
withDate value_ =
    B.withAttribute (A.date value_)


{-| -}
withMaxDate : String -> Builder { a | maxDate : Available } slotCaps msg kind -> Builder { a | maxDate : Used } slotCaps msg kind
withMaxDate value_ =
    B.withAttribute (A.maxDate value_)


{-| -}
withMinDate : String -> Builder { a | minDate : Available } slotCaps msg kind -> Builder { a | minDate : Used } slotCaps msg kind
withMinDate value_ =
    B.withAttribute (A.minDate value_)


{-| -}
withToday : String -> Builder { a | today : Available } slotCaps msg kind -> Builder { a | today : Used } slotCaps msg kind
withToday value_ =
    B.withAttribute (A.today value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnActiveChange : msg -> Builder { a | onActiveChange : Available } slotCaps msg kind -> Builder { a | onActiveChange : Used } slotCaps msg kind
withOnActiveChange value_ =
    B.withAttribute (Ev.onActiveChange value_)

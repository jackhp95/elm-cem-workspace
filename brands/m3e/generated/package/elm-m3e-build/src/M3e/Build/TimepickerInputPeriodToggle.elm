module M3e.Build.TimepickerInputPeriodToggle exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnChange, withOrientation, withPeriod, withSlot, withStyle)

{-| The **TimepickerInputPeriodToggle** element — the flat per-element builder surface,
sourced through the **Timepicker** family façade
(`M3e.Component.Timepicker`). This module and the aggregated
`M3e.Build.Timepicker` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnChange, withOrientation, withPeriod, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.Timepicker as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.InputPeriodToggleIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.InputPeriodToggleBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.InputPeriodToggleAttrCaps


{-| -}
type alias SlotCaps =
    Component.InputPeriodToggleSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.InputPeriodToggleChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-timepicker-input-period-toggle" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.InputPeriodToggleIs kind) admittedBy msg
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
withOrientation : String -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Ir.attribute "orientation" value_)


{-| -}
withPeriod : Value Component.InputPeriodTogglePeriod -> Builder { a | period : Available } slotCaps msg kind -> Builder { a | period : Used } slotCaps msg kind
withPeriod value_ =
    B.withAttribute (Component.inputPeriodTogglePeriod value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)

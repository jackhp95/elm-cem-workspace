module M3e.Build.Stepper exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, PanelSlot, StepSlot, ChildAdmittedBy
    , withClass, withHeaderPosition, withId, withLabelPosition, withLinear, withOnBeforeinput, withOnChange, withOnInput, withOrientation, withSlot, withStyle
    , panel, step
    , withPanel, withStep
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, PanelSlot, StepSlot, ChildAdmittedBy
@docs withClass, withHeaderPosition, withId, withLabelPosition, withLinear, withOnBeforeinput, withOnChange, withOnInput, withOrientation, withSlot, withStyle
@docs panel, step
@docs withPanel, withStep

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.Stepper as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Internal.Types.Stepper
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.Stepper.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Stepper.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Stepper.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Stepper.ChildAdmittedBy childAdm


{-| -}
type alias PanelSlot =
    M3e.Internal.Types.Stepper.PanelSlot


{-| -}
type alias StepSlot =
    M3e.Internal.Types.Stepper.StepSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-stepper" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
panel :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelSlot msg
    -> Element free freeAdmittedBy msg
panel builder =
    Component.panel (B.toElement builder)


{-| -}
step :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepSlot msg
    -> Element free freeAdmittedBy msg
step builder =
    Component.step (B.toElement builder)


{-| -}
withPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withPanel slotBuilder builder_ =
    B.withChild (El.toNode (Component.panel (B.toElement slotBuilder))) builder_


{-| -}
withStep :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withStep slotBuilder builder_ =
    B.withChild (El.toNode (Component.step (B.toElement slotBuilder))) builder_


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
withHeaderPosition : Value Component.HeaderPosition -> Builder { a | headerPosition : Available } slotCaps msg kind -> Builder { a | headerPosition : Used } slotCaps msg kind
withHeaderPosition value_ =
    B.withAttribute (Component.headerPosition value_)


{-| -}
withLabelPosition : Value Component.LabelPosition -> Builder { a | labelPosition : Available } slotCaps msg kind -> Builder { a | labelPosition : Used } slotCaps msg kind
withLabelPosition value_ =
    B.withAttribute (Component.labelPosition value_)


{-| -}
withLinear : Bool -> Builder { a | linear : Available } slotCaps msg kind -> Builder { a | linear : Used } slotCaps msg kind
withLinear value_ =
    B.withAttribute (A.linear value_)


{-| -}
withOrientation : Value Component.Orientation -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Component.orientation value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)

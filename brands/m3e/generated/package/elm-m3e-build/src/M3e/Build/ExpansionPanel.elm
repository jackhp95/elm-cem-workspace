module M3e.Build.ExpansionPanel exposing (Builder, AttrCaps, SlotCaps, Is, HeaderSlot, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withHideToggle, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, withToggleDirection, withTogglePosition, actions, header, toggleIcon, withHeader, withToggleIcon, withActions, withChild)

{-| The **ExpansionPanel** element — the flat per-element builder surface,
sourced through the **Accordion** family façade
(`M3e.Component.Accordion`). This module and the aggregated
`M3e.Build.Accordion` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, HeaderSlot, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withHideToggle, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, withToggleDirection, withTogglePosition, actions, header, toggleIcon, withHeader, withToggleIcon, withActions, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Accordion as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.PanelIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.PanelBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.PanelAttrCaps


{-| -}
type alias SlotCaps =
    Component.PanelSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.PanelChildAdmittedBy childAdm


{-| -}
type alias HeaderSlot =
    Component.PanelHeaderSlot


{-| -}
type alias ToggleIconSlot =
    Component.PanelToggleIconSlot


{-| -}
build :
    { header : Element Component.PanelHeaderSlot (Component.PanelChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-expansion-panel" [] [ El.toNode (Component.panelHeader required_.header) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.PanelIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.panelActions (B.toElement builder)


{-| -}
header :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelHeaderSlot msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.panelHeader (B.toElement builder)


{-| -}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.panelToggleIcon (B.toElement builder)


{-| -}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelHeaderSlot msg
    -> Builder attrCaps { s | header : Available } msg kind
    -> Builder attrCaps { s | header : Used } msg kind
withHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelHeader (B.toElement slotBuilder))) builder_


{-| -}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelToggleIcon (B.toElement slotBuilder))) builder_


{-| -}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelActions (B.toElement slotBuilder))) builder_


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withHideToggle : Bool -> Builder { a | hideToggle : Available } slotCaps msg kind -> Builder { a | hideToggle : Used } slotCaps msg kind
withHideToggle value_ =
    B.withAttribute (A.hideToggle value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withToggleDirection : Value Component.PanelToggleDirection -> Builder { a | toggleDirection : Available } slotCaps msg kind -> Builder { a | toggleDirection : Used } slotCaps msg kind
withToggleDirection value_ =
    B.withAttribute (Component.panelToggleDirection value_)


{-| -}
withTogglePosition : Value Component.PanelTogglePosition -> Builder { a | togglePosition : Available } slotCaps msg kind -> Builder { a | togglePosition : Used } slotCaps msg kind
withTogglePosition value_ =
    B.withAttribute (Component.panelTogglePosition value_)


{-| -}
withOnOpening : msg -> Builder { a | onOpening : Available } slotCaps msg kind -> Builder { a | onOpening : Used } slotCaps msg kind
withOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
withOnOpened : msg -> Builder { a | onOpened : Available } slotCaps msg kind -> Builder { a | onOpened : Used } slotCaps msg kind
withOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
withOnClosing : msg -> Builder { a | onClosing : Available } slotCaps msg kind -> Builder { a | onClosing : Used } slotCaps msg kind
withOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
withOnClosed : msg -> Builder { a | onClosed : Available } slotCaps msg kind -> Builder { a | onClosed : Used } slotCaps msg kind
withOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)

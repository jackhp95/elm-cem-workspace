module M3e.Build.Accordion exposing (AccordionBuilder, AccordionAttrCaps, AccordionSlotCaps, AccordionIs, AccordionContent, AccordionChildAdmittedBy, accordionBuild, accordionToElement, accordionWithClass, accordionWithId, accordionWithMulti, accordionWithSlot, accordionWithStyle, accordionWithChild, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelIs, PanelHeaderSlot, PanelToggleIconSlot, PanelChildAdmittedBy, panelBuild, panelToElement, panelWithClass, panelWithDisabled, panelWithHideToggle, panelWithId, panelWithOnClosed, panelWithOnClosing, panelWithOnOpened, panelWithOnOpening, panelWithOpen, panelWithSlot, panelWithStyle, panelWithToggleDirection, panelWithTogglePosition, panelActions, panelHeader, panelToggleIcon, panelWithHeader, panelWithToggleIcon, panelWithActions, panelWithChild)

{-| The **Accordion** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Accordion`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs AccordionBuilder, AccordionAttrCaps, AccordionSlotCaps, AccordionIs, AccordionContent, AccordionChildAdmittedBy, accordionBuild, accordionToElement, accordionWithClass, accordionWithId, accordionWithMulti, accordionWithSlot, accordionWithStyle, accordionWithChild, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelIs, PanelHeaderSlot, PanelToggleIconSlot, PanelChildAdmittedBy, panelBuild, panelToElement, panelWithClass, panelWithDisabled, panelWithHideToggle, panelWithId, panelWithOnClosed, panelWithOnClosing, panelWithOnOpened, panelWithOnOpening, panelWithOpen, panelWithSlot, panelWithStyle, panelWithToggleDirection, panelWithTogglePosition, panelActions, panelHeader, panelToggleIcon, panelWithHeader, panelWithToggleIcon, panelWithActions, panelWithChild

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
type alias AccordionIs s =
    Component.AccordionIs s


{-| -}
type alias AccordionBuilder attrCaps slotCaps msg kind =
    Component.AccordionBuilder attrCaps slotCaps msg kind


{-| -}
type alias AccordionAttrCaps =
    Component.AccordionAttrCaps


{-| -}
type alias AccordionSlotCaps =
    Component.AccordionSlotCaps


{-| -}
type alias AccordionChildAdmittedBy childAdm =
    Component.AccordionChildAdmittedBy childAdm


{-| -}
type alias AccordionContent =
    Component.AccordionContent


{-| -}
accordionBuild :
    { content : Element Component.AccordionContent (Component.AccordionChildAdmittedBy childAdm) msg }
    -> AccordionBuilder AccordionAttrCaps AccordionSlotCaps msg kind
accordionBuild required_ =
    B.init "m3e-accordion" [] [ El.toNode required_.content ]


{-| -}
accordionToElement : AccordionBuilder attrCaps slotCaps msg kind -> Element (Component.AccordionIs kind) admittedBy msg
accordionToElement =
    B.toElement


{-| -}
accordionWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> AccordionBuilder attrCaps slotCaps msg kind
    -> AccordionBuilder attrCaps slotCaps msg kind
accordionWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
accordionWithClass : String -> AccordionBuilder { a | class : Available } slotCaps msg kind -> AccordionBuilder { a | class : Used } slotCaps msg kind
accordionWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
accordionWithId : String -> AccordionBuilder { a | id : Available } slotCaps msg kind -> AccordionBuilder { a | id : Used } slotCaps msg kind
accordionWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
accordionWithSlot : String -> AccordionBuilder { a | slot : Available } slotCaps msg kind -> AccordionBuilder { a | slot : Used } slotCaps msg kind
accordionWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
accordionWithStyle : String -> String -> AccordionBuilder { a | style : Available } slotCaps msg kind -> AccordionBuilder { a | style : Used } slotCaps msg kind
accordionWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
accordionWithMulti : Bool -> AccordionBuilder { a | multi : Available } slotCaps msg kind -> AccordionBuilder { a | multi : Used } slotCaps msg kind
accordionWithMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
type alias PanelIs s =
    Component.PanelIs s


{-| -}
type alias PanelBuilder attrCaps slotCaps msg kind =
    Component.PanelBuilder attrCaps slotCaps msg kind


{-| -}
type alias PanelAttrCaps =
    Component.PanelAttrCaps


{-| -}
type alias PanelSlotCaps =
    Component.PanelSlotCaps


{-| -}
type alias PanelChildAdmittedBy childAdm =
    Component.PanelChildAdmittedBy childAdm


{-| -}
type alias PanelHeaderSlot =
    Component.PanelHeaderSlot


{-| -}
type alias PanelToggleIconSlot =
    Component.PanelToggleIconSlot


{-| -}
panelBuild :
    { header : Element Component.PanelHeaderSlot (Component.PanelChildAdmittedBy childAdm) msg }
    -> PanelBuilder PanelAttrCaps PanelSlotCaps msg kind
panelBuild required_ =
    B.init "m3e-expansion-panel" [] [ El.toNode (Component.panelHeader required_.header) ]


{-| -}
panelToElement : PanelBuilder attrCaps slotCaps msg kind -> Element (Component.PanelIs kind) admittedBy msg
panelToElement =
    B.toElement


{-| -}
panelActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
panelActions builder =
    Component.panelActions (B.toElement builder)


{-| -}
panelHeader :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelHeaderSlot msg
    -> Element free freeAdmittedBy msg
panelHeader builder =
    Component.panelHeader (B.toElement builder)


{-| -}
panelToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelToggleIconSlot msg
    -> Element free freeAdmittedBy msg
panelToggleIcon builder =
    Component.panelToggleIcon (B.toElement builder)


{-| -}
panelWithHeader :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelHeaderSlot msg
    -> PanelBuilder attrCaps { s | header : Available } msg kind
    -> PanelBuilder attrCaps { s | header : Used } msg kind
panelWithHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelHeader (B.toElement slotBuilder))) builder_


{-| -}
panelWithToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelToggleIconSlot msg
    -> PanelBuilder attrCaps { s | toggleIcon : Available } msg kind
    -> PanelBuilder attrCaps { s | toggleIcon : Used } msg kind
panelWithToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelToggleIcon (B.toElement slotBuilder))) builder_


{-| -}
panelWithActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> PanelBuilder attrCaps slotCaps msg kind
    -> PanelBuilder attrCaps slotCaps msg kind
panelWithActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelActions (B.toElement slotBuilder))) builder_


{-| -}
panelWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> PanelBuilder attrCaps slotCaps msg kind
    -> PanelBuilder attrCaps slotCaps msg kind
panelWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
panelWithClass : String -> PanelBuilder { a | class : Available } slotCaps msg kind -> PanelBuilder { a | class : Used } slotCaps msg kind
panelWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
panelWithId : String -> PanelBuilder { a | id : Available } slotCaps msg kind -> PanelBuilder { a | id : Used } slotCaps msg kind
panelWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
panelWithSlot : String -> PanelBuilder { a | slot : Available } slotCaps msg kind -> PanelBuilder { a | slot : Used } slotCaps msg kind
panelWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
panelWithStyle : String -> String -> PanelBuilder { a | style : Available } slotCaps msg kind -> PanelBuilder { a | style : Used } slotCaps msg kind
panelWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
panelWithDisabled : Bool -> PanelBuilder { a | disabled : Available } slotCaps msg kind -> PanelBuilder { a | disabled : Used } slotCaps msg kind
panelWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
panelWithHideToggle : Bool -> PanelBuilder { a | hideToggle : Available } slotCaps msg kind -> PanelBuilder { a | hideToggle : Used } slotCaps msg kind
panelWithHideToggle value_ =
    B.withAttribute (A.hideToggle value_)


{-| -}
panelWithOpen : Bool -> PanelBuilder { a | open : Available } slotCaps msg kind -> PanelBuilder { a | open : Used } slotCaps msg kind
panelWithOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
panelWithToggleDirection : Value Component.PanelToggleDirection -> PanelBuilder { a | toggleDirection : Available } slotCaps msg kind -> PanelBuilder { a | toggleDirection : Used } slotCaps msg kind
panelWithToggleDirection value_ =
    B.withAttribute (Component.panelToggleDirection value_)


{-| -}
panelWithTogglePosition : Value Component.PanelTogglePosition -> PanelBuilder { a | togglePosition : Available } slotCaps msg kind -> PanelBuilder { a | togglePosition : Used } slotCaps msg kind
panelWithTogglePosition value_ =
    B.withAttribute (Component.panelTogglePosition value_)


{-| -}
panelWithOnOpening : msg -> PanelBuilder { a | onOpening : Available } slotCaps msg kind -> PanelBuilder { a | onOpening : Used } slotCaps msg kind
panelWithOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
panelWithOnOpened : msg -> PanelBuilder { a | onOpened : Available } slotCaps msg kind -> PanelBuilder { a | onOpened : Used } slotCaps msg kind
panelWithOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
panelWithOnClosing : msg -> PanelBuilder { a | onClosing : Available } slotCaps msg kind -> PanelBuilder { a | onClosing : Used } slotCaps msg kind
panelWithOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
panelWithOnClosed : msg -> PanelBuilder { a | onClosed : Available } slotCaps msg kind -> PanelBuilder { a | onClosed : Used } slotCaps msg kind
panelWithOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)

module M3e.Component.Accordion exposing (AccordionIs, AccordionAttrs, AccordionBuilder, AccordionAttrCaps, AccordionSlotCaps, AccordionContent, AccordionChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelHeaderSlot, PanelToggleIconSlot, PanelChildAdmittedBy, PanelToggleDirection, PanelTogglePosition, accordion, accordionMulti, accordionChild, panel, panelToggleDirection, panelTogglePosition, panelDisabled, panelHideToggle, panelOpen, panelOnOpening, panelOnOpened, panelOnClosing, panelOnClosed, panelActions, panelHeader, panelToggleIcon, panelChild)

{-| The **Accordion** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Accordion`](M3e.Element.Accordion) as `accordion`, [`M3e.Element.ExpansionPanel`](M3e.Element.ExpansionPanel) as `panel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs AccordionIs, AccordionAttrs, AccordionBuilder, AccordionAttrCaps, AccordionSlotCaps, AccordionContent, AccordionChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelHeaderSlot, PanelToggleIconSlot, PanelChildAdmittedBy, PanelToggleDirection, PanelTogglePosition, accordion, accordionMulti, accordionChild, panel, panelToggleDirection, panelTogglePosition, panelDisabled, panelHideToggle, panelOpen, panelOnOpening, panelOnOpened, panelOnClosing, panelOnClosed, panelActions, panelHeader, panelToggleIcon, panelChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Accordion as Accordion_
import M3e.Element.ExpansionPanel as Panel_


{-| The `accordion` element of this family — delegates to [`M3e.Element.Accordion.component`](M3e.Element.Accordion#component).
-}
accordion :
    { content : Element AccordionContent (AccordionChildAdmittedBy childAdm) msg }
    -> List (Attr AccordionAttrs msg)
    -> List (Element AccordionContent (AccordionChildAdmittedBy childAdm) msg)
    -> Element (AccordionIs s) admittedBy msg
accordion =
    Accordion_.component


{-| See [`M3e.Element.Accordion.Is`](M3e.Element.Accordion#Is).
-}
type alias AccordionIs s =
    Accordion_.Is s


{-| See [`M3e.Element.Accordion.Attrs`](M3e.Element.Accordion#Attrs).
-}
type alias AccordionAttrs =
    Accordion_.Attrs


{-| See [`M3e.Element.Accordion.Builder`](M3e.Element.Accordion#Builder).
-}
type alias AccordionBuilder attrCaps slotCaps msg kind =
    Accordion_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Accordion.AttrCaps`](M3e.Element.Accordion#AttrCaps).
-}
type alias AccordionAttrCaps =
    Accordion_.AttrCaps


{-| See [`M3e.Element.Accordion.SlotCaps`](M3e.Element.Accordion#SlotCaps).
-}
type alias AccordionSlotCaps =
    Accordion_.SlotCaps


{-| See [`M3e.Element.Accordion.Content`](M3e.Element.Accordion#Content).
-}
type alias AccordionContent =
    Accordion_.Content


{-| See [`M3e.Element.Accordion.ChildAdmittedBy`](M3e.Element.Accordion#ChildAdmittedBy).
-}
type alias AccordionChildAdmittedBy childAdm =
    Accordion_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Accordion.multi`](M3e.Element.Accordion#multi).
-}
accordionMulti : Bool -> Attr { c | multi : Supported } msg
accordionMulti =
    Accordion_.multi


{-| See [`M3e.Element.Accordion.child`](M3e.Element.Accordion#child).
-}
accordionChild : Element AccordionContent admittedBy msg -> Element free freeAdmittedBy msg
accordionChild =
    Accordion_.child


{-| The `panel` element of this family — delegates to [`M3e.Element.ExpansionPanel.component`](M3e.Element.ExpansionPanel#component).
-}
panel :
    { header : Element PanelHeaderSlot (PanelChildAdmittedBy childAdm) msg }
    -> List (Attr PanelAttrs msg)
    -> List (Element childAccepts (PanelChildAdmittedBy childAdm) msg)
    -> Element (PanelIs s) admittedBy msg
panel =
    Panel_.component


{-| See [`M3e.Element.ExpansionPanel.Is`](M3e.Element.ExpansionPanel#Is).
-}
type alias PanelIs s =
    Panel_.Is s


{-| See [`M3e.Element.ExpansionPanel.Attrs`](M3e.Element.ExpansionPanel#Attrs).
-}
type alias PanelAttrs =
    Panel_.Attrs


{-| See [`M3e.Element.ExpansionPanel.Builder`](M3e.Element.ExpansionPanel#Builder).
-}
type alias PanelBuilder attrCaps slotCaps msg kind =
    Panel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ExpansionPanel.AttrCaps`](M3e.Element.ExpansionPanel#AttrCaps).
-}
type alias PanelAttrCaps =
    Panel_.AttrCaps


{-| See [`M3e.Element.ExpansionPanel.SlotCaps`](M3e.Element.ExpansionPanel#SlotCaps).
-}
type alias PanelSlotCaps =
    Panel_.SlotCaps


{-| See [`M3e.Element.ExpansionPanel.HeaderSlot`](M3e.Element.ExpansionPanel#HeaderSlot).
-}
type alias PanelHeaderSlot =
    Panel_.HeaderSlot


{-| See [`M3e.Element.ExpansionPanel.ToggleIconSlot`](M3e.Element.ExpansionPanel#ToggleIconSlot).
-}
type alias PanelToggleIconSlot =
    Panel_.ToggleIconSlot


{-| See [`M3e.Element.ExpansionPanel.ChildAdmittedBy`](M3e.Element.ExpansionPanel#ChildAdmittedBy).
-}
type alias PanelChildAdmittedBy childAdm =
    Panel_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ExpansionPanel.ToggleDirection`](M3e.Element.ExpansionPanel#ToggleDirection).
-}
type alias PanelToggleDirection =
    Panel_.ToggleDirection


{-| See [`M3e.Element.ExpansionPanel.toggleDirection`](M3e.Element.ExpansionPanel#toggleDirection).
-}
panelToggleDirection : Value PanelToggleDirection -> Attr { c | toggleDirection : Supported } msg
panelToggleDirection =
    Panel_.toggleDirection


{-| See [`M3e.Element.ExpansionPanel.TogglePosition`](M3e.Element.ExpansionPanel#TogglePosition).
-}
type alias PanelTogglePosition =
    Panel_.TogglePosition


{-| See [`M3e.Element.ExpansionPanel.togglePosition`](M3e.Element.ExpansionPanel#togglePosition).
-}
panelTogglePosition : Value PanelTogglePosition -> Attr { c | togglePosition : Supported } msg
panelTogglePosition =
    Panel_.togglePosition


{-| See [`M3e.Element.ExpansionPanel.disabled`](M3e.Element.ExpansionPanel#disabled).
-}
panelDisabled : Bool -> Attr { c | disabled : Supported } msg
panelDisabled =
    Panel_.disabled


{-| See [`M3e.Element.ExpansionPanel.hideToggle`](M3e.Element.ExpansionPanel#hideToggle).
-}
panelHideToggle : Bool -> Attr { c | hideToggle : Supported } msg
panelHideToggle =
    Panel_.hideToggle


{-| See [`M3e.Element.ExpansionPanel.open`](M3e.Element.ExpansionPanel#open).
-}
panelOpen : Bool -> Attr { c | open : Supported } msg
panelOpen =
    Panel_.open


{-| See [`M3e.Element.ExpansionPanel.onOpening`](M3e.Element.ExpansionPanel#onOpening).
-}
panelOnOpening : msg -> Attr { c | onOpening : Supported } msg
panelOnOpening =
    Panel_.onOpening


{-| See [`M3e.Element.ExpansionPanel.onOpened`](M3e.Element.ExpansionPanel#onOpened).
-}
panelOnOpened : msg -> Attr { c | onOpened : Supported } msg
panelOnOpened =
    Panel_.onOpened


{-| See [`M3e.Element.ExpansionPanel.onClosing`](M3e.Element.ExpansionPanel#onClosing).
-}
panelOnClosing : msg -> Attr { c | onClosing : Supported } msg
panelOnClosing =
    Panel_.onClosing


{-| See [`M3e.Element.ExpansionPanel.onClosed`](M3e.Element.ExpansionPanel#onClosed).
-}
panelOnClosed : msg -> Attr { c | onClosed : Supported } msg
panelOnClosed =
    Panel_.onClosed


{-| See [`M3e.Element.ExpansionPanel.actions`](M3e.Element.ExpansionPanel#actions).
-}
panelActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelActions =
    Panel_.actions


{-| See [`M3e.Element.ExpansionPanel.header`](M3e.Element.ExpansionPanel#header).
-}
panelHeader : Element PanelHeaderSlot admittedBy msg -> Element free freeAdmittedBy msg
panelHeader =
    Panel_.header


{-| See [`M3e.Element.ExpansionPanel.toggleIcon`](M3e.Element.ExpansionPanel#toggleIcon).
-}
panelToggleIcon : Element PanelToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
panelToggleIcon =
    Panel_.toggleIcon


{-| See [`M3e.Element.ExpansionPanel.child`](M3e.Element.ExpansionPanel#child).
-}
panelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelChild =
    Panel_.child

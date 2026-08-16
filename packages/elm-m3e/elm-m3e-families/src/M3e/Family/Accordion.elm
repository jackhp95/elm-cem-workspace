module M3e.Family.Accordion exposing (AccordionIs, AccordionAttrs, AccordionBuilder, AccordionAttrCaps, AccordionSlotCaps, AccordionContent, AccordionChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelToggleIconSlot, PanelChildAdmittedBy, PanelToggleDirection, PanelTogglePosition, accordion, accordionMulti, accordionChild, panel, panelToggleDirection, panelTogglePosition, panelDisabled, panelHideToggle, panelOpen, panelOnOpening, panelOnOpened, panelOnClosing, panelOnClosed, panelActions, panelHeader, panelToggleIcon, panelChild)

{-| The **Accordion** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Accordion`](M3e.Component.Accordion) as `accordion`, [`M3e.Component.ExpansionPanel`](M3e.Component.ExpansionPanel) as `panel`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs AccordionIs, AccordionAttrs, AccordionBuilder, AccordionAttrCaps, AccordionSlotCaps, AccordionContent, AccordionChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelToggleIconSlot, PanelChildAdmittedBy, PanelToggleDirection, PanelTogglePosition, accordion, accordionMulti, accordionChild, panel, panelToggleDirection, panelTogglePosition, panelDisabled, panelHideToggle, panelOpen, panelOnOpening, panelOnOpened, panelOnClosing, panelOnClosed, panelActions, panelHeader, panelToggleIcon, panelChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Accordion as Accordion_
import M3e.Component.ExpansionPanel as Panel_


{-| The `accordion` element of this family — delegates to [`M3e.Component.Accordion.component`](M3e.Component.Accordion#component).
-}
accordion :
    { content : Element AccordionContent (AccordionChildAdmittedBy childAdm) msg }
    -> List (Attr AccordionAttrs msg)
    -> List (Element AccordionContent (AccordionChildAdmittedBy childAdm) msg)
    -> Element (AccordionIs s) admittedBy msg
accordion =
    Accordion_.component


{-| See [`M3e.Component.Accordion.Is`](M3e.Component.Accordion#Is).
-}
type alias AccordionIs s =
    Accordion_.Is s


{-| See [`M3e.Component.Accordion.Attrs`](M3e.Component.Accordion#Attrs).
-}
type alias AccordionAttrs =
    Accordion_.Attrs


{-| See [`M3e.Component.Accordion.Builder`](M3e.Component.Accordion#Builder).
-}
type alias AccordionBuilder attrCaps slotCaps msg kind =
    Accordion_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Accordion.AttrCaps`](M3e.Component.Accordion#AttrCaps).
-}
type alias AccordionAttrCaps =
    Accordion_.AttrCaps


{-| See [`M3e.Component.Accordion.SlotCaps`](M3e.Component.Accordion#SlotCaps).
-}
type alias AccordionSlotCaps =
    Accordion_.SlotCaps


{-| See [`M3e.Component.Accordion.Content`](M3e.Component.Accordion#Content).
-}
type alias AccordionContent =
    Accordion_.Content


{-| See [`M3e.Component.Accordion.ChildAdmittedBy`](M3e.Component.Accordion#ChildAdmittedBy).
-}
type alias AccordionChildAdmittedBy childAdm =
    Accordion_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Accordion.multi`](M3e.Component.Accordion#multi).
-}
accordionMulti : Bool -> Attr { c | multi : Supported } msg
accordionMulti =
    Accordion_.multi


{-| See [`M3e.Component.Accordion.child`](M3e.Component.Accordion#child).
-}
accordionChild : Element AccordionContent admittedBy msg -> Element free freeAdmittedBy msg
accordionChild =
    Accordion_.child


{-| The `panel` element of this family — delegates to [`M3e.Component.ExpansionPanel.component`](M3e.Component.ExpansionPanel#component).
-}
panel :
    { header : Element childAccepts (PanelChildAdmittedBy childAdm) msg }
    -> List (Attr PanelAttrs msg)
    -> List (Element childAccepts (PanelChildAdmittedBy childAdm) msg)
    -> Element (PanelIs s) admittedBy msg
panel =
    Panel_.component


{-| See [`M3e.Component.ExpansionPanel.Is`](M3e.Component.ExpansionPanel#Is).
-}
type alias PanelIs s =
    Panel_.Is s


{-| See [`M3e.Component.ExpansionPanel.Attrs`](M3e.Component.ExpansionPanel#Attrs).
-}
type alias PanelAttrs =
    Panel_.Attrs


{-| See [`M3e.Component.ExpansionPanel.Builder`](M3e.Component.ExpansionPanel#Builder).
-}
type alias PanelBuilder attrCaps slotCaps msg kind =
    Panel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.ExpansionPanel.AttrCaps`](M3e.Component.ExpansionPanel#AttrCaps).
-}
type alias PanelAttrCaps =
    Panel_.AttrCaps


{-| See [`M3e.Component.ExpansionPanel.SlotCaps`](M3e.Component.ExpansionPanel#SlotCaps).
-}
type alias PanelSlotCaps =
    Panel_.SlotCaps


{-| See [`M3e.Component.ExpansionPanel.ToggleIconSlot`](M3e.Component.ExpansionPanel#ToggleIconSlot).
-}
type alias PanelToggleIconSlot =
    Panel_.ToggleIconSlot


{-| See [`M3e.Component.ExpansionPanel.ChildAdmittedBy`](M3e.Component.ExpansionPanel#ChildAdmittedBy).
-}
type alias PanelChildAdmittedBy childAdm =
    Panel_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.ExpansionPanel.ToggleDirection`](M3e.Component.ExpansionPanel#ToggleDirection).
-}
type alias PanelToggleDirection =
    Panel_.ToggleDirection


{-| See [`M3e.Component.ExpansionPanel.toggleDirection`](M3e.Component.ExpansionPanel#toggleDirection).
-}
panelToggleDirection : Value PanelToggleDirection -> Attr { c | toggleDirection : Supported } msg
panelToggleDirection =
    Panel_.toggleDirection


{-| See [`M3e.Component.ExpansionPanel.TogglePosition`](M3e.Component.ExpansionPanel#TogglePosition).
-}
type alias PanelTogglePosition =
    Panel_.TogglePosition


{-| See [`M3e.Component.ExpansionPanel.togglePosition`](M3e.Component.ExpansionPanel#togglePosition).
-}
panelTogglePosition : Value PanelTogglePosition -> Attr { c | togglePosition : Supported } msg
panelTogglePosition =
    Panel_.togglePosition


{-| See [`M3e.Component.ExpansionPanel.disabled`](M3e.Component.ExpansionPanel#disabled).
-}
panelDisabled : Bool -> Attr { c | disabled : Supported } msg
panelDisabled =
    Panel_.disabled


{-| See [`M3e.Component.ExpansionPanel.hideToggle`](M3e.Component.ExpansionPanel#hideToggle).
-}
panelHideToggle : Bool -> Attr { c | hideToggle : Supported } msg
panelHideToggle =
    Panel_.hideToggle


{-| See [`M3e.Component.ExpansionPanel.open`](M3e.Component.ExpansionPanel#open).
-}
panelOpen : Bool -> Attr { c | open : Supported } msg
panelOpen =
    Panel_.open


{-| See [`M3e.Component.ExpansionPanel.onOpening`](M3e.Component.ExpansionPanel#onOpening).
-}
panelOnOpening : msg -> Attr { c | onOpening : Supported } msg
panelOnOpening =
    Panel_.onOpening


{-| See [`M3e.Component.ExpansionPanel.onOpened`](M3e.Component.ExpansionPanel#onOpened).
-}
panelOnOpened : msg -> Attr { c | onOpened : Supported } msg
panelOnOpened =
    Panel_.onOpened


{-| See [`M3e.Component.ExpansionPanel.onClosing`](M3e.Component.ExpansionPanel#onClosing).
-}
panelOnClosing : msg -> Attr { c | onClosing : Supported } msg
panelOnClosing =
    Panel_.onClosing


{-| See [`M3e.Component.ExpansionPanel.onClosed`](M3e.Component.ExpansionPanel#onClosed).
-}
panelOnClosed : msg -> Attr { c | onClosed : Supported } msg
panelOnClosed =
    Panel_.onClosed


{-| See [`M3e.Component.ExpansionPanel.actions`](M3e.Component.ExpansionPanel#actions).
-}
panelActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelActions =
    Panel_.actions


{-| See [`M3e.Component.ExpansionPanel.header`](M3e.Component.ExpansionPanel#header).
-}
panelHeader : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelHeader =
    Panel_.header


{-| See [`M3e.Component.ExpansionPanel.toggleIcon`](M3e.Component.ExpansionPanel#toggleIcon).
-}
panelToggleIcon : Element PanelToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
panelToggleIcon =
    Panel_.toggleIcon


{-| See [`M3e.Component.ExpansionPanel.child`](M3e.Component.ExpansionPanel#child).
-}
panelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelChild =
    Panel_.child

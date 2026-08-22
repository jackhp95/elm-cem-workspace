module Sl.Component.TabPanel exposing (TabPanelIs, TabPanelAttrs, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelChildAdmittedBy, tabPanel, tabPanelActive, tabPanelName)

{-| The **TabPanel** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.TabPanel`](Sl.Element.TabPanel) as `tabPanel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TabPanelIs, TabPanelAttrs, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelChildAdmittedBy, tabPanel, tabPanelActive, tabPanelName

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.TabPanel as TabPanel_


{-| The `tabPanel` element of this family — delegates to [`Sl.Element.TabPanel.component`](Sl.Element.TabPanel#component).
-}
tabPanel :
    List (Attr TabPanelAttrs msg)
    -> List (Element childAccepts (TabPanelChildAdmittedBy childAdm) msg)
    -> Element (TabPanelIs s) admittedBy msg
tabPanel =
    TabPanel_.component


{-| See [`Sl.Element.TabPanel.Is`](Sl.Element.TabPanel#Is).
-}
type alias TabPanelIs s =
    TabPanel_.Is s


{-| See [`Sl.Element.TabPanel.Attrs`](Sl.Element.TabPanel#Attrs).
-}
type alias TabPanelAttrs =
    TabPanel_.Attrs


{-| See [`Sl.Element.TabPanel.Builder`](Sl.Element.TabPanel#Builder).
-}
type alias TabPanelBuilder attrCaps slotCaps msg kind =
    TabPanel_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.TabPanel.AttrCaps`](Sl.Element.TabPanel#AttrCaps).
-}
type alias TabPanelAttrCaps =
    TabPanel_.AttrCaps


{-| See [`Sl.Element.TabPanel.SlotCaps`](Sl.Element.TabPanel#SlotCaps).
-}
type alias TabPanelSlotCaps =
    TabPanel_.SlotCaps


{-| See [`Sl.Element.TabPanel.ChildAdmittedBy`](Sl.Element.TabPanel#ChildAdmittedBy).
-}
type alias TabPanelChildAdmittedBy childAdm =
    TabPanel_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.TabPanel.active`](Sl.Element.TabPanel#active).
-}
tabPanelActive : Bool -> Attr { c | active : Supported } msg
tabPanelActive =
    TabPanel_.active


{-| See [`Sl.Element.TabPanel.name`](Sl.Element.TabPanel#name).
-}
tabPanelName : String -> Attr { c | name : Supported } msg
tabPanelName =
    TabPanel_.name

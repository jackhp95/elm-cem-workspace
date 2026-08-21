module M3e.Component.Tabs exposing (TabsIs, TabsAttrs, TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsContent, TabsNextIconSlot, TabsPanelSlot, TabsPrevIconSlot, TabsChildAdmittedBy, TabsDisablePagination, TabsHeaderPosition, TabsVariant, TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabContent, TabIconSlot, TabChildAdmittedBy, TabPanelIs, TabPanelAttrs, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelChildAdmittedBy, tabs, tabsDisablePagination, tabsHeaderPosition, tabsVariant, tabsNextPageLabel, tabsPreviousPageLabel, tabsStretch, tabsOnChange, tabsOnBeforeinput, tabsOnInput, tabsNextIcon, tabsPanel, tabsPrevIcon, tabsChild, tab, tabDisabled, tabFor, tabSelected, tabDefaultSelected, tabOnBeforeinput, tabOnInput, tabOnChange, tabOnClick, tabIcon, tabChild, tabPanel, tabPanelChild)

{-| The **Tabs** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Tabs`](M3e.Element.Tabs) as `tabs`, [`M3e.Element.Tab`](M3e.Element.Tab) as `tab`, [`M3e.Element.TabPanel`](M3e.Element.TabPanel) as `tabPanel`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TabsIs, TabsAttrs, TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsContent, TabsNextIconSlot, TabsPanelSlot, TabsPrevIconSlot, TabsChildAdmittedBy, TabsDisablePagination, TabsHeaderPosition, TabsVariant, TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabContent, TabIconSlot, TabChildAdmittedBy, TabPanelIs, TabPanelAttrs, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelChildAdmittedBy, tabs, tabsDisablePagination, tabsHeaderPosition, tabsVariant, tabsNextPageLabel, tabsPreviousPageLabel, tabsStretch, tabsOnChange, tabsOnBeforeinput, tabsOnInput, tabsNextIcon, tabsPanel, tabsPrevIcon, tabsChild, tab, tabDisabled, tabFor, tabSelected, tabDefaultSelected, tabOnBeforeinput, tabOnInput, tabOnChange, tabOnClick, tabIcon, tabChild, tabPanel, tabPanelChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Tab as Tab_
import M3e.Element.TabPanel as TabPanel_
import M3e.Element.Tabs as Tabs_


{-| The `tabs` element of this family — delegates to [`M3e.Element.Tabs.component`](M3e.Element.Tabs#component).
-}
tabs :
    List (Attr TabsAttrs msg)
    -> List (Element TabsContent (TabsChildAdmittedBy childAdm) msg)
    -> Element (TabsIs s) admittedBy msg
tabs =
    Tabs_.component


{-| See [`M3e.Element.Tabs.Is`](M3e.Element.Tabs#Is).
-}
type alias TabsIs s =
    Tabs_.Is s


{-| See [`M3e.Element.Tabs.Attrs`](M3e.Element.Tabs#Attrs).
-}
type alias TabsAttrs =
    Tabs_.Attrs


{-| See [`M3e.Element.Tabs.Builder`](M3e.Element.Tabs#Builder).
-}
type alias TabsBuilder attrCaps slotCaps msg kind =
    Tabs_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Tabs.AttrCaps`](M3e.Element.Tabs#AttrCaps).
-}
type alias TabsAttrCaps =
    Tabs_.AttrCaps


{-| See [`M3e.Element.Tabs.SlotCaps`](M3e.Element.Tabs#SlotCaps).
-}
type alias TabsSlotCaps =
    Tabs_.SlotCaps


{-| See [`M3e.Element.Tabs.Content`](M3e.Element.Tabs#Content).
-}
type alias TabsContent =
    Tabs_.Content


{-| See [`M3e.Element.Tabs.NextIconSlot`](M3e.Element.Tabs#NextIconSlot).
-}
type alias TabsNextIconSlot =
    Tabs_.NextIconSlot


{-| See [`M3e.Element.Tabs.PanelSlot`](M3e.Element.Tabs#PanelSlot).
-}
type alias TabsPanelSlot =
    Tabs_.PanelSlot


{-| See [`M3e.Element.Tabs.PrevIconSlot`](M3e.Element.Tabs#PrevIconSlot).
-}
type alias TabsPrevIconSlot =
    Tabs_.PrevIconSlot


{-| See [`M3e.Element.Tabs.ChildAdmittedBy`](M3e.Element.Tabs#ChildAdmittedBy).
-}
type alias TabsChildAdmittedBy childAdm =
    Tabs_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Tabs.DisablePagination`](M3e.Element.Tabs#DisablePagination).
-}
type alias TabsDisablePagination =
    Tabs_.DisablePagination


{-| See [`M3e.Element.Tabs.disablePagination`](M3e.Element.Tabs#disablePagination).
-}
tabsDisablePagination : Value TabsDisablePagination -> Attr { c | disablePagination : Supported } msg
tabsDisablePagination =
    Tabs_.disablePagination


{-| See [`M3e.Element.Tabs.HeaderPosition`](M3e.Element.Tabs#HeaderPosition).
-}
type alias TabsHeaderPosition =
    Tabs_.HeaderPosition


{-| See [`M3e.Element.Tabs.headerPosition`](M3e.Element.Tabs#headerPosition).
-}
tabsHeaderPosition : Value TabsHeaderPosition -> Attr { c | headerPosition : Supported } msg
tabsHeaderPosition =
    Tabs_.headerPosition


{-| See [`M3e.Element.Tabs.Variant`](M3e.Element.Tabs#Variant).
-}
type alias TabsVariant =
    Tabs_.Variant


{-| See [`M3e.Element.Tabs.variant`](M3e.Element.Tabs#variant).
-}
tabsVariant : Value TabsVariant -> Attr { c | variant : Supported } msg
tabsVariant =
    Tabs_.variant


{-| See [`M3e.Element.Tabs.nextPageLabel`](M3e.Element.Tabs#nextPageLabel).
-}
tabsNextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
tabsNextPageLabel =
    Tabs_.nextPageLabel


{-| See [`M3e.Element.Tabs.previousPageLabel`](M3e.Element.Tabs#previousPageLabel).
-}
tabsPreviousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
tabsPreviousPageLabel =
    Tabs_.previousPageLabel


{-| See [`M3e.Element.Tabs.stretch`](M3e.Element.Tabs#stretch).
-}
tabsStretch : Bool -> Attr { c | stretch : Supported } msg
tabsStretch =
    Tabs_.stretch


{-| See [`M3e.Element.Tabs.onChange`](M3e.Element.Tabs#onChange).
-}
tabsOnChange : msg -> Attr { c | onChange : Supported } msg
tabsOnChange =
    Tabs_.onChange


{-| See [`M3e.Element.Tabs.onBeforeinput`](M3e.Element.Tabs#onBeforeinput).
-}
tabsOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
tabsOnBeforeinput =
    Tabs_.onBeforeinput


{-| See [`M3e.Element.Tabs.onInput`](M3e.Element.Tabs#onInput).
-}
tabsOnInput : msg -> Attr { c | onInput : Supported } msg
tabsOnInput =
    Tabs_.onInput


{-| See [`M3e.Element.Tabs.nextIcon`](M3e.Element.Tabs#nextIcon).
-}
tabsNextIcon : Element TabsNextIconSlot admittedBy msg -> Element free freeAdmittedBy msg
tabsNextIcon =
    Tabs_.nextIcon


{-| See [`M3e.Element.Tabs.panel`](M3e.Element.Tabs#panel).
-}
tabsPanel : Element TabsPanelSlot admittedBy msg -> Element free freeAdmittedBy msg
tabsPanel =
    Tabs_.panel


{-| See [`M3e.Element.Tabs.prevIcon`](M3e.Element.Tabs#prevIcon).
-}
tabsPrevIcon : Element TabsPrevIconSlot admittedBy msg -> Element free freeAdmittedBy msg
tabsPrevIcon =
    Tabs_.prevIcon


{-| See [`M3e.Element.Tabs.child`](M3e.Element.Tabs#child).
-}
tabsChild : Element TabsContent admittedBy msg -> Element free freeAdmittedBy msg
tabsChild =
    Tabs_.child


{-| The `tab` element of this family — delegates to [`M3e.Element.Tab.component`](M3e.Element.Tab#component).
-}
tab :
    List (Attr TabAttrs msg)
    -> List (Element TabContent (TabChildAdmittedBy childAdm) msg)
    -> Element (TabIs s) admittedBy msg
tab =
    Tab_.component


{-| See [`M3e.Element.Tab.Is`](M3e.Element.Tab#Is).
-}
type alias TabIs s =
    Tab_.Is s


{-| See [`M3e.Element.Tab.Attrs`](M3e.Element.Tab#Attrs).
-}
type alias TabAttrs =
    Tab_.Attrs


{-| See [`M3e.Element.Tab.Builder`](M3e.Element.Tab#Builder).
-}
type alias TabBuilder attrCaps slotCaps msg kind =
    Tab_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Tab.AttrCaps`](M3e.Element.Tab#AttrCaps).
-}
type alias TabAttrCaps =
    Tab_.AttrCaps


{-| See [`M3e.Element.Tab.SlotCaps`](M3e.Element.Tab#SlotCaps).
-}
type alias TabSlotCaps =
    Tab_.SlotCaps


{-| See [`M3e.Element.Tab.Content`](M3e.Element.Tab#Content).
-}
type alias TabContent =
    Tab_.Content


{-| See [`M3e.Element.Tab.IconSlot`](M3e.Element.Tab#IconSlot).
-}
type alias TabIconSlot =
    Tab_.IconSlot


{-| See [`M3e.Element.Tab.ChildAdmittedBy`](M3e.Element.Tab#ChildAdmittedBy).
-}
type alias TabChildAdmittedBy childAdm =
    Tab_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Tab.disabled`](M3e.Element.Tab#disabled).
-}
tabDisabled : Bool -> Attr { c | disabled : Supported } msg
tabDisabled =
    Tab_.disabled


{-| See [`M3e.Element.Tab.for`](M3e.Element.Tab#for).
-}
tabFor : String -> Attr { c | for : Supported } msg
tabFor =
    Tab_.for


{-| See [`M3e.Element.Tab.selected`](M3e.Element.Tab#selected).
-}
tabSelected : Bool -> Attr { c | selected : Supported } msg
tabSelected =
    Tab_.selected


{-| See [`M3e.Element.Tab.defaultSelected`](M3e.Element.Tab#defaultSelected).
-}
tabDefaultSelected : Bool -> Attr { c | selected : Supported } msg
tabDefaultSelected =
    Tab_.defaultSelected


{-| See [`M3e.Element.Tab.onBeforeinput`](M3e.Element.Tab#onBeforeinput).
-}
tabOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
tabOnBeforeinput =
    Tab_.onBeforeinput


{-| See [`M3e.Element.Tab.onInput`](M3e.Element.Tab#onInput).
-}
tabOnInput : msg -> Attr { c | onInput : Supported } msg
tabOnInput =
    Tab_.onInput


{-| See [`M3e.Element.Tab.onChange`](M3e.Element.Tab#onChange).
-}
tabOnChange : msg -> Attr { c | onChange : Supported } msg
tabOnChange =
    Tab_.onChange


{-| See [`M3e.Element.Tab.onClick`](M3e.Element.Tab#onClick).
-}
tabOnClick : msg -> Attr { c | onClick : Supported } msg
tabOnClick =
    Tab_.onClick


{-| See [`M3e.Element.Tab.icon`](M3e.Element.Tab#icon).
-}
tabIcon : Element TabIconSlot admittedBy msg -> Element free freeAdmittedBy msg
tabIcon =
    Tab_.icon


{-| See [`M3e.Element.Tab.child`](M3e.Element.Tab#child).
-}
tabChild : Element TabContent admittedBy msg -> Element free freeAdmittedBy msg
tabChild =
    Tab_.child


{-| The `tabPanel` element of this family — delegates to [`M3e.Element.TabPanel.component`](M3e.Element.TabPanel#component).
-}
tabPanel :
    List (Attr TabPanelAttrs msg)
    -> List (Element childAccepts (TabPanelChildAdmittedBy childAdm) msg)
    -> Element (TabPanelIs s) admittedBy msg
tabPanel =
    TabPanel_.component


{-| See [`M3e.Element.TabPanel.Is`](M3e.Element.TabPanel#Is).
-}
type alias TabPanelIs s =
    TabPanel_.Is s


{-| See [`M3e.Element.TabPanel.Attrs`](M3e.Element.TabPanel#Attrs).
-}
type alias TabPanelAttrs =
    TabPanel_.Attrs


{-| See [`M3e.Element.TabPanel.Builder`](M3e.Element.TabPanel#Builder).
-}
type alias TabPanelBuilder attrCaps slotCaps msg kind =
    TabPanel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TabPanel.AttrCaps`](M3e.Element.TabPanel#AttrCaps).
-}
type alias TabPanelAttrCaps =
    TabPanel_.AttrCaps


{-| See [`M3e.Element.TabPanel.SlotCaps`](M3e.Element.TabPanel#SlotCaps).
-}
type alias TabPanelSlotCaps =
    TabPanel_.SlotCaps


{-| See [`M3e.Element.TabPanel.ChildAdmittedBy`](M3e.Element.TabPanel#ChildAdmittedBy).
-}
type alias TabPanelChildAdmittedBy childAdm =
    TabPanel_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TabPanel.child`](M3e.Element.TabPanel#child).
-}
tabPanelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
tabPanelChild =
    TabPanel_.child

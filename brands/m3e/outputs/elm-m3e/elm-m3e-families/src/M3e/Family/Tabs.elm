module M3e.Family.Tabs exposing (TabsIs, TabsAttrs, TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsContent, TabsNextIconSlot, TabsPanelSlot, TabsPrevIconSlot, TabsChildAdmittedBy, TabsDisablePagination, TabsHeaderPosition, TabsVariant, TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabContent, TabIconSlot, TabChildAdmittedBy, TabPanelIs, TabPanelAttrs, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelChildAdmittedBy, tabs, tabsDisablePagination, tabsHeaderPosition, tabsVariant, tabsNextPageLabel, tabsPreviousPageLabel, tabsStretch, tabsOnChange, tabsOnBeforeinput, tabsOnInput, tabsNextIcon, tabsPanel, tabsPrevIcon, tabsChild, tab, tabDisabled, tabFor, tabSelected, tabDefaultSelected, tabOnBeforeinput, tabOnInput, tabOnChange, tabOnClick, tabIcon, tabChild, tabPanel, tabPanelChild)

{-| The **Tabs** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Tabs`](M3e.Component.Tabs) as `tabs`, [`M3e.Component.Tab`](M3e.Component.Tab) as `tab`, [`M3e.Component.TabPanel`](M3e.Component.TabPanel) as `tabPanel`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs TabsIs, TabsAttrs, TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsContent, TabsNextIconSlot, TabsPanelSlot, TabsPrevIconSlot, TabsChildAdmittedBy, TabsDisablePagination, TabsHeaderPosition, TabsVariant, TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabContent, TabIconSlot, TabChildAdmittedBy, TabPanelIs, TabPanelAttrs, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelChildAdmittedBy, tabs, tabsDisablePagination, tabsHeaderPosition, tabsVariant, tabsNextPageLabel, tabsPreviousPageLabel, tabsStretch, tabsOnChange, tabsOnBeforeinput, tabsOnInput, tabsNextIcon, tabsPanel, tabsPrevIcon, tabsChild, tab, tabDisabled, tabFor, tabSelected, tabDefaultSelected, tabOnBeforeinput, tabOnInput, tabOnChange, tabOnClick, tabIcon, tabChild, tabPanel, tabPanelChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Tab as Tab_
import M3e.Component.TabPanel as TabPanel_
import M3e.Component.Tabs as Tabs_


{-| The `tabs` element of this family — delegates to [`M3e.Component.Tabs.component`](M3e.Component.Tabs#component).
-}
tabs :
    List (Attr TabsAttrs msg)
    -> List (Element TabsContent (TabsChildAdmittedBy childAdm) msg)
    -> Element (TabsIs s) admittedBy msg
tabs =
    Tabs_.component


{-| See [`M3e.Component.Tabs.Is`](M3e.Component.Tabs#Is).
-}
type alias TabsIs s =
    Tabs_.Is s


{-| See [`M3e.Component.Tabs.Attrs`](M3e.Component.Tabs#Attrs).
-}
type alias TabsAttrs =
    Tabs_.Attrs


{-| See [`M3e.Component.Tabs.Builder`](M3e.Component.Tabs#Builder).
-}
type alias TabsBuilder attrCaps slotCaps msg kind =
    Tabs_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Tabs.AttrCaps`](M3e.Component.Tabs#AttrCaps).
-}
type alias TabsAttrCaps =
    Tabs_.AttrCaps


{-| See [`M3e.Component.Tabs.SlotCaps`](M3e.Component.Tabs#SlotCaps).
-}
type alias TabsSlotCaps =
    Tabs_.SlotCaps


{-| See [`M3e.Component.Tabs.Content`](M3e.Component.Tabs#Content).
-}
type alias TabsContent =
    Tabs_.Content


{-| See [`M3e.Component.Tabs.NextIconSlot`](M3e.Component.Tabs#NextIconSlot).
-}
type alias TabsNextIconSlot =
    Tabs_.NextIconSlot


{-| See [`M3e.Component.Tabs.PanelSlot`](M3e.Component.Tabs#PanelSlot).
-}
type alias TabsPanelSlot =
    Tabs_.PanelSlot


{-| See [`M3e.Component.Tabs.PrevIconSlot`](M3e.Component.Tabs#PrevIconSlot).
-}
type alias TabsPrevIconSlot =
    Tabs_.PrevIconSlot


{-| See [`M3e.Component.Tabs.ChildAdmittedBy`](M3e.Component.Tabs#ChildAdmittedBy).
-}
type alias TabsChildAdmittedBy childAdm =
    Tabs_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Tabs.DisablePagination`](M3e.Component.Tabs#DisablePagination).
-}
type alias TabsDisablePagination =
    Tabs_.DisablePagination


{-| See [`M3e.Component.Tabs.disablePagination`](M3e.Component.Tabs#disablePagination).
-}
tabsDisablePagination : Value TabsDisablePagination -> Attr { c | disablePagination : Supported } msg
tabsDisablePagination =
    Tabs_.disablePagination


{-| See [`M3e.Component.Tabs.HeaderPosition`](M3e.Component.Tabs#HeaderPosition).
-}
type alias TabsHeaderPosition =
    Tabs_.HeaderPosition


{-| See [`M3e.Component.Tabs.headerPosition`](M3e.Component.Tabs#headerPosition).
-}
tabsHeaderPosition : Value TabsHeaderPosition -> Attr { c | headerPosition : Supported } msg
tabsHeaderPosition =
    Tabs_.headerPosition


{-| See [`M3e.Component.Tabs.Variant`](M3e.Component.Tabs#Variant).
-}
type alias TabsVariant =
    Tabs_.Variant


{-| See [`M3e.Component.Tabs.variant`](M3e.Component.Tabs#variant).
-}
tabsVariant : Value TabsVariant -> Attr { c | variant : Supported } msg
tabsVariant =
    Tabs_.variant


{-| See [`M3e.Component.Tabs.nextPageLabel`](M3e.Component.Tabs#nextPageLabel).
-}
tabsNextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
tabsNextPageLabel =
    Tabs_.nextPageLabel


{-| See [`M3e.Component.Tabs.previousPageLabel`](M3e.Component.Tabs#previousPageLabel).
-}
tabsPreviousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
tabsPreviousPageLabel =
    Tabs_.previousPageLabel


{-| See [`M3e.Component.Tabs.stretch`](M3e.Component.Tabs#stretch).
-}
tabsStretch : Bool -> Attr { c | stretch : Supported } msg
tabsStretch =
    Tabs_.stretch


{-| See [`M3e.Component.Tabs.onChange`](M3e.Component.Tabs#onChange).
-}
tabsOnChange : msg -> Attr { c | onChange : Supported } msg
tabsOnChange =
    Tabs_.onChange


{-| See [`M3e.Component.Tabs.onBeforeinput`](M3e.Component.Tabs#onBeforeinput).
-}
tabsOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
tabsOnBeforeinput =
    Tabs_.onBeforeinput


{-| See [`M3e.Component.Tabs.onInput`](M3e.Component.Tabs#onInput).
-}
tabsOnInput : msg -> Attr { c | onInput : Supported } msg
tabsOnInput =
    Tabs_.onInput


{-| See [`M3e.Component.Tabs.nextIcon`](M3e.Component.Tabs#nextIcon).
-}
tabsNextIcon : Element TabsNextIconSlot admittedBy msg -> Element free freeAdmittedBy msg
tabsNextIcon =
    Tabs_.nextIcon


{-| See [`M3e.Component.Tabs.panel`](M3e.Component.Tabs#panel).
-}
tabsPanel : Element TabsPanelSlot admittedBy msg -> Element free freeAdmittedBy msg
tabsPanel =
    Tabs_.panel


{-| See [`M3e.Component.Tabs.prevIcon`](M3e.Component.Tabs#prevIcon).
-}
tabsPrevIcon : Element TabsPrevIconSlot admittedBy msg -> Element free freeAdmittedBy msg
tabsPrevIcon =
    Tabs_.prevIcon


{-| See [`M3e.Component.Tabs.child`](M3e.Component.Tabs#child).
-}
tabsChild : Element TabsContent admittedBy msg -> Element free freeAdmittedBy msg
tabsChild =
    Tabs_.child


{-| The `tab` element of this family — delegates to [`M3e.Component.Tab.component`](M3e.Component.Tab#component).
-}
tab :
    List (Attr TabAttrs msg)
    -> List (Element TabContent (TabChildAdmittedBy childAdm) msg)
    -> Element (TabIs s) admittedBy msg
tab =
    Tab_.component


{-| See [`M3e.Component.Tab.Is`](M3e.Component.Tab#Is).
-}
type alias TabIs s =
    Tab_.Is s


{-| See [`M3e.Component.Tab.Attrs`](M3e.Component.Tab#Attrs).
-}
type alias TabAttrs =
    Tab_.Attrs


{-| See [`M3e.Component.Tab.Builder`](M3e.Component.Tab#Builder).
-}
type alias TabBuilder attrCaps slotCaps msg kind =
    Tab_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Tab.AttrCaps`](M3e.Component.Tab#AttrCaps).
-}
type alias TabAttrCaps =
    Tab_.AttrCaps


{-| See [`M3e.Component.Tab.SlotCaps`](M3e.Component.Tab#SlotCaps).
-}
type alias TabSlotCaps =
    Tab_.SlotCaps


{-| See [`M3e.Component.Tab.Content`](M3e.Component.Tab#Content).
-}
type alias TabContent =
    Tab_.Content


{-| See [`M3e.Component.Tab.IconSlot`](M3e.Component.Tab#IconSlot).
-}
type alias TabIconSlot =
    Tab_.IconSlot


{-| See [`M3e.Component.Tab.ChildAdmittedBy`](M3e.Component.Tab#ChildAdmittedBy).
-}
type alias TabChildAdmittedBy childAdm =
    Tab_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Tab.disabled`](M3e.Component.Tab#disabled).
-}
tabDisabled : Bool -> Attr { c | disabled : Supported } msg
tabDisabled =
    Tab_.disabled


{-| See [`M3e.Component.Tab.for`](M3e.Component.Tab#for).
-}
tabFor : String -> Attr { c | for : Supported } msg
tabFor =
    Tab_.for


{-| See [`M3e.Component.Tab.selected`](M3e.Component.Tab#selected).
-}
tabSelected : Bool -> Attr { c | selected : Supported } msg
tabSelected =
    Tab_.selected


{-| See [`M3e.Component.Tab.defaultSelected`](M3e.Component.Tab#defaultSelected).
-}
tabDefaultSelected : Bool -> Attr { c | selected : Supported } msg
tabDefaultSelected =
    Tab_.defaultSelected


{-| See [`M3e.Component.Tab.onBeforeinput`](M3e.Component.Tab#onBeforeinput).
-}
tabOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
tabOnBeforeinput =
    Tab_.onBeforeinput


{-| See [`M3e.Component.Tab.onInput`](M3e.Component.Tab#onInput).
-}
tabOnInput : msg -> Attr { c | onInput : Supported } msg
tabOnInput =
    Tab_.onInput


{-| See [`M3e.Component.Tab.onChange`](M3e.Component.Tab#onChange).
-}
tabOnChange : msg -> Attr { c | onChange : Supported } msg
tabOnChange =
    Tab_.onChange


{-| See [`M3e.Component.Tab.onClick`](M3e.Component.Tab#onClick).
-}
tabOnClick : msg -> Attr { c | onClick : Supported } msg
tabOnClick =
    Tab_.onClick


{-| See [`M3e.Component.Tab.icon`](M3e.Component.Tab#icon).
-}
tabIcon : Element TabIconSlot admittedBy msg -> Element free freeAdmittedBy msg
tabIcon =
    Tab_.icon


{-| See [`M3e.Component.Tab.child`](M3e.Component.Tab#child).
-}
tabChild : Element TabContent admittedBy msg -> Element free freeAdmittedBy msg
tabChild =
    Tab_.child


{-| The `tabPanel` element of this family — delegates to [`M3e.Component.TabPanel.component`](M3e.Component.TabPanel#component).
-}
tabPanel :
    List (Attr TabPanelAttrs msg)
    -> List (Element childAccepts (TabPanelChildAdmittedBy childAdm) msg)
    -> Element (TabPanelIs s) admittedBy msg
tabPanel =
    TabPanel_.component


{-| See [`M3e.Component.TabPanel.Is`](M3e.Component.TabPanel#Is).
-}
type alias TabPanelIs s =
    TabPanel_.Is s


{-| See [`M3e.Component.TabPanel.Attrs`](M3e.Component.TabPanel#Attrs).
-}
type alias TabPanelAttrs =
    TabPanel_.Attrs


{-| See [`M3e.Component.TabPanel.Builder`](M3e.Component.TabPanel#Builder).
-}
type alias TabPanelBuilder attrCaps slotCaps msg kind =
    TabPanel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.TabPanel.AttrCaps`](M3e.Component.TabPanel#AttrCaps).
-}
type alias TabPanelAttrCaps =
    TabPanel_.AttrCaps


{-| See [`M3e.Component.TabPanel.SlotCaps`](M3e.Component.TabPanel#SlotCaps).
-}
type alias TabPanelSlotCaps =
    TabPanel_.SlotCaps


{-| See [`M3e.Component.TabPanel.ChildAdmittedBy`](M3e.Component.TabPanel#ChildAdmittedBy).
-}
type alias TabPanelChildAdmittedBy childAdm =
    TabPanel_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.TabPanel.child`](M3e.Component.TabPanel#child).
-}
tabPanelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
tabPanelChild =
    TabPanel_.child

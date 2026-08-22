module M3e.Build.Tabs exposing (TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsIs, TabsContent, TabsNextIconSlot, TabsPanelSlot, TabsPrevIconSlot, TabsChildAdmittedBy, tabsBuild, tabsToElement, tabsWithClass, tabsWithDisablePagination, tabsWithHeaderPosition, tabsWithId, tabsWithNextPageLabel, tabsWithOnBeforeinput, tabsWithOnChange, tabsWithOnInput, tabsWithPreviousPageLabel, tabsWithSlot, tabsWithStretch, tabsWithStyle, tabsWithVariant, tabsNextIcon, tabsPanel, tabsPrevIcon, tabsWithNextIcon, tabsWithPrevIcon, tabsWithPanel, tabsWithChild, TabBuilder, TabAttrCaps, TabSlotCaps, TabIs, TabContent, TabIconSlot, TabChildAdmittedBy, tabBuild, tabToElement, tabWithClass, tabWithDisabled, tabWithFor, tabWithId, tabWithOnBeforeinput, tabWithOnChange, tabWithOnClick, tabWithOnInput, tabWithSelected, tabWithSlot, tabWithStyle, tabIcon, tabWithIcon, tabWithChild, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelIs, TabPanelChildAdmittedBy, tabPanelBuild, tabPanelToElement, tabPanelWithClass, tabPanelWithId, tabPanelWithSlot, tabPanelWithStyle, tabPanelWithChild)

{-| The **Tabs** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Tabs`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsIs, TabsContent, TabsNextIconSlot, TabsPanelSlot, TabsPrevIconSlot, TabsChildAdmittedBy, tabsBuild, tabsToElement, tabsWithClass, tabsWithDisablePagination, tabsWithHeaderPosition, tabsWithId, tabsWithNextPageLabel, tabsWithOnBeforeinput, tabsWithOnChange, tabsWithOnInput, tabsWithPreviousPageLabel, tabsWithSlot, tabsWithStretch, tabsWithStyle, tabsWithVariant, tabsNextIcon, tabsPanel, tabsPrevIcon, tabsWithNextIcon, tabsWithPrevIcon, tabsWithPanel, tabsWithChild, TabBuilder, TabAttrCaps, TabSlotCaps, TabIs, TabContent, TabIconSlot, TabChildAdmittedBy, tabBuild, tabToElement, tabWithClass, tabWithDisabled, tabWithFor, tabWithId, tabWithOnBeforeinput, tabWithOnChange, tabWithOnClick, tabWithOnInput, tabWithSelected, tabWithSlot, tabWithStyle, tabIcon, tabWithIcon, tabWithChild, TabPanelBuilder, TabPanelAttrCaps, TabPanelSlotCaps, TabPanelIs, TabPanelChildAdmittedBy, tabPanelBuild, tabPanelToElement, tabPanelWithClass, tabPanelWithId, tabPanelWithSlot, tabPanelWithStyle, tabPanelWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Tabs as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias TabsIs s =
    Component.TabsIs s


{-| -}
type alias TabsBuilder attrCaps slotCaps msg kind =
    Component.TabsBuilder attrCaps slotCaps msg kind


{-| -}
type alias TabsAttrCaps =
    Component.TabsAttrCaps


{-| -}
type alias TabsSlotCaps =
    Component.TabsSlotCaps


{-| -}
type alias TabsChildAdmittedBy childAdm =
    Component.TabsChildAdmittedBy childAdm


{-| -}
type alias TabsContent =
    Component.TabsContent


{-| -}
type alias TabsNextIconSlot =
    Component.TabsNextIconSlot


{-| -}
type alias TabsPanelSlot =
    Component.TabsPanelSlot


{-| -}
type alias TabsPrevIconSlot =
    Component.TabsPrevIconSlot


{-| -}
tabsBuild : TabsBuilder TabsAttrCaps TabsSlotCaps msg kind
tabsBuild =
    B.init "m3e-tabs" [] []


{-| -}
tabsToElement : TabsBuilder attrCaps slotCaps msg kind -> Element (Component.TabsIs kind) admittedBy msg
tabsToElement =
    B.toElement


{-| -}
tabsNextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabsNextIconSlot msg
    -> Element free freeAdmittedBy msg
tabsNextIcon builder =
    Component.tabsNextIcon (B.toElement builder)


{-| -}
tabsPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabsPanelSlot msg
    -> Element free freeAdmittedBy msg
tabsPanel builder =
    Component.tabsPanel (B.toElement builder)


{-| -}
tabsPrevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabsPrevIconSlot msg
    -> Element free freeAdmittedBy msg
tabsPrevIcon builder =
    Component.tabsPrevIcon (B.toElement builder)


{-| -}
tabsWithNextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabsNextIconSlot msg
    -> TabsBuilder attrCaps { s | nextIcon : Available } msg kind
    -> TabsBuilder attrCaps { s | nextIcon : Used } msg kind
tabsWithNextIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.tabsNextIcon (B.toElement slotBuilder))) builder_


{-| -}
tabsWithPrevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabsPrevIconSlot msg
    -> TabsBuilder attrCaps { s | prevIcon : Available } msg kind
    -> TabsBuilder attrCaps { s | prevIcon : Used } msg kind
tabsWithPrevIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.tabsPrevIcon (B.toElement slotBuilder))) builder_


{-| -}
tabsWithPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabsPanelSlot msg
    -> TabsBuilder attrCaps slotCaps msg kind
    -> TabsBuilder attrCaps slotCaps msg kind
tabsWithPanel slotBuilder builder_ =
    B.withChild (El.toNode (Component.tabsPanel (B.toElement slotBuilder))) builder_


{-| -}
tabsWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TabsBuilder attrCaps slotCaps msg kind
    -> TabsBuilder attrCaps slotCaps msg kind
tabsWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
tabsWithClass : String -> TabsBuilder { a | class : Available } slotCaps msg kind -> TabsBuilder { a | class : Used } slotCaps msg kind
tabsWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
tabsWithId : String -> TabsBuilder { a | id : Available } slotCaps msg kind -> TabsBuilder { a | id : Used } slotCaps msg kind
tabsWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
tabsWithSlot : String -> TabsBuilder { a | slot : Available } slotCaps msg kind -> TabsBuilder { a | slot : Used } slotCaps msg kind
tabsWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
tabsWithStyle : String -> String -> TabsBuilder { a | style : Available } slotCaps msg kind -> TabsBuilder { a | style : Used } slotCaps msg kind
tabsWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
tabsWithDisablePagination : Value Component.TabsDisablePagination -> TabsBuilder { a | disablePagination : Available } slotCaps msg kind -> TabsBuilder { a | disablePagination : Used } slotCaps msg kind
tabsWithDisablePagination value_ =
    B.withAttribute (Component.tabsDisablePagination value_)


{-| -}
tabsWithHeaderPosition : Value Component.TabsHeaderPosition -> TabsBuilder { a | headerPosition : Available } slotCaps msg kind -> TabsBuilder { a | headerPosition : Used } slotCaps msg kind
tabsWithHeaderPosition value_ =
    B.withAttribute (Component.tabsHeaderPosition value_)


{-| -}
tabsWithNextPageLabel : String -> TabsBuilder { a | nextPageLabel : Available } slotCaps msg kind -> TabsBuilder { a | nextPageLabel : Used } slotCaps msg kind
tabsWithNextPageLabel value_ =
    B.withAttribute (A.nextPageLabel value_)


{-| -}
tabsWithPreviousPageLabel : String -> TabsBuilder { a | previousPageLabel : Available } slotCaps msg kind -> TabsBuilder { a | previousPageLabel : Used } slotCaps msg kind
tabsWithPreviousPageLabel value_ =
    B.withAttribute (A.previousPageLabel value_)


{-| -}
tabsWithStretch : Bool -> TabsBuilder { a | stretch : Available } slotCaps msg kind -> TabsBuilder { a | stretch : Used } slotCaps msg kind
tabsWithStretch value_ =
    B.withAttribute (A.stretch value_)


{-| -}
tabsWithVariant : Value Component.TabsVariant -> TabsBuilder { a | variant : Available } slotCaps msg kind -> TabsBuilder { a | variant : Used } slotCaps msg kind
tabsWithVariant value_ =
    B.withAttribute (Component.tabsVariant value_)


{-| -}
tabsWithOnChange : msg -> TabsBuilder { a | onChange : Available } slotCaps msg kind -> TabsBuilder { a | onChange : Used } slotCaps msg kind
tabsWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
tabsWithOnBeforeinput : msg -> TabsBuilder { a | onBeforeinput : Available } slotCaps msg kind -> TabsBuilder { a | onBeforeinput : Used } slotCaps msg kind
tabsWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
tabsWithOnInput : msg -> TabsBuilder { a | onInput : Available } slotCaps msg kind -> TabsBuilder { a | onInput : Used } slotCaps msg kind
tabsWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
type alias TabIs s =
    Component.TabIs s


{-| -}
type alias TabBuilder attrCaps slotCaps msg kind =
    Component.TabBuilder attrCaps slotCaps msg kind


{-| -}
type alias TabAttrCaps =
    Component.TabAttrCaps


{-| -}
type alias TabSlotCaps =
    Component.TabSlotCaps


{-| -}
type alias TabChildAdmittedBy childAdm =
    Component.TabChildAdmittedBy childAdm


{-| -}
type alias TabContent =
    Component.TabContent


{-| -}
type alias TabIconSlot =
    Component.TabIconSlot


{-| -}
tabBuild : TabBuilder TabAttrCaps TabSlotCaps msg kind
tabBuild =
    B.init "m3e-tab" [] []


{-| -}
tabToElement : TabBuilder attrCaps slotCaps msg kind -> Element (Component.TabIs kind) admittedBy msg
tabToElement =
    B.toElement


{-| -}
tabIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabIconSlot msg
    -> Element free freeAdmittedBy msg
tabIcon builder =
    Component.tabIcon (B.toElement builder)


{-| -}
tabWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.TabIconSlot msg
    -> TabBuilder attrCaps { s | icon : Available } msg kind
    -> TabBuilder attrCaps { s | icon : Used } msg kind
tabWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.tabIcon (B.toElement slotBuilder))) builder_


{-| -}
tabWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TabBuilder attrCaps slotCaps msg kind
    -> TabBuilder attrCaps slotCaps msg kind
tabWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
tabWithClass : String -> TabBuilder { a | class : Available } slotCaps msg kind -> TabBuilder { a | class : Used } slotCaps msg kind
tabWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
tabWithId : String -> TabBuilder { a | id : Available } slotCaps msg kind -> TabBuilder { a | id : Used } slotCaps msg kind
tabWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
tabWithSlot : String -> TabBuilder { a | slot : Available } slotCaps msg kind -> TabBuilder { a | slot : Used } slotCaps msg kind
tabWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
tabWithStyle : String -> String -> TabBuilder { a | style : Available } slotCaps msg kind -> TabBuilder { a | style : Used } slotCaps msg kind
tabWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
tabWithDisabled : Bool -> TabBuilder { a | disabled : Available } slotCaps msg kind -> TabBuilder { a | disabled : Used } slotCaps msg kind
tabWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
tabWithFor : String -> TabBuilder { a | for : Available } slotCaps msg kind -> TabBuilder { a | for : Used } slotCaps msg kind
tabWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
tabWithSelected : Bool -> TabBuilder { a | selected : Available } slotCaps msg kind -> TabBuilder { a | selected : Used } slotCaps msg kind
tabWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
tabWithOnBeforeinput : msg -> TabBuilder { a | onBeforeinput : Available } slotCaps msg kind -> TabBuilder { a | onBeforeinput : Used } slotCaps msg kind
tabWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
tabWithOnInput : msg -> TabBuilder { a | onInput : Available } slotCaps msg kind -> TabBuilder { a | onInput : Used } slotCaps msg kind
tabWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
tabWithOnChange : msg -> TabBuilder { a | onChange : Available } slotCaps msg kind -> TabBuilder { a | onChange : Used } slotCaps msg kind
tabWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
tabWithOnClick : msg -> TabBuilder { a | onClick : Available } slotCaps msg kind -> TabBuilder { a | onClick : Used } slotCaps msg kind
tabWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias TabPanelIs s =
    Component.TabPanelIs s


{-| -}
type alias TabPanelBuilder attrCaps slotCaps msg kind =
    Component.TabPanelBuilder attrCaps slotCaps msg kind


{-| -}
type alias TabPanelAttrCaps =
    Component.TabPanelAttrCaps


{-| -}
type alias TabPanelSlotCaps =
    Component.TabPanelSlotCaps


{-| -}
type alias TabPanelChildAdmittedBy childAdm =
    Component.TabPanelChildAdmittedBy childAdm


{-| -}
tabPanelBuild : TabPanelBuilder TabPanelAttrCaps TabPanelSlotCaps msg kind
tabPanelBuild =
    B.init "m3e-tab-panel" [] []


{-| -}
tabPanelToElement : TabPanelBuilder attrCaps slotCaps msg kind -> Element (Component.TabPanelIs kind) admittedBy msg
tabPanelToElement =
    B.toElement


{-| -}
tabPanelWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TabPanelBuilder attrCaps slotCaps msg kind
    -> TabPanelBuilder attrCaps slotCaps msg kind
tabPanelWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
tabPanelWithClass : String -> TabPanelBuilder { a | class : Available } slotCaps msg kind -> TabPanelBuilder { a | class : Used } slotCaps msg kind
tabPanelWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
tabPanelWithId : String -> TabPanelBuilder { a | id : Available } slotCaps msg kind -> TabPanelBuilder { a | id : Used } slotCaps msg kind
tabPanelWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
tabPanelWithSlot : String -> TabPanelBuilder { a | slot : Available } slotCaps msg kind -> TabPanelBuilder { a | slot : Used } slotCaps msg kind
tabPanelWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
tabPanelWithStyle : String -> String -> TabPanelBuilder { a | style : Available } slotCaps msg kind -> TabPanelBuilder { a | style : Used } slotCaps msg kind
tabPanelWithStyle property value_ =
    B.withAttribute (A.style property value_)

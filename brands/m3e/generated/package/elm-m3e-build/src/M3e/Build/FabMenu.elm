module M3e.Build.FabMenu exposing (FabMenuBuilder, FabMenuAttrCaps, FabMenuSlotCaps, FabMenuIs, FabMenuContent, FabMenuChildAdmittedBy, fabMenuBuild, fabMenuToElement, fabMenuWithClass, fabMenuWithId, fabMenuWithOnBeforetoggle, fabMenuWithOnToggle, fabMenuWithSlot, fabMenuWithStyle, fabMenuWithVariant, fabMenuWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithDownload, itemWithHref, itemWithId, itemWithOnClick, itemWithRel, itemWithSlot, itemWithStyle, itemWithTarget, itemIcon, itemWithIcon, itemWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithFor, triggerWithId, triggerWithSlot, triggerWithStyle)

{-| The **FabMenu** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.FabMenu`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs FabMenuBuilder, FabMenuAttrCaps, FabMenuSlotCaps, FabMenuIs, FabMenuContent, FabMenuChildAdmittedBy, fabMenuBuild, fabMenuToElement, fabMenuWithClass, fabMenuWithId, fabMenuWithOnBeforetoggle, fabMenuWithOnToggle, fabMenuWithSlot, fabMenuWithStyle, fabMenuWithVariant, fabMenuWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithDownload, itemWithHref, itemWithId, itemWithOnClick, itemWithRel, itemWithSlot, itemWithStyle, itemWithTarget, itemIcon, itemWithIcon, itemWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithFor, triggerWithId, triggerWithSlot, triggerWithStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.FabMenu as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias FabMenuIs s =
    Component.FabMenuIs s


{-| -}
type alias FabMenuBuilder attrCaps slotCaps msg kind =
    Component.FabMenuBuilder attrCaps slotCaps msg kind


{-| -}
type alias FabMenuAttrCaps =
    Component.FabMenuAttrCaps


{-| -}
type alias FabMenuSlotCaps =
    Component.FabMenuSlotCaps


{-| -}
type alias FabMenuChildAdmittedBy childAdm =
    Component.FabMenuChildAdmittedBy childAdm


{-| -}
type alias FabMenuContent =
    Component.FabMenuContent


{-| -}
fabMenuBuild : FabMenuBuilder FabMenuAttrCaps FabMenuSlotCaps msg kind
fabMenuBuild =
    B.init "m3e-fab-menu" [] []


{-| -}
fabMenuToElement : FabMenuBuilder attrCaps slotCaps msg kind -> Element (Component.FabMenuIs kind) admittedBy msg
fabMenuToElement =
    B.toElement


{-| -}
fabMenuWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> FabMenuBuilder attrCaps slotCaps msg kind
    -> FabMenuBuilder attrCaps slotCaps msg kind
fabMenuWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
fabMenuWithClass : String -> FabMenuBuilder { a | class : Available } slotCaps msg kind -> FabMenuBuilder { a | class : Used } slotCaps msg kind
fabMenuWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
fabMenuWithId : String -> FabMenuBuilder { a | id : Available } slotCaps msg kind -> FabMenuBuilder { a | id : Used } slotCaps msg kind
fabMenuWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
fabMenuWithSlot : String -> FabMenuBuilder { a | slot : Available } slotCaps msg kind -> FabMenuBuilder { a | slot : Used } slotCaps msg kind
fabMenuWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
fabMenuWithStyle : String -> String -> FabMenuBuilder { a | style : Available } slotCaps msg kind -> FabMenuBuilder { a | style : Used } slotCaps msg kind
fabMenuWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
fabMenuWithVariant : Value Component.FabMenuVariant -> FabMenuBuilder { a | variant : Available } slotCaps msg kind -> FabMenuBuilder { a | variant : Used } slotCaps msg kind
fabMenuWithVariant value_ =
    B.withAttribute (Component.fabMenuVariant value_)


{-| -}
fabMenuWithOnBeforetoggle : msg -> FabMenuBuilder { a | onBeforetoggle : Available } slotCaps msg kind -> FabMenuBuilder { a | onBeforetoggle : Used } slotCaps msg kind
fabMenuWithOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
fabMenuWithOnToggle : msg -> FabMenuBuilder { a | onToggle : Available } slotCaps msg kind -> FabMenuBuilder { a | onToggle : Used } slotCaps msg kind
fabMenuWithOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)


{-| -}
type alias ItemIs s =
    Component.ItemIs s


{-| -}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Component.ItemBuilder attrCaps slotCaps msg kind


{-| -}
type alias ItemAttrCaps =
    Component.ItemAttrCaps


{-| -}
type alias ItemSlotCaps =
    Component.ItemSlotCaps


{-| -}
type alias ItemChildAdmittedBy childAdm =
    Component.ItemChildAdmittedBy childAdm


{-| -}
type alias ItemIconSlot =
    Component.ItemIconSlot


{-| -}
itemBuild : ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild =
    B.init "m3e-fab-menu-item" [] []


{-| -}
itemToElement : ItemBuilder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
itemToElement =
    B.toElement


{-| -}
itemIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Element free freeAdmittedBy msg
itemIcon builder =
    Component.itemIcon (B.toElement builder)


{-| -}
itemWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> ItemBuilder attrCaps { s | icon : Available } msg kind
    -> ItemBuilder attrCaps { s | icon : Used } msg kind
itemWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ItemBuilder attrCaps slotCaps msg kind
    -> ItemBuilder attrCaps slotCaps msg kind
itemWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
itemWithClass : String -> ItemBuilder { a | class : Available } slotCaps msg kind -> ItemBuilder { a | class : Used } slotCaps msg kind
itemWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
itemWithId : String -> ItemBuilder { a | id : Available } slotCaps msg kind -> ItemBuilder { a | id : Used } slotCaps msg kind
itemWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
itemWithSlot : String -> ItemBuilder { a | slot : Available } slotCaps msg kind -> ItemBuilder { a | slot : Used } slotCaps msg kind
itemWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
itemWithStyle : String -> String -> ItemBuilder { a | style : Available } slotCaps msg kind -> ItemBuilder { a | style : Used } slotCaps msg kind
itemWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
itemWithDisabled : Bool -> ItemBuilder { a | disabled : Available } slotCaps msg kind -> ItemBuilder { a | disabled : Used } slotCaps msg kind
itemWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
itemWithDownload : String -> ItemBuilder { a | download : Available } slotCaps msg kind -> ItemBuilder { a | download : Used } slotCaps msg kind
itemWithDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
itemWithHref : String -> ItemBuilder { a | href : Available } slotCaps msg kind -> ItemBuilder { a | href : Used } slotCaps msg kind
itemWithHref value_ =
    B.withAttribute (A.href value_)


{-| -}
itemWithRel : String -> ItemBuilder { a | rel : Available } slotCaps msg kind -> ItemBuilder { a | rel : Used } slotCaps msg kind
itemWithRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
itemWithTarget : String -> ItemBuilder { a | target : Available } slotCaps msg kind -> ItemBuilder { a | target : Used } slotCaps msg kind
itemWithTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
itemWithOnClick : msg -> ItemBuilder { a | onClick : Available } slotCaps msg kind -> ItemBuilder { a | onClick : Used } slotCaps msg kind
itemWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias TriggerIs s =
    Component.TriggerIs s


{-| -}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Component.TriggerBuilder attrCaps slotCaps msg kind


{-| -}
type alias TriggerAttrCaps =
    Component.TriggerAttrCaps


{-| -}
type alias TriggerSlotCaps =
    Component.TriggerSlotCaps


{-| -}
type alias TriggerChildAdmittedBy childAdm =
    Component.TriggerChildAdmittedBy childAdm


{-| -}
triggerBuild : TriggerBuilder TriggerAttrCaps TriggerSlotCaps msg kind
triggerBuild =
    B.init "m3e-fab-menu-trigger" [] []


{-| -}
triggerToElement : TriggerBuilder attrCaps slotCaps msg kind -> Element (Component.TriggerIs kind) admittedBy msg
triggerToElement =
    B.toElement


{-| -}
triggerWithClass : String -> TriggerBuilder { a | class : Available } slotCaps msg kind -> TriggerBuilder { a | class : Used } slotCaps msg kind
triggerWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
triggerWithId : String -> TriggerBuilder { a | id : Available } slotCaps msg kind -> TriggerBuilder { a | id : Used } slotCaps msg kind
triggerWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
triggerWithSlot : String -> TriggerBuilder { a | slot : Available } slotCaps msg kind -> TriggerBuilder { a | slot : Used } slotCaps msg kind
triggerWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
triggerWithStyle : String -> String -> TriggerBuilder { a | style : Available } slotCaps msg kind -> TriggerBuilder { a | style : Used } slotCaps msg kind
triggerWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
triggerWithFor : String -> TriggerBuilder { a | for : Available } slotCaps msg kind -> TriggerBuilder { a | for : Used } slotCaps msg kind
triggerWithFor value_ =
    B.withAttribute (A.for value_)

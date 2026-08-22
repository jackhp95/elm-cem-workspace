module M3e.Build.NavMenu exposing (NavMenuBuilder, NavMenuAttrCaps, NavMenuSlotCaps, NavMenuIs, NavMenuContent, NavMenuChildAdmittedBy, navMenuBuild, navMenuToElement, navMenuWithClass, navMenuWithId, navMenuWithSlot, navMenuWithStyle, navMenuWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemBadgeSlot, ItemIconSlot, ItemLabelSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithId, itemWithOnClick, itemWithOnClosed, itemWithOnClosing, itemWithOnOpened, itemWithOnOpening, itemWithOpen, itemWithSelected, itemWithSlot, itemWithStyle, itemBadge, itemIcon, itemLabel, itemSelectedIcon, itemToggleIcon, itemWithBadge, itemWithIcon, itemWithLabel, itemWithSelectedIcon, itemWithToggleIcon, itemWithChild, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupIs, ItemGroupContent, ItemGroupLabelSlot, ItemGroupChildAdmittedBy, itemGroupBuild, itemGroupToElement, itemGroupWithClass, itemGroupWithId, itemGroupWithSlot, itemGroupWithStyle, itemGroupLabel, itemGroupWithLabel, itemGroupWithChild)

{-| The **NavMenu** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.NavMenu`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs NavMenuBuilder, NavMenuAttrCaps, NavMenuSlotCaps, NavMenuIs, NavMenuContent, NavMenuChildAdmittedBy, navMenuBuild, navMenuToElement, navMenuWithClass, navMenuWithId, navMenuWithSlot, navMenuWithStyle, navMenuWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemBadgeSlot, ItemIconSlot, ItemLabelSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithId, itemWithOnClick, itemWithOnClosed, itemWithOnClosing, itemWithOnOpened, itemWithOnOpening, itemWithOpen, itemWithSelected, itemWithSlot, itemWithStyle, itemBadge, itemIcon, itemLabel, itemSelectedIcon, itemToggleIcon, itemWithBadge, itemWithIcon, itemWithLabel, itemWithSelectedIcon, itemWithToggleIcon, itemWithChild, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupIs, ItemGroupContent, ItemGroupLabelSlot, ItemGroupChildAdmittedBy, itemGroupBuild, itemGroupToElement, itemGroupWithClass, itemGroupWithId, itemGroupWithSlot, itemGroupWithStyle, itemGroupLabel, itemGroupWithLabel, itemGroupWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.NavMenu as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias NavMenuIs s =
    Component.NavMenuIs s


{-| -}
type alias NavMenuBuilder attrCaps slotCaps msg kind =
    Component.NavMenuBuilder attrCaps slotCaps msg kind


{-| -}
type alias NavMenuAttrCaps =
    Component.NavMenuAttrCaps


{-| -}
type alias NavMenuSlotCaps =
    Component.NavMenuSlotCaps


{-| -}
type alias NavMenuChildAdmittedBy childAdm =
    Component.NavMenuChildAdmittedBy childAdm


{-| -}
type alias NavMenuContent =
    Component.NavMenuContent


{-| -}
navMenuBuild : NavMenuBuilder NavMenuAttrCaps NavMenuSlotCaps msg kind
navMenuBuild =
    B.init "m3e-nav-menu" [] []


{-| -}
navMenuToElement : NavMenuBuilder attrCaps slotCaps msg kind -> Element (Component.NavMenuIs kind) admittedBy msg
navMenuToElement =
    B.toElement


{-| -}
navMenuWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> NavMenuBuilder attrCaps slotCaps msg kind
    -> NavMenuBuilder attrCaps slotCaps msg kind
navMenuWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
navMenuWithClass : String -> NavMenuBuilder { a | class : Available } slotCaps msg kind -> NavMenuBuilder { a | class : Used } slotCaps msg kind
navMenuWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
navMenuWithId : String -> NavMenuBuilder { a | id : Available } slotCaps msg kind -> NavMenuBuilder { a | id : Used } slotCaps msg kind
navMenuWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
navMenuWithSlot : String -> NavMenuBuilder { a | slot : Available } slotCaps msg kind -> NavMenuBuilder { a | slot : Used } slotCaps msg kind
navMenuWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
navMenuWithStyle : String -> String -> NavMenuBuilder { a | style : Available } slotCaps msg kind -> NavMenuBuilder { a | style : Used } slotCaps msg kind
navMenuWithStyle property value_ =
    B.withAttribute (A.style property value_)


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
type alias ItemContent =
    Component.ItemContent


{-| -}
type alias ItemBadgeSlot =
    Component.ItemBadgeSlot


{-| -}
type alias ItemIconSlot =
    Component.ItemIconSlot


{-| -}
type alias ItemLabelSlot =
    Component.ItemLabelSlot


{-| -}
type alias ItemSelectedIconSlot =
    Component.ItemSelectedIconSlot


{-| -}
type alias ItemToggleIconSlot =
    Component.ItemToggleIconSlot


{-| -}
itemBuild :
    { label : Element Component.ItemLabelSlot (Component.ItemChildAdmittedBy childAdm) msg }
    -> ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild required_ =
    B.init "m3e-nav-menu-item" [] [ El.toNode (Component.itemLabel required_.label) ]


{-| -}
itemToElement : ItemBuilder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
itemToElement =
    B.toElement


{-| -}
itemBadge :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemBadgeSlot msg
    -> Element free freeAdmittedBy msg
itemBadge builder =
    Component.itemBadge (B.toElement builder)


{-| -}
itemIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Element free freeAdmittedBy msg
itemIcon builder =
    Component.itemIcon (B.toElement builder)


{-| -}
itemLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLabelSlot msg
    -> Element free freeAdmittedBy msg
itemLabel builder =
    Component.itemLabel (B.toElement builder)


{-| -}
itemSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSelectedIconSlot msg
    -> Element free freeAdmittedBy msg
itemSelectedIcon builder =
    Component.itemSelectedIcon (B.toElement builder)


{-| -}
itemToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemToggleIconSlot msg
    -> Element free freeAdmittedBy msg
itemToggleIcon builder =
    Component.itemToggleIcon (B.toElement builder)


{-| -}
itemWithBadge :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemBadgeSlot msg
    -> ItemBuilder attrCaps { s | badge : Available } msg kind
    -> ItemBuilder attrCaps { s | badge : Used } msg kind
itemWithBadge slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemBadge (B.toElement slotBuilder))) builder_


{-| -}
itemWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> ItemBuilder attrCaps { s | icon : Available } msg kind
    -> ItemBuilder attrCaps { s | icon : Used } msg kind
itemWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLabelSlot msg
    -> ItemBuilder attrCaps { s | label : Available } msg kind
    -> ItemBuilder attrCaps { s | label : Used } msg kind
itemWithLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemLabel (B.toElement slotBuilder))) builder_


{-| -}
itemWithSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSelectedIconSlot msg
    -> ItemBuilder attrCaps { s | selectedIcon : Available } msg kind
    -> ItemBuilder attrCaps { s | selectedIcon : Used } msg kind
itemWithSelectedIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemSelectedIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemToggleIconSlot msg
    -> ItemBuilder attrCaps { s | toggleIcon : Available } msg kind
    -> ItemBuilder attrCaps { s | toggleIcon : Used } msg kind
itemWithToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemToggleIcon (B.toElement slotBuilder))) builder_


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
itemWithOpen : Bool -> ItemBuilder { a | open : Available } slotCaps msg kind -> ItemBuilder { a | open : Used } slotCaps msg kind
itemWithOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
itemWithSelected : Bool -> ItemBuilder { a | selected : Available } slotCaps msg kind -> ItemBuilder { a | selected : Used } slotCaps msg kind
itemWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
itemWithOnOpening : msg -> ItemBuilder { a | onOpening : Available } slotCaps msg kind -> ItemBuilder { a | onOpening : Used } slotCaps msg kind
itemWithOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
itemWithOnOpened : msg -> ItemBuilder { a | onOpened : Available } slotCaps msg kind -> ItemBuilder { a | onOpened : Used } slotCaps msg kind
itemWithOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
itemWithOnClosing : msg -> ItemBuilder { a | onClosing : Available } slotCaps msg kind -> ItemBuilder { a | onClosing : Used } slotCaps msg kind
itemWithOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
itemWithOnClosed : msg -> ItemBuilder { a | onClosed : Available } slotCaps msg kind -> ItemBuilder { a | onClosed : Used } slotCaps msg kind
itemWithOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)


{-| -}
itemWithOnClick : msg -> ItemBuilder { a | onClick : Available } slotCaps msg kind -> ItemBuilder { a | onClick : Used } slotCaps msg kind
itemWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias ItemGroupIs s =
    Component.ItemGroupIs s


{-| -}
type alias ItemGroupBuilder attrCaps slotCaps msg kind =
    Component.ItemGroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias ItemGroupAttrCaps =
    Component.ItemGroupAttrCaps


{-| -}
type alias ItemGroupSlotCaps =
    Component.ItemGroupSlotCaps


{-| -}
type alias ItemGroupChildAdmittedBy childAdm =
    Component.ItemGroupChildAdmittedBy childAdm


{-| -}
type alias ItemGroupContent =
    Component.ItemGroupContent


{-| -}
type alias ItemGroupLabelSlot =
    Component.ItemGroupLabelSlot


{-| -}
itemGroupBuild : ItemGroupBuilder ItemGroupAttrCaps ItemGroupSlotCaps msg kind
itemGroupBuild =
    B.init "m3e-nav-menu-item-group" [] []


{-| -}
itemGroupToElement : ItemGroupBuilder attrCaps slotCaps msg kind -> Element (Component.ItemGroupIs kind) admittedBy msg
itemGroupToElement =
    B.toElement


{-| -}
itemGroupLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemGroupLabelSlot msg
    -> Element free freeAdmittedBy msg
itemGroupLabel builder =
    Component.itemGroupLabel (B.toElement builder)


{-| -}
itemGroupWithLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemGroupLabelSlot msg
    -> ItemGroupBuilder attrCaps { s | label : Available } msg kind
    -> ItemGroupBuilder attrCaps { s | label : Used } msg kind
itemGroupWithLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemGroupLabel (B.toElement slotBuilder))) builder_


{-| -}
itemGroupWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ItemGroupBuilder attrCaps slotCaps msg kind
    -> ItemGroupBuilder attrCaps slotCaps msg kind
itemGroupWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
itemGroupWithClass : String -> ItemGroupBuilder { a | class : Available } slotCaps msg kind -> ItemGroupBuilder { a | class : Used } slotCaps msg kind
itemGroupWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
itemGroupWithId : String -> ItemGroupBuilder { a | id : Available } slotCaps msg kind -> ItemGroupBuilder { a | id : Used } slotCaps msg kind
itemGroupWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
itemGroupWithSlot : String -> ItemGroupBuilder { a | slot : Available } slotCaps msg kind -> ItemGroupBuilder { a | slot : Used } slotCaps msg kind
itemGroupWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
itemGroupWithStyle : String -> String -> ItemGroupBuilder { a | style : Available } slotCaps msg kind -> ItemGroupBuilder { a | style : Used } slotCaps msg kind
itemGroupWithStyle property value_ =
    B.withAttribute (A.style property value_)

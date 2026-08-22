module M3e.Build.NavMenuItem exposing (Builder, AttrCaps, SlotCaps, Is, Content, BadgeSlot, IconSlot, LabelSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnClick, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSelected, withSlot, withStyle, badge, icon, label, selectedIcon, toggleIcon, withBadge, withIcon, withLabel, withSelectedIcon, withToggleIcon, withChild)

{-| The **NavMenuItem** element — the flat per-element builder surface,
sourced through the **NavMenu** family façade
(`M3e.Component.NavMenu`). This module and the aggregated
`M3e.Build.NavMenu` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, BadgeSlot, IconSlot, LabelSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnClick, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSelected, withSlot, withStyle, badge, icon, label, selectedIcon, toggleIcon, withBadge, withIcon, withLabel, withSelectedIcon, withToggleIcon, withChild

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
type alias Is s =
    Component.ItemIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ItemBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ItemAttrCaps


{-| -}
type alias SlotCaps =
    Component.ItemSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ItemChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ItemContent


{-| -}
type alias BadgeSlot =
    Component.ItemBadgeSlot


{-| -}
type alias IconSlot =
    Component.ItemIconSlot


{-| -}
type alias LabelSlot =
    Component.ItemLabelSlot


{-| -}
type alias SelectedIconSlot =
    Component.ItemSelectedIconSlot


{-| -}
type alias ToggleIconSlot =
    Component.ItemToggleIconSlot


{-| -}
build :
    { label : Element Component.ItemLabelSlot (Component.ItemChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-nav-menu-item" [] [ El.toNode (Component.itemLabel required_.label) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
badge :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemBadgeSlot msg
    -> Element free freeAdmittedBy msg
badge builder =
    Component.itemBadge (B.toElement builder)


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.itemIcon (B.toElement builder)


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.itemLabel (B.toElement builder)


{-| -}
selectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSelectedIconSlot msg
    -> Element free freeAdmittedBy msg
selectedIcon builder =
    Component.itemSelectedIcon (B.toElement builder)


{-| -}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.itemToggleIcon (B.toElement builder)


{-| -}
withBadge :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemBadgeSlot msg
    -> Builder attrCaps { s | badge : Available } msg kind
    -> Builder attrCaps { s | badge : Used } msg kind
withBadge slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemBadge (B.toElement slotBuilder))) builder_


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


{-| -}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemLabel (B.toElement slotBuilder))) builder_


{-| -}
withSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSelectedIconSlot msg
    -> Builder attrCaps { s | selectedIcon : Available } msg kind
    -> Builder attrCaps { s | selectedIcon : Used } msg kind
withSelectedIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemSelectedIcon (B.toElement slotBuilder))) builder_


{-| -}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemToggleIcon (B.toElement slotBuilder))) builder_


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
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


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


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)

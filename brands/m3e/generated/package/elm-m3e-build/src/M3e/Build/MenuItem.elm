module M3e.Build.MenuItem exposing (Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, icon, trailingIcon, withIcon, withTrailingIcon, withChild)

{-| The **MenuItem** element — the flat per-element builder surface,
sourced through the **Menu** family façade
(`M3e.Component.Menu`). This module and the aggregated
`M3e.Build.Menu` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, icon, trailingIcon, withIcon, withTrailingIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Menu as Component
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
type alias IconSlot =
    Component.ItemIconSlot


{-| -}
type alias TrailingIconSlot =
    Component.ItemTrailingIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-menu-item" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.itemIcon (B.toElement builder)


{-| -}
trailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
trailingIcon builder =
    Component.itemTrailingIcon (B.toElement builder)


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


{-| -}
withTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingIconSlot msg
    -> Builder attrCaps { s | trailingIcon : Available } msg kind
    -> Builder attrCaps { s | trailingIcon : Used } msg kind
withTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemTrailingIcon (B.toElement slotBuilder))) builder_


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
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)

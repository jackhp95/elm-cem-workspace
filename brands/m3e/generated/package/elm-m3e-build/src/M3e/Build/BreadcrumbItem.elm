module M3e.Build.BreadcrumbItem exposing (Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy, build, toElement, withClass, withCurrent, withDisabled, withDownload, withHref, withId, withItemLabel, withOnClick, withRel, withSlot, withStyle, withTarget, icon, withIcon, withChild)

{-| The **BreadcrumbItem** element — the flat per-element builder surface,
sourced through the **Breadcrumb** family façade
(`M3e.Component.Breadcrumb`). This module and the aggregated
`M3e.Build.Breadcrumb` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy, build, toElement, withClass, withCurrent, withDisabled, withDownload, withHref, withId, withItemLabel, withOnClick, withRel, withSlot, withStyle, withTarget, icon, withIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Breadcrumb as Component
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
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-breadcrumb-item" [] []


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
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


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
withCurrent : Value Component.ItemCurrent -> Builder { a | current : Available } slotCaps msg kind -> Builder { a | current : Used } slotCaps msg kind
withCurrent value_ =
    B.withAttribute (Component.itemCurrent value_)


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
withItemLabel : String -> Builder { a | itemLabel : Available } slotCaps msg kind -> Builder { a | itemLabel : Used } slotCaps msg kind
withItemLabel value_ =
    B.withAttribute (A.itemLabel value_)


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

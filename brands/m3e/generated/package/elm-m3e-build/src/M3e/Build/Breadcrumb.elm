module M3e.Build.Breadcrumb exposing (BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbIs, BreadcrumbContent, BreadcrumbChildAdmittedBy, breadcrumbBuild, breadcrumbToElement, breadcrumbWithClass, breadcrumbWithId, breadcrumbWithSlot, breadcrumbWithStyle, breadcrumbWithWrap, breadcrumbSeparator, breadcrumbWithSeparator, breadcrumbWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithCurrent, itemWithDisabled, itemWithDownload, itemWithHref, itemWithId, itemWithItemLabel, itemWithOnClick, itemWithRel, itemWithSlot, itemWithStyle, itemWithTarget, itemIcon, itemWithIcon, itemWithChild)

{-| The **Breadcrumb** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Breadcrumb`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs BreadcrumbBuilder, BreadcrumbAttrCaps, BreadcrumbSlotCaps, BreadcrumbIs, BreadcrumbContent, BreadcrumbChildAdmittedBy, breadcrumbBuild, breadcrumbToElement, breadcrumbWithClass, breadcrumbWithId, breadcrumbWithSlot, breadcrumbWithStyle, breadcrumbWithWrap, breadcrumbSeparator, breadcrumbWithSeparator, breadcrumbWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithCurrent, itemWithDisabled, itemWithDownload, itemWithHref, itemWithId, itemWithItemLabel, itemWithOnClick, itemWithRel, itemWithSlot, itemWithStyle, itemWithTarget, itemIcon, itemWithIcon, itemWithChild

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
type alias BreadcrumbIs s =
    Component.BreadcrumbIs s


{-| -}
type alias BreadcrumbBuilder attrCaps slotCaps msg kind =
    Component.BreadcrumbBuilder attrCaps slotCaps msg kind


{-| -}
type alias BreadcrumbAttrCaps =
    Component.BreadcrumbAttrCaps


{-| -}
type alias BreadcrumbSlotCaps =
    Component.BreadcrumbSlotCaps


{-| -}
type alias BreadcrumbChildAdmittedBy childAdm =
    Component.BreadcrumbChildAdmittedBy childAdm


{-| -}
type alias BreadcrumbContent =
    Component.BreadcrumbContent


{-| -}
breadcrumbBuild :
    { content : Element Component.BreadcrumbContent (Component.BreadcrumbChildAdmittedBy childAdm) msg }
    -> BreadcrumbBuilder BreadcrumbAttrCaps BreadcrumbSlotCaps msg kind
breadcrumbBuild required_ =
    B.init "m3e-breadcrumb" [] [ El.toNode required_.content ]


{-| -}
breadcrumbToElement : BreadcrumbBuilder attrCaps slotCaps msg kind -> Element (Component.BreadcrumbIs kind) admittedBy msg
breadcrumbToElement =
    B.toElement


{-| -}
breadcrumbSeparator :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
breadcrumbSeparator builder =
    Component.breadcrumbSeparator (B.toElement builder)


{-| -}
breadcrumbWithSeparator :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> BreadcrumbBuilder attrCaps { s | separator : Available } msg kind
    -> BreadcrumbBuilder attrCaps { s | separator : Used } msg kind
breadcrumbWithSeparator slotBuilder builder_ =
    B.withChild (El.toNode (Component.breadcrumbSeparator (B.toElement slotBuilder))) builder_


{-| -}
breadcrumbWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> BreadcrumbBuilder attrCaps slotCaps msg kind
    -> BreadcrumbBuilder attrCaps slotCaps msg kind
breadcrumbWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
breadcrumbWithClass : String -> BreadcrumbBuilder { a | class : Available } slotCaps msg kind -> BreadcrumbBuilder { a | class : Used } slotCaps msg kind
breadcrumbWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
breadcrumbWithId : String -> BreadcrumbBuilder { a | id : Available } slotCaps msg kind -> BreadcrumbBuilder { a | id : Used } slotCaps msg kind
breadcrumbWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
breadcrumbWithSlot : String -> BreadcrumbBuilder { a | slot : Available } slotCaps msg kind -> BreadcrumbBuilder { a | slot : Used } slotCaps msg kind
breadcrumbWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
breadcrumbWithStyle : String -> String -> BreadcrumbBuilder { a | style : Available } slotCaps msg kind -> BreadcrumbBuilder { a | style : Used } slotCaps msg kind
breadcrumbWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
breadcrumbWithWrap : Bool -> BreadcrumbBuilder { a | wrap : Available } slotCaps msg kind -> BreadcrumbBuilder { a | wrap : Used } slotCaps msg kind
breadcrumbWithWrap value_ =
    B.withAttribute (A.wrap value_)


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
type alias ItemIconSlot =
    Component.ItemIconSlot


{-| -}
itemBuild : ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild =
    B.init "m3e-breadcrumb-item" [] []


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
itemWithCurrent : Value Component.ItemCurrent -> ItemBuilder { a | current : Available } slotCaps msg kind -> ItemBuilder { a | current : Used } slotCaps msg kind
itemWithCurrent value_ =
    B.withAttribute (Component.itemCurrent value_)


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
itemWithItemLabel : String -> ItemBuilder { a | itemLabel : Available } slotCaps msg kind -> ItemBuilder { a | itemLabel : Used } slotCaps msg kind
itemWithItemLabel value_ =
    B.withAttribute (A.itemLabel value_)


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

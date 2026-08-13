module M3e.Build.BreadcrumbItem exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy
    , withClass, withCurrent, withDisabled, withDownload, withHref, withId, withItemLabel, withOnClick, withRel, withSlot, withStyle, withTarget
    , icon
    , withIcon, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, IconSlot, ChildAdmittedBy
@docs withClass, withCurrent, withDisabled, withDownload, withHref, withId, withItemLabel, withOnClick, withRel, withSlot, withStyle, withTarget
@docs icon
@docs withIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.BreadcrumbItem as Component
import M3e.Events as Ev
import M3e.Internal.Types.BreadcrumbItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.BreadcrumbItem.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.BreadcrumbItem.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.BreadcrumbItem.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.BreadcrumbItem.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BreadcrumbItem.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    M3e.Internal.Types.BreadcrumbItem.Content


{-| -}
type alias IconSlot =
    M3e.Internal.Types.BreadcrumbItem.IconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-breadcrumb-item" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.icon (B.toElement builder)


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.icon (B.toElement slotBuilder))) builder_


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
withCurrent : Value Component.Current -> Builder { a | current : Available } slotCaps msg kind -> Builder { a | current : Used } slotCaps msg kind
withCurrent value_ =
    B.withAttribute (Component.current value_)


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

module M3e.Build.NavMenuItemGroup exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, LabelSlot, ChildAdmittedBy
    , withClass, withId, withSlot, withStyle
    , label
    , withLabel, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, LabelSlot, ChildAdmittedBy
@docs withClass, withId, withSlot, withStyle
@docs label
@docs withLabel, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.NavMenuItemGroup as Component
import M3e.Internal.Types.NavMenuItemGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.NavMenuItemGroup.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.NavMenuItemGroup.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.NavMenuItemGroup.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.NavMenuItemGroup.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavMenuItemGroup.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    M3e.Internal.Types.NavMenuItemGroup.Content


{-| -}
type alias LabelSlot =
    M3e.Internal.Types.NavMenuItemGroup.LabelSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-nav-menu-item-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.LabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.label (B.toElement builder)


{-| -}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.LabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.label (B.toElement slotBuilder))) builder_


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

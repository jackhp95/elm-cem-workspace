module Sl.Build.MenuItem exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, SubmenuSlot, ChildAdmittedBy
    , withChecked, withClass, withDisabled, withId, withLoading, withSlot, withStyle, withType, withValue
    , submenu
    , withSubmenu, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, SubmenuSlot, ChildAdmittedBy
@docs withChecked, withClass, withDisabled, withId, withLoading, withSlot, withStyle, withType, withValue
@docs submenu
@docs withSubmenu, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Element.MenuItem as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias SubmenuSlot =
    Component.SubmenuSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-menu-item" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
submenu :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubmenuSlot msg
    -> Element free freeAdmittedBy msg
submenu builder =
    Component.submenu (B.toElement builder)


{-| -}
withSubmenu :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubmenuSlot msg
    -> Builder attrCaps { s | submenu : Available } msg kind
    -> Builder attrCaps { s | submenu : Used } msg kind
withSubmenu slotBuilder builder_ =
    B.withChild (El.toNode (Component.submenu (B.toElement slotBuilder))) builder_


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
withChecked : Bool -> Builder { a | checked : Available } slotCaps msg kind -> Builder { a | checked : Used } slotCaps msg kind
withChecked value_ =
    B.withAttribute (A.checked value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withLoading : Bool -> Builder { a | loading : Available } slotCaps msg kind -> Builder { a | loading : Used } slotCaps msg kind
withLoading value_ =
    B.withAttribute
        (if value_ then
            Ir.attribute "loading" ""

         else
            Ir.none
        )


{-| -}
withType : Value Component.Type -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.type_ value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)

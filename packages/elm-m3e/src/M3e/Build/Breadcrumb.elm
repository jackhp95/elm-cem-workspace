module M3e.Build.Breadcrumb exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withClass, withId, withSlot, withStyle, withWrap
    , separator
    , withSeparator, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withClass, withId, withSlot, withStyle, withWrap
@docs separator
@docs withSeparator, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Breadcrumb as Component
import M3e.Internal.Types.Breadcrumb
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.Breadcrumb.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Breadcrumb.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Breadcrumb.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.Breadcrumb.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Breadcrumb.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    M3e.Internal.Types.Breadcrumb.Content


{-| -}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-breadcrumb" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
separator :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
separator builder =
    Component.separator (B.toElement builder)


{-| -}
withSeparator :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | separator : Available } msg kind
    -> Builder attrCaps { s | separator : Used } msg kind
withSeparator slotBuilder builder_ =
    B.withChild (El.toNode (Component.separator (B.toElement slotBuilder))) builder_


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
withWrap : Bool -> Builder { a | wrap : Available } slotCaps msg kind -> Builder { a | wrap : Used } slotCaps msg kind
withWrap value_ =
    B.withAttribute (A.wrap value_)

module M3e.Build.Toolbar exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withElevated, withId, withShape, withSlot, withStyle, withVariant, withVertical
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withElevated, withId, withShape, withSlot, withStyle, withVariant, withVertical
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Toolbar as Component
import M3e.Internal.Types.Toolbar
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.Toolbar.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Toolbar.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Toolbar.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Toolbar.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-toolbar" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


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
withElevated : Bool -> Builder { a | elevated : Available } slotCaps msg kind -> Builder { a | elevated : Used } slotCaps msg kind
withElevated value_ =
    B.withAttribute (A.elevated value_)


{-| -}
withShape : Value Component.Shape -> Builder { a | shape : Available } slotCaps msg kind -> Builder { a | shape : Used } slotCaps msg kind
withShape value_ =
    B.withAttribute (Component.shape value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| -}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)

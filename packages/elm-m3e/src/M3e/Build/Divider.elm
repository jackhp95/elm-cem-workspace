module M3e.Build.Divider exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withId, withInset, withInsetEnd, withInsetStart, withSlot, withStyle, withVertical
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withId, withInset, withInsetEnd, withInsetStart, withSlot, withStyle, withVertical

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Divider as Component
import M3e.Internal.Types.Divider
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.Divider.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Divider.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Divider.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Divider.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-divider" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


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
withInset : Bool -> Builder { a | inset : Available } slotCaps msg kind -> Builder { a | inset : Used } slotCaps msg kind
withInset value_ =
    B.withAttribute (A.inset value_)


{-| -}
withInsetEnd : Bool -> Builder { a | insetEnd : Available } slotCaps msg kind -> Builder { a | insetEnd : Used } slotCaps msg kind
withInsetEnd value_ =
    B.withAttribute (A.insetEnd value_)


{-| -}
withInsetStart : Bool -> Builder { a | insetStart : Available } slotCaps msg kind -> Builder { a | insetStart : Used } slotCaps msg kind
withInsetStart value_ =
    B.withAttribute (A.insetStart value_)


{-| -}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)

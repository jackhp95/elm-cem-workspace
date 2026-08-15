module M3e.Build.BottomSheet exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDetent, withDetents, withHandle, withHandleLabel, withHideFriction, withHideable, withId, withModal, withOnCancel, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withOvershootLimit, withSlot, withStyle
    , header
    , withHeader, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDetent, withDetents, withHandle, withHandleLabel, withHideFriction, withHideable, withId, withModal, withOnCancel, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withOvershootLimit, withSlot, withStyle
@docs header
@docs withHeader, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Component.BottomSheet as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


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
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-bottom-sheet" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
header :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.header (B.toElement builder)


{-| -}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | header : Available } msg kind
    -> Builder attrCaps { s | header : Used } msg kind
withHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.header (B.toElement slotBuilder))) builder_


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
withDetent : Float -> Builder { a | detent : Available } slotCaps msg kind -> Builder { a | detent : Used } slotCaps msg kind
withDetent value_ =
    B.withAttribute (A.detent value_)


{-| -}
withDetents : String -> Builder { a | detents : Available } slotCaps msg kind -> Builder { a | detents : Used } slotCaps msg kind
withDetents value_ =
    B.withAttribute (A.detents value_)


{-| -}
withHandle : Bool -> Builder { a | handle : Available } slotCaps msg kind -> Builder { a | handle : Used } slotCaps msg kind
withHandle value_ =
    B.withAttribute (A.handle value_)


{-| -}
withHandleLabel : String -> Builder { a | handleLabel : Available } slotCaps msg kind -> Builder { a | handleLabel : Used } slotCaps msg kind
withHandleLabel value_ =
    B.withAttribute (A.handleLabel value_)


{-| -}
withHideFriction : Float -> Builder { a | hideFriction : Available } slotCaps msg kind -> Builder { a | hideFriction : Used } slotCaps msg kind
withHideFriction value_ =
    B.withAttribute (A.hideFriction value_)


{-| -}
withHideable : Bool -> Builder { a | hideable : Available } slotCaps msg kind -> Builder { a | hideable : Used } slotCaps msg kind
withHideable value_ =
    B.withAttribute (A.hideable value_)


{-| -}
withModal : Bool -> Builder { a | modal : Available } slotCaps msg kind -> Builder { a | modal : Used } slotCaps msg kind
withModal value_ =
    B.withAttribute (A.modal value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withOvershootLimit : Float -> Builder { a | overshootLimit : Available } slotCaps msg kind -> Builder { a | overshootLimit : Used } slotCaps msg kind
withOvershootLimit value_ =
    B.withAttribute (A.overshootLimit value_)


{-| -}
withOnOpening : msg -> Builder { a | onOpening : Available } slotCaps msg kind -> Builder { a | onOpening : Used } slotCaps msg kind
withOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
withOnClosing : msg -> Builder { a | onClosing : Available } slotCaps msg kind -> Builder { a | onClosing : Used } slotCaps msg kind
withOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
withOnCancel : msg -> Builder { a | onCancel : Available } slotCaps msg kind -> Builder { a | onCancel : Used } slotCaps msg kind
withOnCancel value_ =
    B.withAttribute (Ev.onCancel value_)


{-| -}
withOnOpened : msg -> Builder { a | onOpened : Available } slotCaps msg kind -> Builder { a | onOpened : Used } slotCaps msg kind
withOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
withOnClosed : msg -> Builder { a | onClosed : Available } slotCaps msg kind -> Builder { a | onClosed : Used } slotCaps msg kind
withOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)

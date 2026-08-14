module M3e.Build.Dialog exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, CloseIconSlot, HeaderSlot, ChildAdmittedBy
    , withAlert, withClass, withCloseLabel, withDisableClose, withDismissible, withId, withNoFocusTrap, withOnCancel, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle
    , actions, closeIcon, header
    , withActions, withCloseIcon, withHeader, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, CloseIconSlot, HeaderSlot, ChildAdmittedBy
@docs withAlert, withClass, withCloseLabel, withDisableClose, withDismissible, withId, withNoFocusTrap, withOnCancel, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle
@docs actions, closeIcon, header
@docs withActions, withCloseIcon, withHeader, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Component.Dialog as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Internal.Types.Dialog
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.Dialog.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Dialog.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Dialog.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.Dialog.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Dialog.ChildAdmittedBy childAdm


{-| -}
type alias CloseIconSlot =
    M3e.Internal.Types.Dialog.CloseIconSlot


{-| -}
type alias HeaderSlot =
    M3e.Internal.Types.Dialog.HeaderSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-dialog" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.actions (B.toElement builder)


{-| -}
closeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.CloseIconSlot msg
    -> Element free freeAdmittedBy msg
closeIcon builder =
    Component.closeIcon (B.toElement builder)


{-| -}
header :
    B.Builder childRow childAttrCaps childSlotCaps Component.HeaderSlot msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.header (B.toElement builder)


{-| -}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | actions : Available } msg kind
    -> Builder attrCaps { s | actions : Used } msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.actions (B.toElement slotBuilder))) builder_


{-| -}
withCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.CloseIconSlot msg
    -> Builder attrCaps { s | closeIcon : Available } msg kind
    -> Builder attrCaps { s | closeIcon : Used } msg kind
withCloseIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.closeIcon (B.toElement slotBuilder))) builder_


{-| -}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps Component.HeaderSlot msg
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
withAlert : Bool -> Builder { a | alert : Available } slotCaps msg kind -> Builder { a | alert : Used } slotCaps msg kind
withAlert value_ =
    B.withAttribute (A.alert value_)


{-| -}
withCloseLabel : String -> Builder { a | closeLabel : Available } slotCaps msg kind -> Builder { a | closeLabel : Used } slotCaps msg kind
withCloseLabel value_ =
    B.withAttribute (A.closeLabel value_)


{-| -}
withDisableClose : Bool -> Builder { a | disableClose : Available } slotCaps msg kind -> Builder { a | disableClose : Used } slotCaps msg kind
withDisableClose value_ =
    B.withAttribute (A.disableClose value_)


{-| -}
withDismissible : Bool -> Builder { a | dismissible : Available } slotCaps msg kind -> Builder { a | dismissible : Used } slotCaps msg kind
withDismissible value_ =
    B.withAttribute (A.dismissible value_)


{-| -}
withNoFocusTrap : Bool -> Builder { a | noFocusTrap : Available } slotCaps msg kind -> Builder { a | noFocusTrap : Used } slotCaps msg kind
withNoFocusTrap value_ =
    B.withAttribute (A.noFocusTrap value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withOnOpening : msg -> Builder { a | onOpening : Available } slotCaps msg kind -> Builder { a | onOpening : Used } slotCaps msg kind
withOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
withOnOpened : msg -> Builder { a | onOpened : Available } slotCaps msg kind -> Builder { a | onOpened : Used } slotCaps msg kind
withOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
withOnClosing : msg -> Builder { a | onClosing : Available } slotCaps msg kind -> Builder { a | onClosing : Used } slotCaps msg kind
withOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
withOnClosed : msg -> Builder { a | onClosed : Available } slotCaps msg kind -> Builder { a | onClosed : Used } slotCaps msg kind
withOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)


{-| -}
withOnCancel : msg -> Builder { a | onCancel : Available } slotCaps msg kind -> Builder { a | onCancel : Used } slotCaps msg kind
withOnCancel value_ =
    B.withAttribute (Ev.onCancel value_)

module M3e.Build.Snackbar exposing (Builder, AttrCaps, SlotCaps, Is, Content, CloseIconSlot, ChildAdmittedBy, build, toElement, withAction, withClass, withCloseLabel, withDismissible, withDuration, withId, withOnBeforetoggle, withOnToggle, withOpen, withSlot, withStyle, closeIcon, withCloseIcon, withChild)

{-| The **Snackbar** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Snackbar`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, CloseIconSlot, ChildAdmittedBy, build, toElement, withAction, withClass, withCloseLabel, withDismissible, withDuration, withId, withOnBeforetoggle, withOnToggle, withOpen, withSlot, withStyle, closeIcon, withCloseIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Snackbar as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SnackbarIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SnackbarBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SnackbarAttrCaps


{-| -}
type alias SlotCaps =
    Component.SnackbarSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SnackbarChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.SnackbarContent


{-| -}
type alias CloseIconSlot =
    Component.SnackbarCloseIconSlot


{-| -}
build :
    { content : Element Component.SnackbarContent (Component.SnackbarChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-snackbar" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SnackbarIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
closeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SnackbarCloseIconSlot msg
    -> Element free freeAdmittedBy msg
closeIcon builder =
    Component.snackbarCloseIcon (B.toElement builder)


{-| -}
withCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SnackbarCloseIconSlot msg
    -> Builder attrCaps { s | closeIcon : Available } msg kind
    -> Builder attrCaps { s | closeIcon : Used } msg kind
withCloseIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.snackbarCloseIcon (B.toElement slotBuilder))) builder_


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
withAction : String -> Builder { a | action : Available } slotCaps msg kind -> Builder { a | action : Used } slotCaps msg kind
withAction value_ =
    B.withAttribute (A.action value_)


{-| -}
withCloseLabel : String -> Builder { a | closeLabel : Available } slotCaps msg kind -> Builder { a | closeLabel : Used } slotCaps msg kind
withCloseLabel value_ =
    B.withAttribute (A.closeLabel value_)


{-| -}
withDismissible : Bool -> Builder { a | dismissible : Available } slotCaps msg kind -> Builder { a | dismissible : Used } slotCaps msg kind
withDismissible value_ =
    B.withAttribute (A.dismissible value_)


{-| -}
withDuration : Float -> Builder { a | duration : Available } slotCaps msg kind -> Builder { a | duration : Used } slotCaps msg kind
withDuration value_ =
    B.withAttribute (A.duration value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)

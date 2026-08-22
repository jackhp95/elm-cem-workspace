module M3e.Component.Snackbar exposing (SnackbarIs, SnackbarAttrs, SnackbarBuilder, SnackbarAttrCaps, SnackbarSlotCaps, SnackbarContent, SnackbarCloseIconSlot, SnackbarChildAdmittedBy, snackbar, snackbarAction, snackbarCloseLabel, snackbarDismissible, snackbarDuration, snackbarOpen, snackbarOnBeforetoggle, snackbarOnToggle, snackbarCloseIcon, snackbarChild)

{-| The **Snackbar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Snackbar`](M3e.Element.Snackbar) as `snackbar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SnackbarIs, SnackbarAttrs, SnackbarBuilder, SnackbarAttrCaps, SnackbarSlotCaps, SnackbarContent, SnackbarCloseIconSlot, SnackbarChildAdmittedBy, snackbar, snackbarAction, snackbarCloseLabel, snackbarDismissible, snackbarDuration, snackbarOpen, snackbarOnBeforetoggle, snackbarOnToggle, snackbarCloseIcon, snackbarChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Snackbar as Snackbar_


{-| The `snackbar` element of this family — delegates to [`M3e.Element.Snackbar.component`](M3e.Element.Snackbar#component).
-}
snackbar :
    { content : Element SnackbarContent (SnackbarChildAdmittedBy childAdm) msg }
    -> List (Attr SnackbarAttrs msg)
    -> List (Element SnackbarContent (SnackbarChildAdmittedBy childAdm) msg)
    -> Element (SnackbarIs s) admittedBy msg
snackbar =
    Snackbar_.component


{-| See [`M3e.Element.Snackbar.Is`](M3e.Element.Snackbar#Is).
-}
type alias SnackbarIs s =
    Snackbar_.Is s


{-| See [`M3e.Element.Snackbar.Attrs`](M3e.Element.Snackbar#Attrs).
-}
type alias SnackbarAttrs =
    Snackbar_.Attrs


{-| See [`M3e.Element.Snackbar.Builder`](M3e.Element.Snackbar#Builder).
-}
type alias SnackbarBuilder attrCaps slotCaps msg kind =
    Snackbar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Snackbar.AttrCaps`](M3e.Element.Snackbar#AttrCaps).
-}
type alias SnackbarAttrCaps =
    Snackbar_.AttrCaps


{-| See [`M3e.Element.Snackbar.SlotCaps`](M3e.Element.Snackbar#SlotCaps).
-}
type alias SnackbarSlotCaps =
    Snackbar_.SlotCaps


{-| See [`M3e.Element.Snackbar.Content`](M3e.Element.Snackbar#Content).
-}
type alias SnackbarContent =
    Snackbar_.Content


{-| See [`M3e.Element.Snackbar.CloseIconSlot`](M3e.Element.Snackbar#CloseIconSlot).
-}
type alias SnackbarCloseIconSlot =
    Snackbar_.CloseIconSlot


{-| See [`M3e.Element.Snackbar.ChildAdmittedBy`](M3e.Element.Snackbar#ChildAdmittedBy).
-}
type alias SnackbarChildAdmittedBy childAdm =
    Snackbar_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Snackbar.action`](M3e.Element.Snackbar#action).
-}
snackbarAction : String -> Attr { c | action : Supported } msg
snackbarAction =
    Snackbar_.action


{-| See [`M3e.Element.Snackbar.closeLabel`](M3e.Element.Snackbar#closeLabel).
-}
snackbarCloseLabel : String -> Attr { c | closeLabel : Supported } msg
snackbarCloseLabel =
    Snackbar_.closeLabel


{-| See [`M3e.Element.Snackbar.dismissible`](M3e.Element.Snackbar#dismissible).
-}
snackbarDismissible : Bool -> Attr { c | dismissible : Supported } msg
snackbarDismissible =
    Snackbar_.dismissible


{-| See [`M3e.Element.Snackbar.duration`](M3e.Element.Snackbar#duration).
-}
snackbarDuration : Float -> Attr { c | duration : Supported } msg
snackbarDuration =
    Snackbar_.duration


{-| See [`M3e.Element.Snackbar.open`](M3e.Element.Snackbar#open).
-}
snackbarOpen : Bool -> Attr { c | open : Supported } msg
snackbarOpen =
    Snackbar_.open


{-| See [`M3e.Element.Snackbar.onBeforetoggle`](M3e.Element.Snackbar#onBeforetoggle).
-}
snackbarOnBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
snackbarOnBeforetoggle =
    Snackbar_.onBeforetoggle


{-| See [`M3e.Element.Snackbar.onToggle`](M3e.Element.Snackbar#onToggle).
-}
snackbarOnToggle : msg -> Attr { c | onToggle : Supported } msg
snackbarOnToggle =
    Snackbar_.onToggle


{-| See [`M3e.Element.Snackbar.closeIcon`](M3e.Element.Snackbar#closeIcon).
-}
snackbarCloseIcon : Element SnackbarCloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
snackbarCloseIcon =
    Snackbar_.closeIcon


{-| See [`M3e.Element.Snackbar.child`](M3e.Element.Snackbar#child).
-}
snackbarChild : Element SnackbarContent admittedBy msg -> Element free freeAdmittedBy msg
snackbarChild =
    Snackbar_.child

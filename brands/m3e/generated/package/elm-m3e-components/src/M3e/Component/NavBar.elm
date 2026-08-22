module M3e.Component.NavBar exposing (NavBarIs, NavBarAttrs, NavBarBuilder, NavBarAttrCaps, NavBarSlotCaps, NavBarContent, NavBarChildAdmittedBy, NavBarMode, navBar, navBarMode, navBarOnChange, navBarOnBeforeinput, navBarOnInput, navBarChild)

{-| The **NavBar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.NavBar`](M3e.Element.NavBar) as `navBar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs NavBarIs, NavBarAttrs, NavBarBuilder, NavBarAttrCaps, NavBarSlotCaps, NavBarContent, NavBarChildAdmittedBy, NavBarMode, navBar, navBarMode, navBarOnChange, navBarOnBeforeinput, navBarOnInput, navBarChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.NavBar as NavBar_


{-| The `navBar` element of this family — delegates to [`M3e.Element.NavBar.component`](M3e.Element.NavBar#component).
-}
navBar :
    List (Attr NavBarAttrs msg)
    -> List (Element NavBarContent (NavBarChildAdmittedBy childAdm) msg)
    -> Element (NavBarIs s) admittedBy msg
navBar =
    NavBar_.component


{-| See [`M3e.Element.NavBar.Is`](M3e.Element.NavBar#Is).
-}
type alias NavBarIs s =
    NavBar_.Is s


{-| See [`M3e.Element.NavBar.Attrs`](M3e.Element.NavBar#Attrs).
-}
type alias NavBarAttrs =
    NavBar_.Attrs


{-| See [`M3e.Element.NavBar.Builder`](M3e.Element.NavBar#Builder).
-}
type alias NavBarBuilder attrCaps slotCaps msg kind =
    NavBar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavBar.AttrCaps`](M3e.Element.NavBar#AttrCaps).
-}
type alias NavBarAttrCaps =
    NavBar_.AttrCaps


{-| See [`M3e.Element.NavBar.SlotCaps`](M3e.Element.NavBar#SlotCaps).
-}
type alias NavBarSlotCaps =
    NavBar_.SlotCaps


{-| See [`M3e.Element.NavBar.Content`](M3e.Element.NavBar#Content).
-}
type alias NavBarContent =
    NavBar_.Content


{-| See [`M3e.Element.NavBar.ChildAdmittedBy`](M3e.Element.NavBar#ChildAdmittedBy).
-}
type alias NavBarChildAdmittedBy childAdm =
    NavBar_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavBar.Mode`](M3e.Element.NavBar#Mode).
-}
type alias NavBarMode =
    NavBar_.Mode


{-| See [`M3e.Element.NavBar.mode`](M3e.Element.NavBar#mode).
-}
navBarMode : Value NavBarMode -> Attr { c | mode : Supported } msg
navBarMode =
    NavBar_.mode


{-| See [`M3e.Element.NavBar.onChange`](M3e.Element.NavBar#onChange).
-}
navBarOnChange : msg -> Attr { c | onChange : Supported } msg
navBarOnChange =
    NavBar_.onChange


{-| See [`M3e.Element.NavBar.onBeforeinput`](M3e.Element.NavBar#onBeforeinput).
-}
navBarOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
navBarOnBeforeinput =
    NavBar_.onBeforeinput


{-| See [`M3e.Element.NavBar.onInput`](M3e.Element.NavBar#onInput).
-}
navBarOnInput : msg -> Attr { c | onInput : Supported } msg
navBarOnInput =
    NavBar_.onInput


{-| See [`M3e.Element.NavBar.child`](M3e.Element.NavBar#child).
-}
navBarChild : Element NavBarContent admittedBy msg -> Element free freeAdmittedBy msg
navBarChild =
    NavBar_.child

module M3e.Component.NavRail exposing (NavRailIs, NavRailAttrs, NavRailBuilder, NavRailAttrCaps, NavRailSlotCaps, NavRailContent, NavRailChildAdmittedBy, NavRailMode, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, navRail, navRailMode, navRailOnBeforeinput, navRailOnInput, navRailOnChange, navRailChild, toggle, toggleFor)

{-| The **NavRail** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.NavRail`](M3e.Element.NavRail) as `navRail`, [`M3e.Element.NavRailToggle`](M3e.Element.NavRailToggle) as `toggle`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs NavRailIs, NavRailAttrs, NavRailBuilder, NavRailAttrCaps, NavRailSlotCaps, NavRailContent, NavRailChildAdmittedBy, NavRailMode, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, navRail, navRailMode, navRailOnBeforeinput, navRailOnInput, navRailOnChange, navRailChild, toggle, toggleFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.NavRail as NavRail_
import M3e.Element.NavRailToggle as Toggle_


{-| The `navRail` element of this family — delegates to [`M3e.Element.NavRail.component`](M3e.Element.NavRail#component).
-}
navRail :
    List (Attr NavRailAttrs msg)
    -> List (Element NavRailContent (NavRailChildAdmittedBy childAdm) msg)
    -> Element (NavRailIs s) admittedBy msg
navRail =
    NavRail_.component


{-| See [`M3e.Element.NavRail.Is`](M3e.Element.NavRail#Is).
-}
type alias NavRailIs s =
    NavRail_.Is s


{-| See [`M3e.Element.NavRail.Attrs`](M3e.Element.NavRail#Attrs).
-}
type alias NavRailAttrs =
    NavRail_.Attrs


{-| See [`M3e.Element.NavRail.Builder`](M3e.Element.NavRail#Builder).
-}
type alias NavRailBuilder attrCaps slotCaps msg kind =
    NavRail_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavRail.AttrCaps`](M3e.Element.NavRail#AttrCaps).
-}
type alias NavRailAttrCaps =
    NavRail_.AttrCaps


{-| See [`M3e.Element.NavRail.SlotCaps`](M3e.Element.NavRail#SlotCaps).
-}
type alias NavRailSlotCaps =
    NavRail_.SlotCaps


{-| See [`M3e.Element.NavRail.Content`](M3e.Element.NavRail#Content).
-}
type alias NavRailContent =
    NavRail_.Content


{-| See [`M3e.Element.NavRail.ChildAdmittedBy`](M3e.Element.NavRail#ChildAdmittedBy).
-}
type alias NavRailChildAdmittedBy childAdm =
    NavRail_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavRail.Mode`](M3e.Element.NavRail#Mode).
-}
type alias NavRailMode =
    NavRail_.Mode


{-| See [`M3e.Element.NavRail.mode`](M3e.Element.NavRail#mode).
-}
navRailMode : Value NavRailMode -> Attr { c | mode : Supported } msg
navRailMode =
    NavRail_.mode


{-| See [`M3e.Element.NavRail.onBeforeinput`](M3e.Element.NavRail#onBeforeinput).
-}
navRailOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
navRailOnBeforeinput =
    NavRail_.onBeforeinput


{-| See [`M3e.Element.NavRail.onInput`](M3e.Element.NavRail#onInput).
-}
navRailOnInput : msg -> Attr { c | onInput : Supported } msg
navRailOnInput =
    NavRail_.onInput


{-| See [`M3e.Element.NavRail.onChange`](M3e.Element.NavRail#onChange).
-}
navRailOnChange : msg -> Attr { c | onChange : Supported } msg
navRailOnChange =
    NavRail_.onChange


{-| See [`M3e.Element.NavRail.child`](M3e.Element.NavRail#child).
-}
navRailChild : Element NavRailContent admittedBy msg -> Element free freeAdmittedBy msg
navRailChild =
    NavRail_.child


{-| The `toggle` element of this family — delegates to [`M3e.Element.NavRailToggle.component`](M3e.Element.NavRailToggle#component).
-}
toggle :
    List (Attr ToggleAttrs msg)
    -> List (Element childAccepts (ToggleChildAdmittedBy childAdm) msg)
    -> Element (ToggleIs s) admittedBy msg
toggle =
    Toggle_.component


{-| See [`M3e.Element.NavRailToggle.Is`](M3e.Element.NavRailToggle#Is).
-}
type alias ToggleIs s =
    Toggle_.Is s


{-| See [`M3e.Element.NavRailToggle.Attrs`](M3e.Element.NavRailToggle#Attrs).
-}
type alias ToggleAttrs =
    Toggle_.Attrs


{-| See [`M3e.Element.NavRailToggle.Builder`](M3e.Element.NavRailToggle#Builder).
-}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Toggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.NavRailToggle.AttrCaps`](M3e.Element.NavRailToggle#AttrCaps).
-}
type alias ToggleAttrCaps =
    Toggle_.AttrCaps


{-| See [`M3e.Element.NavRailToggle.SlotCaps`](M3e.Element.NavRailToggle#SlotCaps).
-}
type alias ToggleSlotCaps =
    Toggle_.SlotCaps


{-| See [`M3e.Element.NavRailToggle.ChildAdmittedBy`](M3e.Element.NavRailToggle#ChildAdmittedBy).
-}
type alias ToggleChildAdmittedBy childAdm =
    Toggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.NavRailToggle.for`](M3e.Element.NavRailToggle#for).
-}
toggleFor : String -> Attr { c | for : Supported } msg
toggleFor =
    Toggle_.for

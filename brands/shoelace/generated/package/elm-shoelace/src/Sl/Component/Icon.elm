module Sl.Component.Icon exposing (IconIs, IconAttrs, IconBuilder, IconAttrCaps, IconSlotCaps, IconChildAdmittedBy, icon, iconLabel, iconLibrary, iconName, iconSrc, iconOnLoad, iconOnError)

{-| The **Icon** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Icon`](Sl.Element.Icon) as `icon`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs IconIs, IconAttrs, IconBuilder, IconAttrCaps, IconSlotCaps, IconChildAdmittedBy, icon, iconLabel, iconLibrary, iconName, iconSrc, iconOnLoad, iconOnError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Icon as Icon_


{-| The `icon` element of this family — delegates to [`Sl.Element.Icon.component`](Sl.Element.Icon#component).
-}
icon :
    List (Attr IconAttrs msg)
    -> List (Element childAccepts (IconChildAdmittedBy childAdm) msg)
    -> Element (IconIs s) admittedBy msg
icon =
    Icon_.component


{-| See [`Sl.Element.Icon.Is`](Sl.Element.Icon#Is).
-}
type alias IconIs s =
    Icon_.Is s


{-| See [`Sl.Element.Icon.Attrs`](Sl.Element.Icon#Attrs).
-}
type alias IconAttrs =
    Icon_.Attrs


{-| See [`Sl.Element.Icon.Builder`](Sl.Element.Icon#Builder).
-}
type alias IconBuilder attrCaps slotCaps msg kind =
    Icon_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Icon.AttrCaps`](Sl.Element.Icon#AttrCaps).
-}
type alias IconAttrCaps =
    Icon_.AttrCaps


{-| See [`Sl.Element.Icon.SlotCaps`](Sl.Element.Icon#SlotCaps).
-}
type alias IconSlotCaps =
    Icon_.SlotCaps


{-| See [`Sl.Element.Icon.ChildAdmittedBy`](Sl.Element.Icon#ChildAdmittedBy).
-}
type alias IconChildAdmittedBy childAdm =
    Icon_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Icon.label`](Sl.Element.Icon#label).
-}
iconLabel : String -> Attr { c | label : Supported } msg
iconLabel =
    Icon_.label


{-| See [`Sl.Element.Icon.library`](Sl.Element.Icon#library).
-}
iconLibrary : String -> Attr { c | library : Supported } msg
iconLibrary =
    Icon_.library


{-| See [`Sl.Element.Icon.name`](Sl.Element.Icon#name).
-}
iconName : String -> Attr { c | name : Supported } msg
iconName =
    Icon_.name


{-| See [`Sl.Element.Icon.src`](Sl.Element.Icon#src).
-}
iconSrc : String -> Attr { c | src : Supported } msg
iconSrc =
    Icon_.src


{-| See [`Sl.Element.Icon.onLoad`](Sl.Element.Icon#onLoad).
-}
iconOnLoad : msg -> Attr { c | onLoad : Supported } msg
iconOnLoad =
    Icon_.onLoad


{-| See [`Sl.Element.Icon.onError`](Sl.Element.Icon#onError).
-}
iconOnError : msg -> Attr { c | onError : Supported } msg
iconOnError =
    Icon_.onError

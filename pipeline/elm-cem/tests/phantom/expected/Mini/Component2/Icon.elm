module Mini.Component2.Icon exposing (IconIs, IconAttrs, IconBuilder, IconAttrCaps, IconSlotCaps, IconContent, IconChildAdmittedBy, icon, iconChild)

{-| The **Icon** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Icon`](Mini.Element.Icon) as `icon`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs IconIs, IconAttrs, IconBuilder, IconAttrCaps, IconSlotCaps, IconContent, IconChildAdmittedBy, icon, iconChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Mini.Element.Icon as Icon_


{-| The `icon` element of this family — delegates to [`Mini.Element.Icon.component`](Mini.Element.Icon#component).
-}
icon :
    List (Attr IconAttrs msg)
    -> List (Element IconContent (IconChildAdmittedBy childAdm) msg)
    -> Element (IconIs s) admittedBy msg
icon =
    Icon_.component


{-| See [`Mini.Element.Icon.Is`](Mini.Element.Icon#Is).
-}
type alias IconIs s =
    Icon_.Is s


{-| See [`Mini.Element.Icon.Attrs`](Mini.Element.Icon#Attrs).
-}
type alias IconAttrs =
    Icon_.Attrs


{-| See [`Mini.Element.Icon.Builder`](Mini.Element.Icon#Builder).
-}
type alias IconBuilder attrCaps slotCaps msg kind =
    Icon_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Icon.AttrCaps`](Mini.Element.Icon#AttrCaps).
-}
type alias IconAttrCaps =
    Icon_.AttrCaps


{-| See [`Mini.Element.Icon.SlotCaps`](Mini.Element.Icon#SlotCaps).
-}
type alias IconSlotCaps =
    Icon_.SlotCaps


{-| See [`Mini.Element.Icon.Content`](Mini.Element.Icon#Content).
-}
type alias IconContent =
    Icon_.Content


{-| See [`Mini.Element.Icon.ChildAdmittedBy`](Mini.Element.Icon#ChildAdmittedBy).
-}
type alias IconChildAdmittedBy childAdm =
    Icon_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Icon.child`](Mini.Element.Icon#child).
-}
iconChild : Element IconContent admittedBy msg -> Element free freeAdmittedBy msg
iconChild =
    Icon_.child

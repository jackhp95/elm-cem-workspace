module Hz.Component.Global exposing (GlobalIs, GlobalAttrs, GlobalBuilder, GlobalAttrCaps, GlobalSlotCaps, GlobalContent, GlobalChildAdmittedBy, global, globalChild)

{-| The **Global** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.Global`](Hz.Element.Global) as `global`.

Prefer whichever import reads best — the flat `Hz.Element.*` modules and
this family module are the same elements, same types.

@docs GlobalIs, GlobalAttrs, GlobalBuilder, GlobalAttrCaps, GlobalSlotCaps, GlobalContent, GlobalChildAdmittedBy, global, globalChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Hz.Element.Global as Global_


{-| The `global` element of this family — delegates to [`Hz.Element.Global.component`](Hz.Element.Global#component).
-}
global :
    List (Attr GlobalAttrs msg)
    -> List (Element GlobalContent (GlobalChildAdmittedBy childAdm) msg)
    -> Element (GlobalIs s) admittedBy msg
global =
    Global_.component


{-| See [`Hz.Element.Global.Is`](Hz.Element.Global#Is).
-}
type alias GlobalIs s =
    Global_.Is s


{-| See [`Hz.Element.Global.Attrs`](Hz.Element.Global#Attrs).
-}
type alias GlobalAttrs =
    Global_.Attrs


{-| See [`Hz.Element.Global.Builder`](Hz.Element.Global#Builder).
-}
type alias GlobalBuilder attrCaps slotCaps msg kind =
    Global_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.Global.AttrCaps`](Hz.Element.Global#AttrCaps).
-}
type alias GlobalAttrCaps =
    Global_.AttrCaps


{-| See [`Hz.Element.Global.SlotCaps`](Hz.Element.Global#SlotCaps).
-}
type alias GlobalSlotCaps =
    Global_.SlotCaps


{-| See [`Hz.Element.Global.Content`](Hz.Element.Global#Content).
-}
type alias GlobalContent =
    Global_.Content


{-| See [`Hz.Element.Global.ChildAdmittedBy`](Hz.Element.Global#ChildAdmittedBy).
-}
type alias GlobalChildAdmittedBy childAdm =
    Global_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.Global.child`](Hz.Element.Global#child).
-}
globalChild : Element GlobalContent admittedBy msg -> Element free freeAdmittedBy msg
globalChild =
    Global_.child

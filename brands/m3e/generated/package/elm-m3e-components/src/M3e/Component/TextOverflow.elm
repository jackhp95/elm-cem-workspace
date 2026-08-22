module M3e.Component.TextOverflow exposing (TextOverflowIs, TextOverflowAttrs, TextOverflowBuilder, TextOverflowAttrCaps, TextOverflowSlotCaps, TextOverflowContent, TextOverflowChildAdmittedBy, textOverflow, textOverflowChild)

{-| The **TextOverflow** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.TextOverflow`](M3e.Element.TextOverflow) as `textOverflow`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TextOverflowIs, TextOverflowAttrs, TextOverflowBuilder, TextOverflowAttrCaps, TextOverflowSlotCaps, TextOverflowContent, TextOverflowChildAdmittedBy, textOverflow, textOverflowChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import M3e.Element.TextOverflow as TextOverflow_


{-| The `textOverflow` element of this family — delegates to [`M3e.Element.TextOverflow.component`](M3e.Element.TextOverflow#component).
-}
textOverflow :
    List (Attr TextOverflowAttrs msg)
    -> List (Element TextOverflowContent (TextOverflowChildAdmittedBy childAdm) msg)
    -> Element (TextOverflowIs s) admittedBy msg
textOverflow =
    TextOverflow_.component


{-| See [`M3e.Element.TextOverflow.Is`](M3e.Element.TextOverflow#Is).
-}
type alias TextOverflowIs s =
    TextOverflow_.Is s


{-| See [`M3e.Element.TextOverflow.Attrs`](M3e.Element.TextOverflow#Attrs).
-}
type alias TextOverflowAttrs =
    TextOverflow_.Attrs


{-| See [`M3e.Element.TextOverflow.Builder`](M3e.Element.TextOverflow#Builder).
-}
type alias TextOverflowBuilder attrCaps slotCaps msg kind =
    TextOverflow_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TextOverflow.AttrCaps`](M3e.Element.TextOverflow#AttrCaps).
-}
type alias TextOverflowAttrCaps =
    TextOverflow_.AttrCaps


{-| See [`M3e.Element.TextOverflow.SlotCaps`](M3e.Element.TextOverflow#SlotCaps).
-}
type alias TextOverflowSlotCaps =
    TextOverflow_.SlotCaps


{-| See [`M3e.Element.TextOverflow.Content`](M3e.Element.TextOverflow#Content).
-}
type alias TextOverflowContent =
    TextOverflow_.Content


{-| See [`M3e.Element.TextOverflow.ChildAdmittedBy`](M3e.Element.TextOverflow#ChildAdmittedBy).
-}
type alias TextOverflowChildAdmittedBy childAdm =
    TextOverflow_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TextOverflow.child`](M3e.Element.TextOverflow#child).
-}
textOverflowChild : Element TextOverflowContent admittedBy msg -> Element free freeAdmittedBy msg
textOverflowChild =
    TextOverflow_.child

module Mini.Component2.Toolbar exposing (ToolbarIs, ToolbarAttrs, ToolbarBuilder, ToolbarAttrCaps, ToolbarSlotCaps, ToolbarChildAdmittedBy, toolbar, toolbarChild)

{-| The **Toolbar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Toolbar`](Mini.Element.Toolbar) as `toolbar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ToolbarIs, ToolbarAttrs, ToolbarBuilder, ToolbarAttrCaps, ToolbarSlotCaps, ToolbarChildAdmittedBy, toolbar, toolbarChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Mini.Element.Toolbar as Toolbar_


{-| The `toolbar` element of this family — delegates to [`Mini.Element.Toolbar.component`](Mini.Element.Toolbar#component).
-}
toolbar :
    List (Attr ToolbarAttrs msg)
    -> List (Element Actions (ToolbarChildAdmittedBy childAdm) msg)
    -> Element (ToolbarIs s) admittedBy msg
toolbar =
    Toolbar_.component


{-| See [`Mini.Element.Toolbar.Is`](Mini.Element.Toolbar#Is).
-}
type alias ToolbarIs s =
    Toolbar_.Is s


{-| See [`Mini.Element.Toolbar.Attrs`](Mini.Element.Toolbar#Attrs).
-}
type alias ToolbarAttrs =
    Toolbar_.Attrs


{-| See [`Mini.Element.Toolbar.Builder`](Mini.Element.Toolbar#Builder).
-}
type alias ToolbarBuilder attrCaps slotCaps msg kind =
    Toolbar_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Toolbar.AttrCaps`](Mini.Element.Toolbar#AttrCaps).
-}
type alias ToolbarAttrCaps =
    Toolbar_.AttrCaps


{-| See [`Mini.Element.Toolbar.SlotCaps`](Mini.Element.Toolbar#SlotCaps).
-}
type alias ToolbarSlotCaps =
    Toolbar_.SlotCaps


{-| See [`Mini.Element.Toolbar.ChildAdmittedBy`](Mini.Element.Toolbar#ChildAdmittedBy).
-}
type alias ToolbarChildAdmittedBy childAdm =
    Toolbar_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Toolbar.child`](Mini.Element.Toolbar#child).
-}
toolbarChild : Element Actions admittedBy msg -> Element free freeAdmittedBy msg
toolbarChild =
    Toolbar_.child

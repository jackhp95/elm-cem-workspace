module M3e.Component.Toolbar exposing (ToolbarIs, ToolbarAttrs, ToolbarBuilder, ToolbarAttrCaps, ToolbarSlotCaps, ToolbarChildAdmittedBy, ToolbarShape, ToolbarVariant, toolbar, toolbarShape, toolbarVariant, toolbarElevated, toolbarVertical, toolbarChild)

{-| The **Toolbar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Toolbar`](M3e.Element.Toolbar) as `toolbar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ToolbarIs, ToolbarAttrs, ToolbarBuilder, ToolbarAttrCaps, ToolbarSlotCaps, ToolbarChildAdmittedBy, ToolbarShape, ToolbarVariant, toolbar, toolbarShape, toolbarVariant, toolbarElevated, toolbarVertical, toolbarChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Toolbar as Toolbar_


{-| The `toolbar` element of this family — delegates to [`M3e.Element.Toolbar.component`](M3e.Element.Toolbar#component).
-}
toolbar :
    List (Attr ToolbarAttrs msg)
    -> List (Element childAccepts (ToolbarChildAdmittedBy childAdm) msg)
    -> Element (ToolbarIs s) admittedBy msg
toolbar =
    Toolbar_.component


{-| See [`M3e.Element.Toolbar.Is`](M3e.Element.Toolbar#Is).
-}
type alias ToolbarIs s =
    Toolbar_.Is s


{-| See [`M3e.Element.Toolbar.Attrs`](M3e.Element.Toolbar#Attrs).
-}
type alias ToolbarAttrs =
    Toolbar_.Attrs


{-| See [`M3e.Element.Toolbar.Builder`](M3e.Element.Toolbar#Builder).
-}
type alias ToolbarBuilder attrCaps slotCaps msg kind =
    Toolbar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Toolbar.AttrCaps`](M3e.Element.Toolbar#AttrCaps).
-}
type alias ToolbarAttrCaps =
    Toolbar_.AttrCaps


{-| See [`M3e.Element.Toolbar.SlotCaps`](M3e.Element.Toolbar#SlotCaps).
-}
type alias ToolbarSlotCaps =
    Toolbar_.SlotCaps


{-| See [`M3e.Element.Toolbar.ChildAdmittedBy`](M3e.Element.Toolbar#ChildAdmittedBy).
-}
type alias ToolbarChildAdmittedBy childAdm =
    Toolbar_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Toolbar.Shape`](M3e.Element.Toolbar#Shape).
-}
type alias ToolbarShape =
    Toolbar_.Shape


{-| See [`M3e.Element.Toolbar.shape`](M3e.Element.Toolbar#shape).
-}
toolbarShape : Value ToolbarShape -> Attr { c | shape : Supported } msg
toolbarShape =
    Toolbar_.shape


{-| See [`M3e.Element.Toolbar.Variant`](M3e.Element.Toolbar#Variant).
-}
type alias ToolbarVariant =
    Toolbar_.Variant


{-| See [`M3e.Element.Toolbar.variant`](M3e.Element.Toolbar#variant).
-}
toolbarVariant : Value ToolbarVariant -> Attr { c | variant : Supported } msg
toolbarVariant =
    Toolbar_.variant


{-| See [`M3e.Element.Toolbar.elevated`](M3e.Element.Toolbar#elevated).
-}
toolbarElevated : Bool -> Attr { c | elevated : Supported } msg
toolbarElevated =
    Toolbar_.elevated


{-| See [`M3e.Element.Toolbar.vertical`](M3e.Element.Toolbar#vertical).
-}
toolbarVertical : Bool -> Attr { c | vertical : Supported } msg
toolbarVertical =
    Toolbar_.vertical


{-| See [`M3e.Element.Toolbar.child`](M3e.Element.Toolbar#child).
-}
toolbarChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
toolbarChild =
    Toolbar_.child

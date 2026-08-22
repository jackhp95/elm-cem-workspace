module M3e.Component.ContentPane exposing (ContentPaneIs, ContentPaneAttrs, ContentPaneBuilder, ContentPaneAttrCaps, ContentPaneSlotCaps, ContentPaneChildAdmittedBy, contentPane, contentPaneChild)

{-| The **ContentPane** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.ContentPane`](M3e.Element.ContentPane) as `contentPane`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ContentPaneIs, ContentPaneAttrs, ContentPaneBuilder, ContentPaneAttrCaps, ContentPaneSlotCaps, ContentPaneChildAdmittedBy, contentPane, contentPaneChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import M3e.Element.ContentPane as ContentPane_


{-| The `contentPane` element of this family — delegates to [`M3e.Element.ContentPane.component`](M3e.Element.ContentPane#component).
-}
contentPane :
    List (Attr ContentPaneAttrs msg)
    -> List (Element childAccepts (ContentPaneChildAdmittedBy childAdm) msg)
    -> Element (ContentPaneIs s) admittedBy msg
contentPane =
    ContentPane_.component


{-| See [`M3e.Element.ContentPane.Is`](M3e.Element.ContentPane#Is).
-}
type alias ContentPaneIs s =
    ContentPane_.Is s


{-| See [`M3e.Element.ContentPane.Attrs`](M3e.Element.ContentPane#Attrs).
-}
type alias ContentPaneAttrs =
    ContentPane_.Attrs


{-| See [`M3e.Element.ContentPane.Builder`](M3e.Element.ContentPane#Builder).
-}
type alias ContentPaneBuilder attrCaps slotCaps msg kind =
    ContentPane_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ContentPane.AttrCaps`](M3e.Element.ContentPane#AttrCaps).
-}
type alias ContentPaneAttrCaps =
    ContentPane_.AttrCaps


{-| See [`M3e.Element.ContentPane.SlotCaps`](M3e.Element.ContentPane#SlotCaps).
-}
type alias ContentPaneSlotCaps =
    ContentPane_.SlotCaps


{-| See [`M3e.Element.ContentPane.ChildAdmittedBy`](M3e.Element.ContentPane#ChildAdmittedBy).
-}
type alias ContentPaneChildAdmittedBy childAdm =
    ContentPane_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ContentPane.child`](M3e.Element.ContentPane#child).
-}
contentPaneChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
contentPaneChild =
    ContentPane_.child

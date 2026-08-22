module Hz.Component.Text exposing (TextIs, TextAttrs, TextBuilder, TextAttrCaps, TextSlotCaps, TextContent, TextChildAdmittedBy, text, textChild)

{-| The **Text** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.Text`](Hz.Element.Text) as `text`.

Prefer whichever import reads best — the flat `Hz.Element.*` modules and
this family module are the same elements, same types.

@docs TextIs, TextAttrs, TextBuilder, TextAttrCaps, TextSlotCaps, TextContent, TextChildAdmittedBy, text, textChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Hz.Element.Text as Text_


{-| The `text` element of this family — delegates to [`Hz.Element.Text.component`](Hz.Element.Text#component).
-}
text :
    List (Attr TextAttrs msg)
    -> List (Element TextContent (TextChildAdmittedBy childAdm) msg)
    -> Element (TextIs s) admittedBy msg
text =
    Text_.component


{-| See [`Hz.Element.Text.Is`](Hz.Element.Text#Is).
-}
type alias TextIs s =
    Text_.Is s


{-| See [`Hz.Element.Text.Attrs`](Hz.Element.Text#Attrs).
-}
type alias TextAttrs =
    Text_.Attrs


{-| See [`Hz.Element.Text.Builder`](Hz.Element.Text#Builder).
-}
type alias TextBuilder attrCaps slotCaps msg kind =
    Text_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.Text.AttrCaps`](Hz.Element.Text#AttrCaps).
-}
type alias TextAttrCaps =
    Text_.AttrCaps


{-| See [`Hz.Element.Text.SlotCaps`](Hz.Element.Text#SlotCaps).
-}
type alias TextSlotCaps =
    Text_.SlotCaps


{-| See [`Hz.Element.Text.Content`](Hz.Element.Text#Content).
-}
type alias TextContent =
    Text_.Content


{-| See [`Hz.Element.Text.ChildAdmittedBy`](Hz.Element.Text#ChildAdmittedBy).
-}
type alias TextChildAdmittedBy childAdm =
    Text_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.Text.child`](Hz.Element.Text#child).
-}
textChild : Element TextContent admittedBy msg -> Element free freeAdmittedBy msg
textChild =
    Text_.child

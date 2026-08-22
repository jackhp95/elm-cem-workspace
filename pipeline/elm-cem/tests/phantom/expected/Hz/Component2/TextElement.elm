module Hz.Component2.TextElement exposing (TextElementIs, TextElementAttrs, TextElementBuilder, TextElementAttrCaps, TextElementSlotCaps, TextElementContent, TextElementChildAdmittedBy, textElement, textElementChild)

{-| The **TextElement** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.TextElement`](Hz.Element.TextElement) as `textElement`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TextElementIs, TextElementAttrs, TextElementBuilder, TextElementAttrCaps, TextElementSlotCaps, TextElementContent, TextElementChildAdmittedBy, textElement, textElementChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Hz.Element.TextElement as TextElement_


{-| The `textElement` element of this family — delegates to [`Hz.Element.TextElement.component`](Hz.Element.TextElement#component).
-}
textElement :
    List (Attr TextElementAttrs msg)
    -> List (Element TextElementContent (TextElementChildAdmittedBy childAdm) msg)
    -> Element (TextElementIs s) admittedBy msg
textElement =
    TextElement_.component


{-| See [`Hz.Element.TextElement.Is`](Hz.Element.TextElement#Is).
-}
type alias TextElementIs s =
    TextElement_.Is s


{-| See [`Hz.Element.TextElement.Attrs`](Hz.Element.TextElement#Attrs).
-}
type alias TextElementAttrs =
    TextElement_.Attrs


{-| See [`Hz.Element.TextElement.Builder`](Hz.Element.TextElement#Builder).
-}
type alias TextElementBuilder attrCaps slotCaps msg kind =
    TextElement_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.TextElement.AttrCaps`](Hz.Element.TextElement#AttrCaps).
-}
type alias TextElementAttrCaps =
    TextElement_.AttrCaps


{-| See [`Hz.Element.TextElement.SlotCaps`](Hz.Element.TextElement#SlotCaps).
-}
type alias TextElementSlotCaps =
    TextElement_.SlotCaps


{-| See [`Hz.Element.TextElement.Content`](Hz.Element.TextElement#Content).
-}
type alias TextElementContent =
    TextElement_.Content


{-| See [`Hz.Element.TextElement.ChildAdmittedBy`](Hz.Element.TextElement#ChildAdmittedBy).
-}
type alias TextElementChildAdmittedBy childAdm =
    TextElement_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.TextElement.child`](Hz.Element.TextElement#child).
-}
textElementChild : Element TextElementContent admittedBy msg -> Element free freeAdmittedBy msg
textElementChild =
    TextElement_.child

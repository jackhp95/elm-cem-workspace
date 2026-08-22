module Or.Component.Plain exposing (PlainIs, PlainAttrs, PlainBuilder, PlainAttrCaps, PlainSlotCaps, PlainContent, PlainChildAdmittedBy, plain, plainChild)

{-| The **Plain** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Or.Element.Plain`](Or.Element.Plain) as `plain`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs PlainIs, PlainAttrs, PlainBuilder, PlainAttrCaps, PlainSlotCaps, PlainContent, PlainChildAdmittedBy, plain, plainChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Or.Element.Plain as Plain_


{-| The `plain` element of this family — delegates to [`Or.Element.Plain.component`](Or.Element.Plain#component).
-}
plain :
    List (Attr PlainAttrs msg)
    -> List (Element PlainContent (PlainChildAdmittedBy childAdm) msg)
    -> Element (PlainIs s) admittedBy msg
plain =
    Plain_.component


{-| See [`Or.Element.Plain.Is`](Or.Element.Plain#Is).
-}
type alias PlainIs s =
    Plain_.Is s


{-| See [`Or.Element.Plain.Attrs`](Or.Element.Plain#Attrs).
-}
type alias PlainAttrs =
    Plain_.Attrs


{-| See [`Or.Element.Plain.Builder`](Or.Element.Plain#Builder).
-}
type alias PlainBuilder attrCaps slotCaps msg kind =
    Plain_.Builder attrCaps slotCaps msg kind


{-| See [`Or.Element.Plain.AttrCaps`](Or.Element.Plain#AttrCaps).
-}
type alias PlainAttrCaps =
    Plain_.AttrCaps


{-| See [`Or.Element.Plain.SlotCaps`](Or.Element.Plain#SlotCaps).
-}
type alias PlainSlotCaps =
    Plain_.SlotCaps


{-| See [`Or.Element.Plain.Content`](Or.Element.Plain#Content).
-}
type alias PlainContent =
    Plain_.Content


{-| See [`Or.Element.Plain.ChildAdmittedBy`](Or.Element.Plain#ChildAdmittedBy).
-}
type alias PlainChildAdmittedBy childAdm =
    Plain_.ChildAdmittedBy childAdm


{-| See [`Or.Element.Plain.child`](Or.Element.Plain#child).
-}
plainChild : Element PlainContent admittedBy msg -> Element free freeAdmittedBy msg
plainChild =
    Plain_.child

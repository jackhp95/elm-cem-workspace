module Sl.Component.Card exposing (CardIs, CardAttrs, CardBuilder, CardAttrCaps, CardSlotCaps, CardChildAdmittedBy, card)

{-| The **Card** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Card`](Sl.Element.Card) as `card`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs CardIs, CardAttrs, CardBuilder, CardAttrCaps, CardSlotCaps, CardChildAdmittedBy, card

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Sl.Element.Card as Card_


{-| The `card` element of this family — delegates to [`Sl.Element.Card.component`](Sl.Element.Card#component).
-}
card :
    List (Attr CardAttrs msg)
    -> List (Element childAccepts (CardChildAdmittedBy childAdm) msg)
    -> Element (CardIs s) admittedBy msg
card =
    Card_.component


{-| See [`Sl.Element.Card.Is`](Sl.Element.Card#Is).
-}
type alias CardIs s =
    Card_.Is s


{-| See [`Sl.Element.Card.Attrs`](Sl.Element.Card#Attrs).
-}
type alias CardAttrs =
    Card_.Attrs


{-| See [`Sl.Element.Card.Builder`](Sl.Element.Card#Builder).
-}
type alias CardBuilder attrCaps slotCaps msg kind =
    Card_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Card.AttrCaps`](Sl.Element.Card#AttrCaps).
-}
type alias CardAttrCaps =
    Card_.AttrCaps


{-| See [`Sl.Element.Card.SlotCaps`](Sl.Element.Card#SlotCaps).
-}
type alias CardSlotCaps =
    Card_.SlotCaps


{-| See [`Sl.Element.Card.ChildAdmittedBy`](Sl.Element.Card#ChildAdmittedBy).
-}
type alias CardChildAdmittedBy childAdm =
    Card_.ChildAdmittedBy childAdm

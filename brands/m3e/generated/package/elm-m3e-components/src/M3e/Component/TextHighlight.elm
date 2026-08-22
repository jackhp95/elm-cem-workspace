module M3e.Component.TextHighlight exposing (TextHighlightIs, TextHighlightAttrs, TextHighlightBuilder, TextHighlightAttrCaps, TextHighlightSlotCaps, TextHighlightChildAdmittedBy, TextHighlightMode, textHighlight, textHighlightMode, textHighlightCaseSensitive, textHighlightDisabled, textHighlightTerm, textHighlightOnHighlight, textHighlightChild)

{-| The **TextHighlight** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.TextHighlight`](M3e.Element.TextHighlight) as `textHighlight`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TextHighlightIs, TextHighlightAttrs, TextHighlightBuilder, TextHighlightAttrCaps, TextHighlightSlotCaps, TextHighlightChildAdmittedBy, TextHighlightMode, textHighlight, textHighlightMode, textHighlightCaseSensitive, textHighlightDisabled, textHighlightTerm, textHighlightOnHighlight, textHighlightChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.TextHighlight as TextHighlight_


{-| The `textHighlight` element of this family — delegates to [`M3e.Element.TextHighlight.component`](M3e.Element.TextHighlight#component).
-}
textHighlight :
    List (Attr TextHighlightAttrs msg)
    -> List (Element childAccepts (TextHighlightChildAdmittedBy childAdm) msg)
    -> Element (TextHighlightIs s) admittedBy msg
textHighlight =
    TextHighlight_.component


{-| See [`M3e.Element.TextHighlight.Is`](M3e.Element.TextHighlight#Is).
-}
type alias TextHighlightIs s =
    TextHighlight_.Is s


{-| See [`M3e.Element.TextHighlight.Attrs`](M3e.Element.TextHighlight#Attrs).
-}
type alias TextHighlightAttrs =
    TextHighlight_.Attrs


{-| See [`M3e.Element.TextHighlight.Builder`](M3e.Element.TextHighlight#Builder).
-}
type alias TextHighlightBuilder attrCaps slotCaps msg kind =
    TextHighlight_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TextHighlight.AttrCaps`](M3e.Element.TextHighlight#AttrCaps).
-}
type alias TextHighlightAttrCaps =
    TextHighlight_.AttrCaps


{-| See [`M3e.Element.TextHighlight.SlotCaps`](M3e.Element.TextHighlight#SlotCaps).
-}
type alias TextHighlightSlotCaps =
    TextHighlight_.SlotCaps


{-| See [`M3e.Element.TextHighlight.ChildAdmittedBy`](M3e.Element.TextHighlight#ChildAdmittedBy).
-}
type alias TextHighlightChildAdmittedBy childAdm =
    TextHighlight_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TextHighlight.Mode`](M3e.Element.TextHighlight#Mode).
-}
type alias TextHighlightMode =
    TextHighlight_.Mode


{-| See [`M3e.Element.TextHighlight.mode`](M3e.Element.TextHighlight#mode).
-}
textHighlightMode : Value TextHighlightMode -> Attr { c | mode : Supported } msg
textHighlightMode =
    TextHighlight_.mode


{-| See [`M3e.Element.TextHighlight.caseSensitive`](M3e.Element.TextHighlight#caseSensitive).
-}
textHighlightCaseSensitive : Bool -> Attr { c | caseSensitive : Supported } msg
textHighlightCaseSensitive =
    TextHighlight_.caseSensitive


{-| See [`M3e.Element.TextHighlight.disabled`](M3e.Element.TextHighlight#disabled).
-}
textHighlightDisabled : Bool -> Attr { c | disabled : Supported } msg
textHighlightDisabled =
    TextHighlight_.disabled


{-| See [`M3e.Element.TextHighlight.term`](M3e.Element.TextHighlight#term).
-}
textHighlightTerm : String -> Attr { c | term : Supported } msg
textHighlightTerm =
    TextHighlight_.term


{-| See [`M3e.Element.TextHighlight.onHighlight`](M3e.Element.TextHighlight#onHighlight).
-}
textHighlightOnHighlight : msg -> Attr { c | onHighlight : Supported } msg
textHighlightOnHighlight =
    TextHighlight_.onHighlight


{-| See [`M3e.Element.TextHighlight.child`](M3e.Element.TextHighlight#child).
-}
textHighlightChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
textHighlightChild =
    TextHighlight_.child

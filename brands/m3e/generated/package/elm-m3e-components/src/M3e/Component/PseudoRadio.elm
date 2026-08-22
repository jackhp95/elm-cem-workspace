module M3e.Component.PseudoRadio exposing (PseudoRadioIs, PseudoRadioAttrs, PseudoRadioBuilder, PseudoRadioAttrCaps, PseudoRadioSlotCaps, PseudoRadioChildAdmittedBy, pseudoRadio, pseudoRadioChecked, pseudoRadioDisabled, pseudoRadioDefaultChecked)

{-| The **PseudoRadio** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.PseudoRadio`](M3e.Element.PseudoRadio) as `pseudoRadio`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs PseudoRadioIs, PseudoRadioAttrs, PseudoRadioBuilder, PseudoRadioAttrCaps, PseudoRadioSlotCaps, PseudoRadioChildAdmittedBy, pseudoRadio, pseudoRadioChecked, pseudoRadioDisabled, pseudoRadioDefaultChecked

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.PseudoRadio as PseudoRadio_


{-| The `pseudoRadio` element of this family — delegates to [`M3e.Element.PseudoRadio.component`](M3e.Element.PseudoRadio#component).
-}
pseudoRadio :
    List (Attr PseudoRadioAttrs msg)
    -> List (Element childAccepts (PseudoRadioChildAdmittedBy childAdm) msg)
    -> Element (PseudoRadioIs s) admittedBy msg
pseudoRadio =
    PseudoRadio_.component


{-| See [`M3e.Element.PseudoRadio.Is`](M3e.Element.PseudoRadio#Is).
-}
type alias PseudoRadioIs s =
    PseudoRadio_.Is s


{-| See [`M3e.Element.PseudoRadio.Attrs`](M3e.Element.PseudoRadio#Attrs).
-}
type alias PseudoRadioAttrs =
    PseudoRadio_.Attrs


{-| See [`M3e.Element.PseudoRadio.Builder`](M3e.Element.PseudoRadio#Builder).
-}
type alias PseudoRadioBuilder attrCaps slotCaps msg kind =
    PseudoRadio_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.PseudoRadio.AttrCaps`](M3e.Element.PseudoRadio#AttrCaps).
-}
type alias PseudoRadioAttrCaps =
    PseudoRadio_.AttrCaps


{-| See [`M3e.Element.PseudoRadio.SlotCaps`](M3e.Element.PseudoRadio#SlotCaps).
-}
type alias PseudoRadioSlotCaps =
    PseudoRadio_.SlotCaps


{-| See [`M3e.Element.PseudoRadio.ChildAdmittedBy`](M3e.Element.PseudoRadio#ChildAdmittedBy).
-}
type alias PseudoRadioChildAdmittedBy childAdm =
    PseudoRadio_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.PseudoRadio.checked`](M3e.Element.PseudoRadio#checked).
-}
pseudoRadioChecked : Bool -> Attr { c | checked : Supported } msg
pseudoRadioChecked =
    PseudoRadio_.checked


{-| See [`M3e.Element.PseudoRadio.disabled`](M3e.Element.PseudoRadio#disabled).
-}
pseudoRadioDisabled : Bool -> Attr { c | disabled : Supported } msg
pseudoRadioDisabled =
    PseudoRadio_.disabled


{-| See [`M3e.Element.PseudoRadio.defaultChecked`](M3e.Element.PseudoRadio#defaultChecked).
-}
pseudoRadioDefaultChecked : Bool -> Attr { c | checked : Supported } msg
pseudoRadioDefaultChecked =
    PseudoRadio_.defaultChecked

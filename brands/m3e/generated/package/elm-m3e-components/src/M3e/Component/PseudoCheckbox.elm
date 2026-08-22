module M3e.Component.PseudoCheckbox exposing (PseudoCheckboxIs, PseudoCheckboxAttrs, PseudoCheckboxBuilder, PseudoCheckboxAttrCaps, PseudoCheckboxSlotCaps, PseudoCheckboxChildAdmittedBy, pseudoCheckbox, pseudoCheckboxChecked, pseudoCheckboxDisabled, pseudoCheckboxIndeterminate, pseudoCheckboxDefaultChecked)

{-| The **PseudoCheckbox** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.PseudoCheckbox`](M3e.Element.PseudoCheckbox) as `pseudoCheckbox`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs PseudoCheckboxIs, PseudoCheckboxAttrs, PseudoCheckboxBuilder, PseudoCheckboxAttrCaps, PseudoCheckboxSlotCaps, PseudoCheckboxChildAdmittedBy, pseudoCheckbox, pseudoCheckboxChecked, pseudoCheckboxDisabled, pseudoCheckboxIndeterminate, pseudoCheckboxDefaultChecked

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.PseudoCheckbox as PseudoCheckbox_


{-| The `pseudoCheckbox` element of this family — delegates to [`M3e.Element.PseudoCheckbox.component`](M3e.Element.PseudoCheckbox#component).
-}
pseudoCheckbox :
    List (Attr PseudoCheckboxAttrs msg)
    -> List (Element childAccepts (PseudoCheckboxChildAdmittedBy childAdm) msg)
    -> Element (PseudoCheckboxIs s) admittedBy msg
pseudoCheckbox =
    PseudoCheckbox_.component


{-| See [`M3e.Element.PseudoCheckbox.Is`](M3e.Element.PseudoCheckbox#Is).
-}
type alias PseudoCheckboxIs s =
    PseudoCheckbox_.Is s


{-| See [`M3e.Element.PseudoCheckbox.Attrs`](M3e.Element.PseudoCheckbox#Attrs).
-}
type alias PseudoCheckboxAttrs =
    PseudoCheckbox_.Attrs


{-| See [`M3e.Element.PseudoCheckbox.Builder`](M3e.Element.PseudoCheckbox#Builder).
-}
type alias PseudoCheckboxBuilder attrCaps slotCaps msg kind =
    PseudoCheckbox_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.PseudoCheckbox.AttrCaps`](M3e.Element.PseudoCheckbox#AttrCaps).
-}
type alias PseudoCheckboxAttrCaps =
    PseudoCheckbox_.AttrCaps


{-| See [`M3e.Element.PseudoCheckbox.SlotCaps`](M3e.Element.PseudoCheckbox#SlotCaps).
-}
type alias PseudoCheckboxSlotCaps =
    PseudoCheckbox_.SlotCaps


{-| See [`M3e.Element.PseudoCheckbox.ChildAdmittedBy`](M3e.Element.PseudoCheckbox#ChildAdmittedBy).
-}
type alias PseudoCheckboxChildAdmittedBy childAdm =
    PseudoCheckbox_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.PseudoCheckbox.checked`](M3e.Element.PseudoCheckbox#checked).
-}
pseudoCheckboxChecked : Bool -> Attr { c | checked : Supported } msg
pseudoCheckboxChecked =
    PseudoCheckbox_.checked


{-| See [`M3e.Element.PseudoCheckbox.disabled`](M3e.Element.PseudoCheckbox#disabled).
-}
pseudoCheckboxDisabled : Bool -> Attr { c | disabled : Supported } msg
pseudoCheckboxDisabled =
    PseudoCheckbox_.disabled


{-| See [`M3e.Element.PseudoCheckbox.indeterminate`](M3e.Element.PseudoCheckbox#indeterminate).
-}
pseudoCheckboxIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
pseudoCheckboxIndeterminate =
    PseudoCheckbox_.indeterminate


{-| See [`M3e.Element.PseudoCheckbox.defaultChecked`](M3e.Element.PseudoCheckbox#defaultChecked).
-}
pseudoCheckboxDefaultChecked : Bool -> Attr { c | checked : Supported } msg
pseudoCheckboxDefaultChecked =
    PseudoCheckbox_.defaultChecked

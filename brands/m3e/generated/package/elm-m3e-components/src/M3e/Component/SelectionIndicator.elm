module M3e.Component.SelectionIndicator exposing (SelectionIndicatorIs, SelectionIndicatorAttrs, SelectionIndicatorBuilder, SelectionIndicatorAttrCaps, SelectionIndicatorSlotCaps, SelectionIndicatorChildAdmittedBy, selectionIndicator, selectionIndicatorBounce, selectionIndicatorCentered, selectionIndicatorDisabled, selectionIndicatorFor, selectionIndicatorSelected, selectionIndicatorDefaultSelected)

{-| The **SelectionIndicator** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SelectionIndicator`](M3e.Element.SelectionIndicator) as `selectionIndicator`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SelectionIndicatorIs, SelectionIndicatorAttrs, SelectionIndicatorBuilder, SelectionIndicatorAttrCaps, SelectionIndicatorSlotCaps, SelectionIndicatorChildAdmittedBy, selectionIndicator, selectionIndicatorBounce, selectionIndicatorCentered, selectionIndicatorDisabled, selectionIndicatorFor, selectionIndicatorSelected, selectionIndicatorDefaultSelected

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.SelectionIndicator as SelectionIndicator_


{-| The `selectionIndicator` element of this family — delegates to [`M3e.Element.SelectionIndicator.component`](M3e.Element.SelectionIndicator#component).
-}
selectionIndicator :
    List (Attr SelectionIndicatorAttrs msg)
    -> List (Element childAccepts (SelectionIndicatorChildAdmittedBy childAdm) msg)
    -> Element (SelectionIndicatorIs s) admittedBy msg
selectionIndicator =
    SelectionIndicator_.component


{-| See [`M3e.Element.SelectionIndicator.Is`](M3e.Element.SelectionIndicator#Is).
-}
type alias SelectionIndicatorIs s =
    SelectionIndicator_.Is s


{-| See [`M3e.Element.SelectionIndicator.Attrs`](M3e.Element.SelectionIndicator#Attrs).
-}
type alias SelectionIndicatorAttrs =
    SelectionIndicator_.Attrs


{-| See [`M3e.Element.SelectionIndicator.Builder`](M3e.Element.SelectionIndicator#Builder).
-}
type alias SelectionIndicatorBuilder attrCaps slotCaps msg kind =
    SelectionIndicator_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SelectionIndicator.AttrCaps`](M3e.Element.SelectionIndicator#AttrCaps).
-}
type alias SelectionIndicatorAttrCaps =
    SelectionIndicator_.AttrCaps


{-| See [`M3e.Element.SelectionIndicator.SlotCaps`](M3e.Element.SelectionIndicator#SlotCaps).
-}
type alias SelectionIndicatorSlotCaps =
    SelectionIndicator_.SlotCaps


{-| See [`M3e.Element.SelectionIndicator.ChildAdmittedBy`](M3e.Element.SelectionIndicator#ChildAdmittedBy).
-}
type alias SelectionIndicatorChildAdmittedBy childAdm =
    SelectionIndicator_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SelectionIndicator.bounce`](M3e.Element.SelectionIndicator#bounce).
-}
selectionIndicatorBounce : Bool -> Attr { c | bounce : Supported } msg
selectionIndicatorBounce =
    SelectionIndicator_.bounce


{-| See [`M3e.Element.SelectionIndicator.centered`](M3e.Element.SelectionIndicator#centered).
-}
selectionIndicatorCentered : Bool -> Attr { c | centered : Supported } msg
selectionIndicatorCentered =
    SelectionIndicator_.centered


{-| See [`M3e.Element.SelectionIndicator.disabled`](M3e.Element.SelectionIndicator#disabled).
-}
selectionIndicatorDisabled : Bool -> Attr { c | disabled : Supported } msg
selectionIndicatorDisabled =
    SelectionIndicator_.disabled


{-| See [`M3e.Element.SelectionIndicator.for`](M3e.Element.SelectionIndicator#for).
-}
selectionIndicatorFor : String -> Attr { c | for : Supported } msg
selectionIndicatorFor =
    SelectionIndicator_.for


{-| See [`M3e.Element.SelectionIndicator.selected`](M3e.Element.SelectionIndicator#selected).
-}
selectionIndicatorSelected : Bool -> Attr { c | selected : Supported } msg
selectionIndicatorSelected =
    SelectionIndicator_.selected


{-| See [`M3e.Element.SelectionIndicator.defaultSelected`](M3e.Element.SelectionIndicator#defaultSelected).
-}
selectionIndicatorDefaultSelected : Bool -> Attr { c | selected : Supported } msg
selectionIndicatorDefaultSelected =
    SelectionIndicator_.defaultSelected

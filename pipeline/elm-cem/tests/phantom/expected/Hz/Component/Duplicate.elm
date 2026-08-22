module Hz.Component.Duplicate exposing (DuplicateIs, DuplicateAttrs, DuplicateBuilder, DuplicateAttrCaps, DuplicateSlotCaps, DuplicateContent, DuplicateChildAdmittedBy, duplicate, duplicateValue, duplicateDefaultValue, duplicateChild)

{-| The **Duplicate** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Hz.Element.Duplicate`](Hz.Element.Duplicate) as `duplicate`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DuplicateIs, DuplicateAttrs, DuplicateBuilder, DuplicateAttrCaps, DuplicateSlotCaps, DuplicateContent, DuplicateChildAdmittedBy, duplicate, duplicateValue, duplicateDefaultValue, duplicateChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Hz.Element.Duplicate as Duplicate_


{-| The `duplicate` element of this family — delegates to [`Hz.Element.Duplicate.component`](Hz.Element.Duplicate#component).
-}
duplicate :
    List (Attr DuplicateAttrs msg)
    -> List (Element DuplicateContent (DuplicateChildAdmittedBy childAdm) msg)
    -> Element (DuplicateIs s) admittedBy msg
duplicate =
    Duplicate_.component


{-| See [`Hz.Element.Duplicate.Is`](Hz.Element.Duplicate#Is).
-}
type alias DuplicateIs s =
    Duplicate_.Is s


{-| See [`Hz.Element.Duplicate.Attrs`](Hz.Element.Duplicate#Attrs).
-}
type alias DuplicateAttrs =
    Duplicate_.Attrs


{-| See [`Hz.Element.Duplicate.Builder`](Hz.Element.Duplicate#Builder).
-}
type alias DuplicateBuilder attrCaps slotCaps msg kind =
    Duplicate_.Builder attrCaps slotCaps msg kind


{-| See [`Hz.Element.Duplicate.AttrCaps`](Hz.Element.Duplicate#AttrCaps).
-}
type alias DuplicateAttrCaps =
    Duplicate_.AttrCaps


{-| See [`Hz.Element.Duplicate.SlotCaps`](Hz.Element.Duplicate#SlotCaps).
-}
type alias DuplicateSlotCaps =
    Duplicate_.SlotCaps


{-| See [`Hz.Element.Duplicate.Content`](Hz.Element.Duplicate#Content).
-}
type alias DuplicateContent =
    Duplicate_.Content


{-| See [`Hz.Element.Duplicate.ChildAdmittedBy`](Hz.Element.Duplicate#ChildAdmittedBy).
-}
type alias DuplicateChildAdmittedBy childAdm =
    Duplicate_.ChildAdmittedBy childAdm


{-| See [`Hz.Element.Duplicate.value`](Hz.Element.Duplicate#value).
-}
duplicateValue : String -> Attr { c | value : Supported } msg
duplicateValue =
    Duplicate_.value


{-| See [`Hz.Element.Duplicate.defaultValue`](Hz.Element.Duplicate#defaultValue).
-}
duplicateDefaultValue : String -> Attr { c | value : Supported } msg
duplicateDefaultValue =
    Duplicate_.defaultValue


{-| See [`Hz.Element.Duplicate.child`](Hz.Element.Duplicate#child).
-}
duplicateChild : Element DuplicateContent admittedBy msg -> Element free freeAdmittedBy msg
duplicateChild =
    Duplicate_.child

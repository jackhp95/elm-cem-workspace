module M3e.Component.FocusTrap exposing (FocusTrapIs, FocusTrapAttrs, FocusTrapBuilder, FocusTrapAttrCaps, FocusTrapSlotCaps, FocusTrapChildAdmittedBy, focusTrap, focusTrapDisabled, focusTrapChild)

{-| The **FocusTrap** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.FocusTrap`](M3e.Element.FocusTrap) as `focusTrap`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FocusTrapIs, FocusTrapAttrs, FocusTrapBuilder, FocusTrapAttrCaps, FocusTrapSlotCaps, FocusTrapChildAdmittedBy, focusTrap, focusTrapDisabled, focusTrapChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.FocusTrap as FocusTrap_


{-| The `focusTrap` element of this family — delegates to [`M3e.Element.FocusTrap.component`](M3e.Element.FocusTrap#component).
-}
focusTrap :
    List (Attr FocusTrapAttrs msg)
    -> List (Element childAccepts (FocusTrapChildAdmittedBy childAdm) msg)
    -> Element (FocusTrapIs s) admittedBy msg
focusTrap =
    FocusTrap_.component


{-| See [`M3e.Element.FocusTrap.Is`](M3e.Element.FocusTrap#Is).
-}
type alias FocusTrapIs s =
    FocusTrap_.Is s


{-| See [`M3e.Element.FocusTrap.Attrs`](M3e.Element.FocusTrap#Attrs).
-}
type alias FocusTrapAttrs =
    FocusTrap_.Attrs


{-| See [`M3e.Element.FocusTrap.Builder`](M3e.Element.FocusTrap#Builder).
-}
type alias FocusTrapBuilder attrCaps slotCaps msg kind =
    FocusTrap_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.FocusTrap.AttrCaps`](M3e.Element.FocusTrap#AttrCaps).
-}
type alias FocusTrapAttrCaps =
    FocusTrap_.AttrCaps


{-| See [`M3e.Element.FocusTrap.SlotCaps`](M3e.Element.FocusTrap#SlotCaps).
-}
type alias FocusTrapSlotCaps =
    FocusTrap_.SlotCaps


{-| See [`M3e.Element.FocusTrap.ChildAdmittedBy`](M3e.Element.FocusTrap#ChildAdmittedBy).
-}
type alias FocusTrapChildAdmittedBy childAdm =
    FocusTrap_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.FocusTrap.disabled`](M3e.Element.FocusTrap#disabled).
-}
focusTrapDisabled : Bool -> Attr { c | disabled : Supported } msg
focusTrapDisabled =
    FocusTrap_.disabled


{-| See [`M3e.Element.FocusTrap.child`](M3e.Element.FocusTrap#child).
-}
focusTrapChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
focusTrapChild =
    FocusTrap_.child

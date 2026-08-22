module M3e.Component.Collapsible exposing (CollapsibleIs, CollapsibleAttrs, CollapsibleBuilder, CollapsibleAttrCaps, CollapsibleSlotCaps, CollapsibleChildAdmittedBy, CollapsibleOrientation, collapsible, collapsibleOrientation, collapsibleNoAnimate, collapsibleOpen, collapsibleOnOpening, collapsibleOnOpened, collapsibleOnClosing, collapsibleOnClosed, collapsibleChild)

{-| The **Collapsible** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Collapsible`](M3e.Element.Collapsible) as `collapsible`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs CollapsibleIs, CollapsibleAttrs, CollapsibleBuilder, CollapsibleAttrCaps, CollapsibleSlotCaps, CollapsibleChildAdmittedBy, CollapsibleOrientation, collapsible, collapsibleOrientation, collapsibleNoAnimate, collapsibleOpen, collapsibleOnOpening, collapsibleOnOpened, collapsibleOnClosing, collapsibleOnClosed, collapsibleChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Collapsible as Collapsible_


{-| The `collapsible` element of this family — delegates to [`M3e.Element.Collapsible.component`](M3e.Element.Collapsible#component).
-}
collapsible :
    List (Attr CollapsibleAttrs msg)
    -> List (Element childAccepts (CollapsibleChildAdmittedBy childAdm) msg)
    -> Element (CollapsibleIs s) admittedBy msg
collapsible =
    Collapsible_.component


{-| See [`M3e.Element.Collapsible.Is`](M3e.Element.Collapsible#Is).
-}
type alias CollapsibleIs s =
    Collapsible_.Is s


{-| See [`M3e.Element.Collapsible.Attrs`](M3e.Element.Collapsible#Attrs).
-}
type alias CollapsibleAttrs =
    Collapsible_.Attrs


{-| See [`M3e.Element.Collapsible.Builder`](M3e.Element.Collapsible#Builder).
-}
type alias CollapsibleBuilder attrCaps slotCaps msg kind =
    Collapsible_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Collapsible.AttrCaps`](M3e.Element.Collapsible#AttrCaps).
-}
type alias CollapsibleAttrCaps =
    Collapsible_.AttrCaps


{-| See [`M3e.Element.Collapsible.SlotCaps`](M3e.Element.Collapsible#SlotCaps).
-}
type alias CollapsibleSlotCaps =
    Collapsible_.SlotCaps


{-| See [`M3e.Element.Collapsible.ChildAdmittedBy`](M3e.Element.Collapsible#ChildAdmittedBy).
-}
type alias CollapsibleChildAdmittedBy childAdm =
    Collapsible_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Collapsible.Orientation`](M3e.Element.Collapsible#Orientation).
-}
type alias CollapsibleOrientation =
    Collapsible_.Orientation


{-| See [`M3e.Element.Collapsible.orientation`](M3e.Element.Collapsible#orientation).
-}
collapsibleOrientation : Value CollapsibleOrientation -> Attr { c | orientation : Supported } msg
collapsibleOrientation =
    Collapsible_.orientation


{-| See [`M3e.Element.Collapsible.noAnimate`](M3e.Element.Collapsible#noAnimate).
-}
collapsibleNoAnimate : Bool -> Attr { c | noAnimate : Supported } msg
collapsibleNoAnimate =
    Collapsible_.noAnimate


{-| See [`M3e.Element.Collapsible.open`](M3e.Element.Collapsible#open).
-}
collapsibleOpen : Bool -> Attr { c | open : Supported } msg
collapsibleOpen =
    Collapsible_.open


{-| See [`M3e.Element.Collapsible.onOpening`](M3e.Element.Collapsible#onOpening).
-}
collapsibleOnOpening : msg -> Attr { c | onOpening : Supported } msg
collapsibleOnOpening =
    Collapsible_.onOpening


{-| See [`M3e.Element.Collapsible.onOpened`](M3e.Element.Collapsible#onOpened).
-}
collapsibleOnOpened : msg -> Attr { c | onOpened : Supported } msg
collapsibleOnOpened =
    Collapsible_.onOpened


{-| See [`M3e.Element.Collapsible.onClosing`](M3e.Element.Collapsible#onClosing).
-}
collapsibleOnClosing : msg -> Attr { c | onClosing : Supported } msg
collapsibleOnClosing =
    Collapsible_.onClosing


{-| See [`M3e.Element.Collapsible.onClosed`](M3e.Element.Collapsible#onClosed).
-}
collapsibleOnClosed : msg -> Attr { c | onClosed : Supported } msg
collapsibleOnClosed =
    Collapsible_.onClosed


{-| See [`M3e.Element.Collapsible.child`](M3e.Element.Collapsible#child).
-}
collapsibleChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
collapsibleChild =
    Collapsible_.child

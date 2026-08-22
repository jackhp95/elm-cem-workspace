module M3e.Component.Slide exposing (SlideIs, SlideAttrs, SlideBuilder, SlideAttrCaps, SlideSlotCaps, SlideChildAdmittedBy, slide, slideSelectedIndex, slideChild)

{-| The **Slide** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Slide`](M3e.Element.Slide) as `slide`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SlideIs, SlideAttrs, SlideBuilder, SlideAttrCaps, SlideSlotCaps, SlideChildAdmittedBy, slide, slideSelectedIndex, slideChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Slide as Slide_


{-| The `slide` element of this family — delegates to [`M3e.Element.Slide.component`](M3e.Element.Slide#component).
-}
slide :
    List (Attr SlideAttrs msg)
    -> List (Element childAccepts (SlideChildAdmittedBy childAdm) msg)
    -> Element (SlideIs s) admittedBy msg
slide =
    Slide_.component


{-| See [`M3e.Element.Slide.Is`](M3e.Element.Slide#Is).
-}
type alias SlideIs s =
    Slide_.Is s


{-| See [`M3e.Element.Slide.Attrs`](M3e.Element.Slide#Attrs).
-}
type alias SlideAttrs =
    Slide_.Attrs


{-| See [`M3e.Element.Slide.Builder`](M3e.Element.Slide#Builder).
-}
type alias SlideBuilder attrCaps slotCaps msg kind =
    Slide_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Slide.AttrCaps`](M3e.Element.Slide#AttrCaps).
-}
type alias SlideAttrCaps =
    Slide_.AttrCaps


{-| See [`M3e.Element.Slide.SlotCaps`](M3e.Element.Slide#SlotCaps).
-}
type alias SlideSlotCaps =
    Slide_.SlotCaps


{-| See [`M3e.Element.Slide.ChildAdmittedBy`](M3e.Element.Slide#ChildAdmittedBy).
-}
type alias SlideChildAdmittedBy childAdm =
    Slide_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Slide.selectedIndex`](M3e.Element.Slide#selectedIndex).
-}
slideSelectedIndex : Float -> Attr { c | selectedIndex : Supported } msg
slideSelectedIndex =
    Slide_.selectedIndex


{-| See [`M3e.Element.Slide.child`](M3e.Element.Slide#child).
-}
slideChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
slideChild =
    Slide_.child

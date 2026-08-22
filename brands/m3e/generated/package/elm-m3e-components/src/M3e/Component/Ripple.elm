module M3e.Component.Ripple exposing (RippleIs, RippleAttrs, RippleBuilder, RippleAttrCaps, RippleSlotCaps, RippleChildAdmittedBy, ripple, rippleCentered, rippleDisabled, rippleFor, rippleRadius, rippleUnbounded)

{-| The **Ripple** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Ripple`](M3e.Element.Ripple) as `ripple`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs RippleIs, RippleAttrs, RippleBuilder, RippleAttrCaps, RippleSlotCaps, RippleChildAdmittedBy, ripple, rippleCentered, rippleDisabled, rippleFor, rippleRadius, rippleUnbounded

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.Ripple as Ripple_


{-| The `ripple` element of this family — delegates to [`M3e.Element.Ripple.component`](M3e.Element.Ripple#component).
-}
ripple :
    List (Attr RippleAttrs msg)
    -> List (Element childAccepts (RippleChildAdmittedBy childAdm) msg)
    -> Element (RippleIs s) admittedBy msg
ripple =
    Ripple_.component


{-| See [`M3e.Element.Ripple.Is`](M3e.Element.Ripple#Is).
-}
type alias RippleIs s =
    Ripple_.Is s


{-| See [`M3e.Element.Ripple.Attrs`](M3e.Element.Ripple#Attrs).
-}
type alias RippleAttrs =
    Ripple_.Attrs


{-| See [`M3e.Element.Ripple.Builder`](M3e.Element.Ripple#Builder).
-}
type alias RippleBuilder attrCaps slotCaps msg kind =
    Ripple_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Ripple.AttrCaps`](M3e.Element.Ripple#AttrCaps).
-}
type alias RippleAttrCaps =
    Ripple_.AttrCaps


{-| See [`M3e.Element.Ripple.SlotCaps`](M3e.Element.Ripple#SlotCaps).
-}
type alias RippleSlotCaps =
    Ripple_.SlotCaps


{-| See [`M3e.Element.Ripple.ChildAdmittedBy`](M3e.Element.Ripple#ChildAdmittedBy).
-}
type alias RippleChildAdmittedBy childAdm =
    Ripple_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Ripple.centered`](M3e.Element.Ripple#centered).
-}
rippleCentered : Bool -> Attr { c | centered : Supported } msg
rippleCentered =
    Ripple_.centered


{-| See [`M3e.Element.Ripple.disabled`](M3e.Element.Ripple#disabled).
-}
rippleDisabled : Bool -> Attr { c | disabled : Supported } msg
rippleDisabled =
    Ripple_.disabled


{-| See [`M3e.Element.Ripple.for`](M3e.Element.Ripple#for).
-}
rippleFor : String -> Attr { c | for : Supported } msg
rippleFor =
    Ripple_.for


{-| See [`M3e.Element.Ripple.radius`](M3e.Element.Ripple#radius).
-}
rippleRadius : Float -> Attr { c | radius : Supported } msg
rippleRadius =
    Ripple_.radius


{-| See [`M3e.Element.Ripple.unbounded`](M3e.Element.Ripple#unbounded).
-}
rippleUnbounded : Bool -> Attr { c | unbounded : Supported } msg
rippleUnbounded =
    Ripple_.unbounded

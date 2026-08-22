module M3e.Component.StateLayer exposing (StateLayerIs, StateLayerAttrs, StateLayerBuilder, StateLayerAttrCaps, StateLayerSlotCaps, StateLayerChildAdmittedBy, stateLayer, stateLayerDisableHover, stateLayerDisabled, stateLayerEnablePressed, stateLayerFor)

{-| The **StateLayer** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.StateLayer`](M3e.Element.StateLayer) as `stateLayer`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs StateLayerIs, StateLayerAttrs, StateLayerBuilder, StateLayerAttrCaps, StateLayerSlotCaps, StateLayerChildAdmittedBy, stateLayer, stateLayerDisableHover, stateLayerDisabled, stateLayerEnablePressed, stateLayerFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.StateLayer as StateLayer_


{-| The `stateLayer` element of this family — delegates to [`M3e.Element.StateLayer.component`](M3e.Element.StateLayer#component).
-}
stateLayer :
    List (Attr StateLayerAttrs msg)
    -> List (Element childAccepts (StateLayerChildAdmittedBy childAdm) msg)
    -> Element (StateLayerIs s) admittedBy msg
stateLayer =
    StateLayer_.component


{-| See [`M3e.Element.StateLayer.Is`](M3e.Element.StateLayer#Is).
-}
type alias StateLayerIs s =
    StateLayer_.Is s


{-| See [`M3e.Element.StateLayer.Attrs`](M3e.Element.StateLayer#Attrs).
-}
type alias StateLayerAttrs =
    StateLayer_.Attrs


{-| See [`M3e.Element.StateLayer.Builder`](M3e.Element.StateLayer#Builder).
-}
type alias StateLayerBuilder attrCaps slotCaps msg kind =
    StateLayer_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.StateLayer.AttrCaps`](M3e.Element.StateLayer#AttrCaps).
-}
type alias StateLayerAttrCaps =
    StateLayer_.AttrCaps


{-| See [`M3e.Element.StateLayer.SlotCaps`](M3e.Element.StateLayer#SlotCaps).
-}
type alias StateLayerSlotCaps =
    StateLayer_.SlotCaps


{-| See [`M3e.Element.StateLayer.ChildAdmittedBy`](M3e.Element.StateLayer#ChildAdmittedBy).
-}
type alias StateLayerChildAdmittedBy childAdm =
    StateLayer_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.StateLayer.disableHover`](M3e.Element.StateLayer#disableHover).
-}
stateLayerDisableHover : Bool -> Attr { c | disableHover : Supported } msg
stateLayerDisableHover =
    StateLayer_.disableHover


{-| See [`M3e.Element.StateLayer.disabled`](M3e.Element.StateLayer#disabled).
-}
stateLayerDisabled : Bool -> Attr { c | disabled : Supported } msg
stateLayerDisabled =
    StateLayer_.disabled


{-| See [`M3e.Element.StateLayer.enablePressed`](M3e.Element.StateLayer#enablePressed).
-}
stateLayerEnablePressed : Bool -> Attr { c | enablePressed : Supported } msg
stateLayerEnablePressed =
    StateLayer_.enablePressed


{-| See [`M3e.Element.StateLayer.for`](M3e.Element.StateLayer#for).
-}
stateLayerFor : String -> Attr { c | for : Supported } msg
stateLayerFor =
    StateLayer_.for

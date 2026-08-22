module M3e.Component.Slider exposing (SliderIs, SliderAttrs, SliderBuilder, SliderAttrCaps, SliderSlotCaps, SliderChildAdmittedBy, SliderSize, slider, sliderSize, sliderDisabled, sliderDiscrete, sliderLabelled, sliderMax, sliderMin, sliderStep, sliderOnBeforeinput, sliderOnInput, sliderOnChange, sliderChild)

{-| The **Slider** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Slider`](M3e.Element.Slider) as `slider`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SliderIs, SliderAttrs, SliderBuilder, SliderAttrCaps, SliderSlotCaps, SliderChildAdmittedBy, SliderSize, slider, sliderSize, sliderDisabled, sliderDiscrete, sliderLabelled, sliderMax, sliderMin, sliderStep, sliderOnBeforeinput, sliderOnInput, sliderOnChange, sliderChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Slider as Slider_


{-| The `slider` element of this family — delegates to [`M3e.Element.Slider.component`](M3e.Element.Slider#component).
-}
slider :
    { content : Element childAccepts (SliderChildAdmittedBy childAdm) msg }
    -> List (Attr SliderAttrs msg)
    -> List (Element childAccepts (SliderChildAdmittedBy childAdm) msg)
    -> Element (SliderIs s) admittedBy msg
slider =
    Slider_.component


{-| See [`M3e.Element.Slider.Is`](M3e.Element.Slider#Is).
-}
type alias SliderIs s =
    Slider_.Is s


{-| See [`M3e.Element.Slider.Attrs`](M3e.Element.Slider#Attrs).
-}
type alias SliderAttrs =
    Slider_.Attrs


{-| See [`M3e.Element.Slider.Builder`](M3e.Element.Slider#Builder).
-}
type alias SliderBuilder attrCaps slotCaps msg kind =
    Slider_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Slider.AttrCaps`](M3e.Element.Slider#AttrCaps).
-}
type alias SliderAttrCaps =
    Slider_.AttrCaps


{-| See [`M3e.Element.Slider.SlotCaps`](M3e.Element.Slider#SlotCaps).
-}
type alias SliderSlotCaps =
    Slider_.SlotCaps


{-| See [`M3e.Element.Slider.ChildAdmittedBy`](M3e.Element.Slider#ChildAdmittedBy).
-}
type alias SliderChildAdmittedBy childAdm =
    Slider_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Slider.Size`](M3e.Element.Slider#Size).
-}
type alias SliderSize =
    Slider_.Size


{-| See [`M3e.Element.Slider.size`](M3e.Element.Slider#size).
-}
sliderSize : Value SliderSize -> Attr { c | size : Supported } msg
sliderSize =
    Slider_.size


{-| See [`M3e.Element.Slider.disabled`](M3e.Element.Slider#disabled).
-}
sliderDisabled : Bool -> Attr { c | disabled : Supported } msg
sliderDisabled =
    Slider_.disabled


{-| See [`M3e.Element.Slider.discrete`](M3e.Element.Slider#discrete).
-}
sliderDiscrete : Bool -> Attr { c | discrete : Supported } msg
sliderDiscrete =
    Slider_.discrete


{-| See [`M3e.Element.Slider.labelled`](M3e.Element.Slider#labelled).
-}
sliderLabelled : Bool -> Attr { c | labelled : Supported } msg
sliderLabelled =
    Slider_.labelled


{-| See [`M3e.Element.Slider.max`](M3e.Element.Slider#max).
-}
sliderMax : Float -> Attr { c | max : Supported } msg
sliderMax =
    Slider_.max


{-| See [`M3e.Element.Slider.min`](M3e.Element.Slider#min).
-}
sliderMin : Float -> Attr { c | min : Supported } msg
sliderMin =
    Slider_.min


{-| See [`M3e.Element.Slider.step`](M3e.Element.Slider#step).
-}
sliderStep : Float -> Attr { c | step : Supported } msg
sliderStep =
    Slider_.step


{-| See [`M3e.Element.Slider.onBeforeinput`](M3e.Element.Slider#onBeforeinput).
-}
sliderOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
sliderOnBeforeinput =
    Slider_.onBeforeinput


{-| See [`M3e.Element.Slider.onInput`](M3e.Element.Slider#onInput).
-}
sliderOnInput : msg -> Attr { c | onInput : Supported } msg
sliderOnInput =
    Slider_.onInput


{-| See [`M3e.Element.Slider.onChange`](M3e.Element.Slider#onChange).
-}
sliderOnChange : msg -> Attr { c | onChange : Supported } msg
sliderOnChange =
    Slider_.onChange


{-| See [`M3e.Element.Slider.child`](M3e.Element.Slider#child).
-}
sliderChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
sliderChild =
    Slider_.child

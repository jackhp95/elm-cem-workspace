module M3e.Component.SliderThumb exposing (SliderThumbIs, SliderThumbAttrs, SliderThumbBuilder, SliderThumbAttrCaps, SliderThumbSlotCaps, SliderThumbChildAdmittedBy, sliderThumb, sliderThumbDisabled, sliderThumbName, sliderThumbValue, sliderThumbDefaultValue, sliderThumbOnValueChange, sliderThumbOnBeforeinput, sliderThumbOnInput, sliderThumbOnChange, sliderThumbOnClick)

{-| The **SliderThumb** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SliderThumb`](M3e.Element.SliderThumb) as `sliderThumb`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SliderThumbIs, SliderThumbAttrs, SliderThumbBuilder, SliderThumbAttrCaps, SliderThumbSlotCaps, SliderThumbChildAdmittedBy, sliderThumb, sliderThumbDisabled, sliderThumbName, sliderThumbValue, sliderThumbDefaultValue, sliderThumbOnValueChange, sliderThumbOnBeforeinput, sliderThumbOnInput, sliderThumbOnChange, sliderThumbOnClick

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.SliderThumb as SliderThumb_


{-| The `sliderThumb` element of this family — delegates to [`M3e.Element.SliderThumb.component`](M3e.Element.SliderThumb#component).
-}
sliderThumb :
    List (Attr SliderThumbAttrs msg)
    -> List (Element childAccepts (SliderThumbChildAdmittedBy childAdm) msg)
    -> Element (SliderThumbIs s) admittedBy msg
sliderThumb =
    SliderThumb_.component


{-| See [`M3e.Element.SliderThumb.Is`](M3e.Element.SliderThumb#Is).
-}
type alias SliderThumbIs s =
    SliderThumb_.Is s


{-| See [`M3e.Element.SliderThumb.Attrs`](M3e.Element.SliderThumb#Attrs).
-}
type alias SliderThumbAttrs =
    SliderThumb_.Attrs


{-| See [`M3e.Element.SliderThumb.Builder`](M3e.Element.SliderThumb#Builder).
-}
type alias SliderThumbBuilder attrCaps slotCaps msg kind =
    SliderThumb_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SliderThumb.AttrCaps`](M3e.Element.SliderThumb#AttrCaps).
-}
type alias SliderThumbAttrCaps =
    SliderThumb_.AttrCaps


{-| See [`M3e.Element.SliderThumb.SlotCaps`](M3e.Element.SliderThumb#SlotCaps).
-}
type alias SliderThumbSlotCaps =
    SliderThumb_.SlotCaps


{-| See [`M3e.Element.SliderThumb.ChildAdmittedBy`](M3e.Element.SliderThumb#ChildAdmittedBy).
-}
type alias SliderThumbChildAdmittedBy childAdm =
    SliderThumb_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SliderThumb.disabled`](M3e.Element.SliderThumb#disabled).
-}
sliderThumbDisabled : Bool -> Attr { c | disabled : Supported } msg
sliderThumbDisabled =
    SliderThumb_.disabled


{-| See [`M3e.Element.SliderThumb.name`](M3e.Element.SliderThumb#name).
-}
sliderThumbName : String -> Attr { c | name : Supported } msg
sliderThumbName =
    SliderThumb_.name


{-| See [`M3e.Element.SliderThumb.value`](M3e.Element.SliderThumb#value).
-}
sliderThumbValue : Float -> Attr { c | value : Supported } msg
sliderThumbValue =
    SliderThumb_.value


{-| See [`M3e.Element.SliderThumb.defaultValue`](M3e.Element.SliderThumb#defaultValue).
-}
sliderThumbDefaultValue : Float -> Attr { c | value : Supported } msg
sliderThumbDefaultValue =
    SliderThumb_.defaultValue


{-| See [`M3e.Element.SliderThumb.onValueChange`](M3e.Element.SliderThumb#onValueChange).
-}
sliderThumbOnValueChange : msg -> Attr { c | onValueChange : Supported } msg
sliderThumbOnValueChange =
    SliderThumb_.onValueChange


{-| See [`M3e.Element.SliderThumb.onBeforeinput`](M3e.Element.SliderThumb#onBeforeinput).
-}
sliderThumbOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
sliderThumbOnBeforeinput =
    SliderThumb_.onBeforeinput


{-| See [`M3e.Element.SliderThumb.onInput`](M3e.Element.SliderThumb#onInput).
-}
sliderThumbOnInput : msg -> Attr { c | onInput : Supported } msg
sliderThumbOnInput =
    SliderThumb_.onInput


{-| See [`M3e.Element.SliderThumb.onChange`](M3e.Element.SliderThumb#onChange).
-}
sliderThumbOnChange : msg -> Attr { c | onChange : Supported } msg
sliderThumbOnChange =
    SliderThumb_.onChange


{-| See [`M3e.Element.SliderThumb.onClick`](M3e.Element.SliderThumb#onClick).
-}
sliderThumbOnClick : msg -> Attr { c | onClick : Supported } msg
sliderThumbOnClick =
    SliderThumb_.onClick

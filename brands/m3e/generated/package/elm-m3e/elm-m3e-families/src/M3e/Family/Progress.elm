module M3e.Family.Progress exposing (CircularIs, CircularAttrs, CircularBuilder, CircularAttrCaps, CircularSlotCaps, CircularChildAdmittedBy, CircularVariant, LinearIs, LinearAttrs, LinearBuilder, LinearAttrCaps, LinearSlotCaps, LinearChildAdmittedBy, LinearMode, LinearVariant, LoadingIs, LoadingAttrs, LoadingBuilder, LoadingAttrCaps, LoadingSlotCaps, LoadingChildAdmittedBy, LoadingVariant, circular, circularVariant, circularIndeterminate, circularMax, circularValue, circularDefaultValue, circularChild, linear, linearMode, linearVariant, linearBufferValue, linearMax, linearValue, linearDefaultValue, loading, loadingVariant)

{-| The **Progress** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.CircularProgressIndicator`](M3e.Component.CircularProgressIndicator) as `circular`, [`M3e.Component.LinearProgressIndicator`](M3e.Component.LinearProgressIndicator) as `linear`, [`M3e.Component.LoadingIndicator`](M3e.Component.LoadingIndicator) as `loading`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs CircularIs, CircularAttrs, CircularBuilder, CircularAttrCaps, CircularSlotCaps, CircularChildAdmittedBy, CircularVariant, LinearIs, LinearAttrs, LinearBuilder, LinearAttrCaps, LinearSlotCaps, LinearChildAdmittedBy, LinearMode, LinearVariant, LoadingIs, LoadingAttrs, LoadingBuilder, LoadingAttrCaps, LoadingSlotCaps, LoadingChildAdmittedBy, LoadingVariant, circular, circularVariant, circularIndeterminate, circularMax, circularValue, circularDefaultValue, circularChild, linear, linearMode, linearVariant, linearBufferValue, linearMax, linearValue, linearDefaultValue, loading, loadingVariant

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.CircularProgressIndicator as Circular_
import M3e.Component.LinearProgressIndicator as Linear_
import M3e.Component.LoadingIndicator as Loading_


{-| The `circular` element of this family — delegates to [`M3e.Component.CircularProgressIndicator.component`](M3e.Component.CircularProgressIndicator#component).
-}
circular :
    List (Attr CircularAttrs msg)
    -> List (Element childAccepts (CircularChildAdmittedBy childAdm) msg)
    -> Element (CircularIs s) admittedBy msg
circular =
    Circular_.component


{-| See [`M3e.Component.CircularProgressIndicator.Is`](M3e.Component.CircularProgressIndicator#Is).
-}
type alias CircularIs s =
    Circular_.Is s


{-| See [`M3e.Component.CircularProgressIndicator.Attrs`](M3e.Component.CircularProgressIndicator#Attrs).
-}
type alias CircularAttrs =
    Circular_.Attrs


{-| See [`M3e.Component.CircularProgressIndicator.Builder`](M3e.Component.CircularProgressIndicator#Builder).
-}
type alias CircularBuilder attrCaps slotCaps msg kind =
    Circular_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.CircularProgressIndicator.AttrCaps`](M3e.Component.CircularProgressIndicator#AttrCaps).
-}
type alias CircularAttrCaps =
    Circular_.AttrCaps


{-| See [`M3e.Component.CircularProgressIndicator.SlotCaps`](M3e.Component.CircularProgressIndicator#SlotCaps).
-}
type alias CircularSlotCaps =
    Circular_.SlotCaps


{-| See [`M3e.Component.CircularProgressIndicator.ChildAdmittedBy`](M3e.Component.CircularProgressIndicator#ChildAdmittedBy).
-}
type alias CircularChildAdmittedBy childAdm =
    Circular_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.CircularProgressIndicator.Variant`](M3e.Component.CircularProgressIndicator#Variant).
-}
type alias CircularVariant =
    Circular_.Variant


{-| See [`M3e.Component.CircularProgressIndicator.variant`](M3e.Component.CircularProgressIndicator#variant).
-}
circularVariant : Value CircularVariant -> Attr { c | variant : Supported } msg
circularVariant =
    Circular_.variant


{-| See [`M3e.Component.CircularProgressIndicator.indeterminate`](M3e.Component.CircularProgressIndicator#indeterminate).
-}
circularIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
circularIndeterminate =
    Circular_.indeterminate


{-| See [`M3e.Component.CircularProgressIndicator.max`](M3e.Component.CircularProgressIndicator#max).
-}
circularMax : Float -> Attr { c | max : Supported } msg
circularMax =
    Circular_.max


{-| See [`M3e.Component.CircularProgressIndicator.value`](M3e.Component.CircularProgressIndicator#value).
-}
circularValue : Float -> Attr { c | value : Supported } msg
circularValue =
    Circular_.value


{-| See [`M3e.Component.CircularProgressIndicator.defaultValue`](M3e.Component.CircularProgressIndicator#defaultValue).
-}
circularDefaultValue : Float -> Attr { c | value : Supported } msg
circularDefaultValue =
    Circular_.defaultValue


{-| See [`M3e.Component.CircularProgressIndicator.child`](M3e.Component.CircularProgressIndicator#child).
-}
circularChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
circularChild =
    Circular_.child


{-| The `linear` element of this family — delegates to [`M3e.Component.LinearProgressIndicator.component`](M3e.Component.LinearProgressIndicator#component).
-}
linear :
    List (Attr LinearAttrs msg)
    -> List (Element childAccepts (LinearChildAdmittedBy childAdm) msg)
    -> Element (LinearIs s) admittedBy msg
linear =
    Linear_.component


{-| See [`M3e.Component.LinearProgressIndicator.Is`](M3e.Component.LinearProgressIndicator#Is).
-}
type alias LinearIs s =
    Linear_.Is s


{-| See [`M3e.Component.LinearProgressIndicator.Attrs`](M3e.Component.LinearProgressIndicator#Attrs).
-}
type alias LinearAttrs =
    Linear_.Attrs


{-| See [`M3e.Component.LinearProgressIndicator.Builder`](M3e.Component.LinearProgressIndicator#Builder).
-}
type alias LinearBuilder attrCaps slotCaps msg kind =
    Linear_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.LinearProgressIndicator.AttrCaps`](M3e.Component.LinearProgressIndicator#AttrCaps).
-}
type alias LinearAttrCaps =
    Linear_.AttrCaps


{-| See [`M3e.Component.LinearProgressIndicator.SlotCaps`](M3e.Component.LinearProgressIndicator#SlotCaps).
-}
type alias LinearSlotCaps =
    Linear_.SlotCaps


{-| See [`M3e.Component.LinearProgressIndicator.ChildAdmittedBy`](M3e.Component.LinearProgressIndicator#ChildAdmittedBy).
-}
type alias LinearChildAdmittedBy childAdm =
    Linear_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.LinearProgressIndicator.Mode`](M3e.Component.LinearProgressIndicator#Mode).
-}
type alias LinearMode =
    Linear_.Mode


{-| See [`M3e.Component.LinearProgressIndicator.mode`](M3e.Component.LinearProgressIndicator#mode).
-}
linearMode : Value LinearMode -> Attr { c | mode : Supported } msg
linearMode =
    Linear_.mode


{-| See [`M3e.Component.LinearProgressIndicator.Variant`](M3e.Component.LinearProgressIndicator#Variant).
-}
type alias LinearVariant =
    Linear_.Variant


{-| See [`M3e.Component.LinearProgressIndicator.variant`](M3e.Component.LinearProgressIndicator#variant).
-}
linearVariant : Value LinearVariant -> Attr { c | variant : Supported } msg
linearVariant =
    Linear_.variant


{-| See [`M3e.Component.LinearProgressIndicator.bufferValue`](M3e.Component.LinearProgressIndicator#bufferValue).
-}
linearBufferValue : Float -> Attr { c | bufferValue : Supported } msg
linearBufferValue =
    Linear_.bufferValue


{-| See [`M3e.Component.LinearProgressIndicator.max`](M3e.Component.LinearProgressIndicator#max).
-}
linearMax : Float -> Attr { c | max : Supported } msg
linearMax =
    Linear_.max


{-| See [`M3e.Component.LinearProgressIndicator.value`](M3e.Component.LinearProgressIndicator#value).
-}
linearValue : Float -> Attr { c | value : Supported } msg
linearValue =
    Linear_.value


{-| See [`M3e.Component.LinearProgressIndicator.defaultValue`](M3e.Component.LinearProgressIndicator#defaultValue).
-}
linearDefaultValue : Float -> Attr { c | value : Supported } msg
linearDefaultValue =
    Linear_.defaultValue


{-| The `loading` element of this family — delegates to [`M3e.Component.LoadingIndicator.component`](M3e.Component.LoadingIndicator#component).
-}
loading :
    List (Attr LoadingAttrs msg)
    -> List (Element childAccepts (LoadingChildAdmittedBy childAdm) msg)
    -> Element (LoadingIs s) admittedBy msg
loading =
    Loading_.component


{-| See [`M3e.Component.LoadingIndicator.Is`](M3e.Component.LoadingIndicator#Is).
-}
type alias LoadingIs s =
    Loading_.Is s


{-| See [`M3e.Component.LoadingIndicator.Attrs`](M3e.Component.LoadingIndicator#Attrs).
-}
type alias LoadingAttrs =
    Loading_.Attrs


{-| See [`M3e.Component.LoadingIndicator.Builder`](M3e.Component.LoadingIndicator#Builder).
-}
type alias LoadingBuilder attrCaps slotCaps msg kind =
    Loading_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.LoadingIndicator.AttrCaps`](M3e.Component.LoadingIndicator#AttrCaps).
-}
type alias LoadingAttrCaps =
    Loading_.AttrCaps


{-| See [`M3e.Component.LoadingIndicator.SlotCaps`](M3e.Component.LoadingIndicator#SlotCaps).
-}
type alias LoadingSlotCaps =
    Loading_.SlotCaps


{-| See [`M3e.Component.LoadingIndicator.ChildAdmittedBy`](M3e.Component.LoadingIndicator#ChildAdmittedBy).
-}
type alias LoadingChildAdmittedBy childAdm =
    Loading_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.LoadingIndicator.Variant`](M3e.Component.LoadingIndicator#Variant).
-}
type alias LoadingVariant =
    Loading_.Variant


{-| See [`M3e.Component.LoadingIndicator.variant`](M3e.Component.LoadingIndicator#variant).
-}
loadingVariant : Value LoadingVariant -> Attr { c | variant : Supported } msg
loadingVariant =
    Loading_.variant

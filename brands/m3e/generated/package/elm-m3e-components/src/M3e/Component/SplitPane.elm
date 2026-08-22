module M3e.Component.SplitPane exposing (SplitPaneIs, SplitPaneAttrs, SplitPaneBuilder, SplitPaneAttrCaps, SplitPaneSlotCaps, SplitPaneChildAdmittedBy, SplitPaneOrientation, splitPane, splitPaneOrientation, splitPaneDetents, splitPaneDisabled, splitPaneLabel, splitPaneMax, splitPaneMin, splitPaneName, splitPaneOvershootLimit, splitPaneStep, splitPaneValue, splitPaneWrapDetents, splitPaneDefaultValue, splitPaneOnChange, splitPaneOnBeforeinput, splitPaneOnInput, splitPaneEnd, splitPaneStart)

{-| The **SplitPane** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SplitPane`](M3e.Element.SplitPane) as `splitPane`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SplitPaneIs, SplitPaneAttrs, SplitPaneBuilder, SplitPaneAttrCaps, SplitPaneSlotCaps, SplitPaneChildAdmittedBy, SplitPaneOrientation, splitPane, splitPaneOrientation, splitPaneDetents, splitPaneDisabled, splitPaneLabel, splitPaneMax, splitPaneMin, splitPaneName, splitPaneOvershootLimit, splitPaneStep, splitPaneValue, splitPaneWrapDetents, splitPaneDefaultValue, splitPaneOnChange, splitPaneOnBeforeinput, splitPaneOnInput, splitPaneEnd, splitPaneStart

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.SplitPane as SplitPane_


{-| The `splitPane` element of this family — delegates to [`M3e.Element.SplitPane.component`](M3e.Element.SplitPane#component).
-}
splitPane :
    { end : Element childAccepts (SplitPaneChildAdmittedBy childAdm) msg
    , start : Element childAccepts (SplitPaneChildAdmittedBy childAdm) msg
    }
    -> List (Attr SplitPaneAttrs msg)
    -> List (Element childAccepts (SplitPaneChildAdmittedBy childAdm) msg)
    -> Element (SplitPaneIs s) admittedBy msg
splitPane =
    SplitPane_.component


{-| See [`M3e.Element.SplitPane.Is`](M3e.Element.SplitPane#Is).
-}
type alias SplitPaneIs s =
    SplitPane_.Is s


{-| See [`M3e.Element.SplitPane.Attrs`](M3e.Element.SplitPane#Attrs).
-}
type alias SplitPaneAttrs =
    SplitPane_.Attrs


{-| See [`M3e.Element.SplitPane.Builder`](M3e.Element.SplitPane#Builder).
-}
type alias SplitPaneBuilder attrCaps slotCaps msg kind =
    SplitPane_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SplitPane.AttrCaps`](M3e.Element.SplitPane#AttrCaps).
-}
type alias SplitPaneAttrCaps =
    SplitPane_.AttrCaps


{-| See [`M3e.Element.SplitPane.SlotCaps`](M3e.Element.SplitPane#SlotCaps).
-}
type alias SplitPaneSlotCaps =
    SplitPane_.SlotCaps


{-| See [`M3e.Element.SplitPane.ChildAdmittedBy`](M3e.Element.SplitPane#ChildAdmittedBy).
-}
type alias SplitPaneChildAdmittedBy childAdm =
    SplitPane_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SplitPane.Orientation`](M3e.Element.SplitPane#Orientation).
-}
type alias SplitPaneOrientation =
    SplitPane_.Orientation


{-| See [`M3e.Element.SplitPane.orientation`](M3e.Element.SplitPane#orientation).
-}
splitPaneOrientation : Value SplitPaneOrientation -> Attr { c | orientation : Supported } msg
splitPaneOrientation =
    SplitPane_.orientation


{-| See [`M3e.Element.SplitPane.detents`](M3e.Element.SplitPane#detents).
-}
splitPaneDetents : String -> Attr { c | detents : Supported } msg
splitPaneDetents =
    SplitPane_.detents


{-| See [`M3e.Element.SplitPane.disabled`](M3e.Element.SplitPane#disabled).
-}
splitPaneDisabled : Bool -> Attr { c | disabled : Supported } msg
splitPaneDisabled =
    SplitPane_.disabled


{-| See [`M3e.Element.SplitPane.label`](M3e.Element.SplitPane#label).
-}
splitPaneLabel : String -> Attr { c | label : Supported } msg
splitPaneLabel =
    SplitPane_.label


{-| See [`M3e.Element.SplitPane.max`](M3e.Element.SplitPane#max).
-}
splitPaneMax : Float -> Attr { c | max : Supported } msg
splitPaneMax =
    SplitPane_.max


{-| See [`M3e.Element.SplitPane.min`](M3e.Element.SplitPane#min).
-}
splitPaneMin : Float -> Attr { c | min : Supported } msg
splitPaneMin =
    SplitPane_.min


{-| See [`M3e.Element.SplitPane.name`](M3e.Element.SplitPane#name).
-}
splitPaneName : String -> Attr { c | name : Supported } msg
splitPaneName =
    SplitPane_.name


{-| See [`M3e.Element.SplitPane.overshootLimit`](M3e.Element.SplitPane#overshootLimit).
-}
splitPaneOvershootLimit : Float -> Attr { c | overshootLimit : Supported } msg
splitPaneOvershootLimit =
    SplitPane_.overshootLimit


{-| See [`M3e.Element.SplitPane.step`](M3e.Element.SplitPane#step).
-}
splitPaneStep : Float -> Attr { c | step : Supported } msg
splitPaneStep =
    SplitPane_.step


{-| See [`M3e.Element.SplitPane.value`](M3e.Element.SplitPane#value).
-}
splitPaneValue : Float -> Attr { c | value : Supported } msg
splitPaneValue =
    SplitPane_.value


{-| See [`M3e.Element.SplitPane.wrapDetents`](M3e.Element.SplitPane#wrapDetents).
-}
splitPaneWrapDetents : Bool -> Attr { c | wrapDetents : Supported } msg
splitPaneWrapDetents =
    SplitPane_.wrapDetents


{-| See [`M3e.Element.SplitPane.defaultValue`](M3e.Element.SplitPane#defaultValue).
-}
splitPaneDefaultValue : Float -> Attr { c | value : Supported } msg
splitPaneDefaultValue =
    SplitPane_.defaultValue


{-| See [`M3e.Element.SplitPane.onChange`](M3e.Element.SplitPane#onChange).
-}
splitPaneOnChange : msg -> Attr { c | onChange : Supported } msg
splitPaneOnChange =
    SplitPane_.onChange


{-| See [`M3e.Element.SplitPane.onBeforeinput`](M3e.Element.SplitPane#onBeforeinput).
-}
splitPaneOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
splitPaneOnBeforeinput =
    SplitPane_.onBeforeinput


{-| See [`M3e.Element.SplitPane.onInput`](M3e.Element.SplitPane#onInput).
-}
splitPaneOnInput : msg -> Attr { c | onInput : Supported } msg
splitPaneOnInput =
    SplitPane_.onInput


{-| See [`M3e.Element.SplitPane.end`](M3e.Element.SplitPane#end).
-}
splitPaneEnd : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
splitPaneEnd =
    SplitPane_.end


{-| See [`M3e.Element.SplitPane.start`](M3e.Element.SplitPane#start).
-}
splitPaneStart : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
splitPaneStart =
    SplitPane_.start

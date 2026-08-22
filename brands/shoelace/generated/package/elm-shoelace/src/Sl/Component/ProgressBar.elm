module Sl.Component.ProgressBar exposing (ProgressBarIs, ProgressBarAttrs, ProgressBarBuilder, ProgressBarAttrCaps, ProgressBarSlotCaps, ProgressBarChildAdmittedBy, progressBar, progressBarIndeterminate, progressBarLabel, progressBarValue, progressBarDefaultValue)

{-| The **ProgressBar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.ProgressBar`](Sl.Element.ProgressBar) as `progressBar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ProgressBarIs, ProgressBarAttrs, ProgressBarBuilder, ProgressBarAttrCaps, ProgressBarSlotCaps, ProgressBarChildAdmittedBy, progressBar, progressBarIndeterminate, progressBarLabel, progressBarValue, progressBarDefaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.ProgressBar as ProgressBar_


{-| The `progressBar` element of this family — delegates to [`Sl.Element.ProgressBar.component`](Sl.Element.ProgressBar#component).
-}
progressBar :
    List (Attr ProgressBarAttrs msg)
    -> List (Element childAccepts (ProgressBarChildAdmittedBy childAdm) msg)
    -> Element (ProgressBarIs s) admittedBy msg
progressBar =
    ProgressBar_.component


{-| See [`Sl.Element.ProgressBar.Is`](Sl.Element.ProgressBar#Is).
-}
type alias ProgressBarIs s =
    ProgressBar_.Is s


{-| See [`Sl.Element.ProgressBar.Attrs`](Sl.Element.ProgressBar#Attrs).
-}
type alias ProgressBarAttrs =
    ProgressBar_.Attrs


{-| See [`Sl.Element.ProgressBar.Builder`](Sl.Element.ProgressBar#Builder).
-}
type alias ProgressBarBuilder attrCaps slotCaps msg kind =
    ProgressBar_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.ProgressBar.AttrCaps`](Sl.Element.ProgressBar#AttrCaps).
-}
type alias ProgressBarAttrCaps =
    ProgressBar_.AttrCaps


{-| See [`Sl.Element.ProgressBar.SlotCaps`](Sl.Element.ProgressBar#SlotCaps).
-}
type alias ProgressBarSlotCaps =
    ProgressBar_.SlotCaps


{-| See [`Sl.Element.ProgressBar.ChildAdmittedBy`](Sl.Element.ProgressBar#ChildAdmittedBy).
-}
type alias ProgressBarChildAdmittedBy childAdm =
    ProgressBar_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.ProgressBar.indeterminate`](Sl.Element.ProgressBar#indeterminate).
-}
progressBarIndeterminate : Bool -> Attr { c | indeterminate : Supported } msg
progressBarIndeterminate =
    ProgressBar_.indeterminate


{-| See [`Sl.Element.ProgressBar.label`](Sl.Element.ProgressBar#label).
-}
progressBarLabel : String -> Attr { c | label : Supported } msg
progressBarLabel =
    ProgressBar_.label


{-| See [`Sl.Element.ProgressBar.value`](Sl.Element.ProgressBar#value).
-}
progressBarValue : Float -> Attr { c | value : Supported } msg
progressBarValue =
    ProgressBar_.value


{-| See [`Sl.Element.ProgressBar.defaultValue`](Sl.Element.ProgressBar#defaultValue).
-}
progressBarDefaultValue : Float -> Attr { c | value : Supported } msg
progressBarDefaultValue =
    ProgressBar_.defaultValue

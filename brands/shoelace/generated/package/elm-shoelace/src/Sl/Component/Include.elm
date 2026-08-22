module Sl.Component.Include exposing (IncludeIs, IncludeAttrs, IncludeBuilder, IncludeAttrCaps, IncludeSlotCaps, IncludeChildAdmittedBy, IncludeMode, include, includeMode, includeAllowScripts, includeSrc, includeOnLoad, includeOnError)

{-| The **Include** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Include`](Sl.Element.Include) as `include`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs IncludeIs, IncludeAttrs, IncludeBuilder, IncludeAttrCaps, IncludeSlotCaps, IncludeChildAdmittedBy, IncludeMode, include, includeMode, includeAllowScripts, includeSrc, includeOnLoad, includeOnError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Include as Include_


{-| The `include` element of this family — delegates to [`Sl.Element.Include.component`](Sl.Element.Include#component).
-}
include :
    List (Attr IncludeAttrs msg)
    -> List (Element childAccepts (IncludeChildAdmittedBy childAdm) msg)
    -> Element (IncludeIs s) admittedBy msg
include =
    Include_.component


{-| See [`Sl.Element.Include.Is`](Sl.Element.Include#Is).
-}
type alias IncludeIs s =
    Include_.Is s


{-| See [`Sl.Element.Include.Attrs`](Sl.Element.Include#Attrs).
-}
type alias IncludeAttrs =
    Include_.Attrs


{-| See [`Sl.Element.Include.Builder`](Sl.Element.Include#Builder).
-}
type alias IncludeBuilder attrCaps slotCaps msg kind =
    Include_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Include.AttrCaps`](Sl.Element.Include#AttrCaps).
-}
type alias IncludeAttrCaps =
    Include_.AttrCaps


{-| See [`Sl.Element.Include.SlotCaps`](Sl.Element.Include#SlotCaps).
-}
type alias IncludeSlotCaps =
    Include_.SlotCaps


{-| See [`Sl.Element.Include.ChildAdmittedBy`](Sl.Element.Include#ChildAdmittedBy).
-}
type alias IncludeChildAdmittedBy childAdm =
    Include_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Include.Mode`](Sl.Element.Include#Mode).
-}
type alias IncludeMode =
    Include_.Mode


{-| See [`Sl.Element.Include.mode`](Sl.Element.Include#mode).
-}
includeMode : Value IncludeMode -> Attr { c | mode : Supported } msg
includeMode =
    Include_.mode


{-| See [`Sl.Element.Include.allowScripts`](Sl.Element.Include#allowScripts).
-}
includeAllowScripts : Bool -> Attr { c | allowScripts : Supported } msg
includeAllowScripts =
    Include_.allowScripts


{-| See [`Sl.Element.Include.src`](Sl.Element.Include#src).
-}
includeSrc : String -> Attr { c | src : Supported } msg
includeSrc =
    Include_.src


{-| See [`Sl.Element.Include.onLoad`](Sl.Element.Include#onLoad).
-}
includeOnLoad : msg -> Attr { c | onLoad : Supported } msg
includeOnLoad =
    Include_.onLoad


{-| See [`Sl.Element.Include.onError`](Sl.Element.Include#onError).
-}
includeOnError : msg -> Attr { c | onError : Supported } msg
includeOnError =
    Include_.onError

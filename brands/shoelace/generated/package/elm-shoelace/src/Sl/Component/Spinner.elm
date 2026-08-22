module Sl.Component.Spinner exposing (SpinnerIs, SpinnerAttrs, SpinnerBuilder, SpinnerAttrCaps, SpinnerSlotCaps, SpinnerChildAdmittedBy, spinner)

{-| The **Spinner** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Spinner`](Sl.Element.Spinner) as `spinner`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SpinnerIs, SpinnerAttrs, SpinnerBuilder, SpinnerAttrCaps, SpinnerSlotCaps, SpinnerChildAdmittedBy, spinner

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Sl.Element.Spinner as Spinner_


{-| The `spinner` element of this family — delegates to [`Sl.Element.Spinner.component`](Sl.Element.Spinner#component).
-}
spinner :
    List (Attr SpinnerAttrs msg)
    -> List (Element childAccepts (SpinnerChildAdmittedBy childAdm) msg)
    -> Element (SpinnerIs s) admittedBy msg
spinner =
    Spinner_.component


{-| See [`Sl.Element.Spinner.Is`](Sl.Element.Spinner#Is).
-}
type alias SpinnerIs s =
    Spinner_.Is s


{-| See [`Sl.Element.Spinner.Attrs`](Sl.Element.Spinner#Attrs).
-}
type alias SpinnerAttrs =
    Spinner_.Attrs


{-| See [`Sl.Element.Spinner.Builder`](Sl.Element.Spinner#Builder).
-}
type alias SpinnerBuilder attrCaps slotCaps msg kind =
    Spinner_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Spinner.AttrCaps`](Sl.Element.Spinner#AttrCaps).
-}
type alias SpinnerAttrCaps =
    Spinner_.AttrCaps


{-| See [`Sl.Element.Spinner.SlotCaps`](Sl.Element.Spinner#SlotCaps).
-}
type alias SpinnerSlotCaps =
    Spinner_.SlotCaps


{-| See [`Sl.Element.Spinner.ChildAdmittedBy`](Sl.Element.Spinner#ChildAdmittedBy).
-}
type alias SpinnerChildAdmittedBy childAdm =
    Spinner_.ChildAdmittedBy childAdm

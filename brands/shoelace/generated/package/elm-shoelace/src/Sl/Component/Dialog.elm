module Sl.Component.Dialog exposing (DialogIs, DialogAttrs, DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogChildAdmittedBy, dialog, dialogLabel, dialogNoHeader, dialogOpen, dialogOnShow, dialogOnAfterShow, dialogOnHide, dialogOnAfterHide, dialogOnInitialFocus, dialogOnRequestClose)

{-| The **Dialog** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Dialog`](Sl.Element.Dialog) as `dialog`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs DialogIs, DialogAttrs, DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogChildAdmittedBy, dialog, dialogLabel, dialogNoHeader, dialogOpen, dialogOnShow, dialogOnAfterShow, dialogOnHide, dialogOnAfterHide, dialogOnInitialFocus, dialogOnRequestClose

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Dialog as Dialog_


{-| The `dialog` element of this family — delegates to [`Sl.Element.Dialog.component`](Sl.Element.Dialog#component).
-}
dialog :
    List (Attr DialogAttrs msg)
    -> List (Element childAccepts (DialogChildAdmittedBy childAdm) msg)
    -> Element (DialogIs s) admittedBy msg
dialog =
    Dialog_.component


{-| See [`Sl.Element.Dialog.Is`](Sl.Element.Dialog#Is).
-}
type alias DialogIs s =
    Dialog_.Is s


{-| See [`Sl.Element.Dialog.Attrs`](Sl.Element.Dialog#Attrs).
-}
type alias DialogAttrs =
    Dialog_.Attrs


{-| See [`Sl.Element.Dialog.Builder`](Sl.Element.Dialog#Builder).
-}
type alias DialogBuilder attrCaps slotCaps msg kind =
    Dialog_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Dialog.AttrCaps`](Sl.Element.Dialog#AttrCaps).
-}
type alias DialogAttrCaps =
    Dialog_.AttrCaps


{-| See [`Sl.Element.Dialog.SlotCaps`](Sl.Element.Dialog#SlotCaps).
-}
type alias DialogSlotCaps =
    Dialog_.SlotCaps


{-| See [`Sl.Element.Dialog.ChildAdmittedBy`](Sl.Element.Dialog#ChildAdmittedBy).
-}
type alias DialogChildAdmittedBy childAdm =
    Dialog_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Dialog.label`](Sl.Element.Dialog#label).
-}
dialogLabel : String -> Attr { c | label : Supported } msg
dialogLabel =
    Dialog_.label


{-| See [`Sl.Element.Dialog.noHeader`](Sl.Element.Dialog#noHeader).
-}
dialogNoHeader : Bool -> Attr { c | noHeader : Supported } msg
dialogNoHeader =
    Dialog_.noHeader


{-| See [`Sl.Element.Dialog.open`](Sl.Element.Dialog#open).
-}
dialogOpen : Bool -> Attr { c | open : Supported } msg
dialogOpen =
    Dialog_.open


{-| See [`Sl.Element.Dialog.onShow`](Sl.Element.Dialog#onShow).
-}
dialogOnShow : msg -> Attr { c | onShow : Supported } msg
dialogOnShow =
    Dialog_.onShow


{-| See [`Sl.Element.Dialog.onAfterShow`](Sl.Element.Dialog#onAfterShow).
-}
dialogOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
dialogOnAfterShow =
    Dialog_.onAfterShow


{-| See [`Sl.Element.Dialog.onHide`](Sl.Element.Dialog#onHide).
-}
dialogOnHide : msg -> Attr { c | onHide : Supported } msg
dialogOnHide =
    Dialog_.onHide


{-| See [`Sl.Element.Dialog.onAfterHide`](Sl.Element.Dialog#onAfterHide).
-}
dialogOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
dialogOnAfterHide =
    Dialog_.onAfterHide


{-| See [`Sl.Element.Dialog.onInitialFocus`](Sl.Element.Dialog#onInitialFocus).
-}
dialogOnInitialFocus : msg -> Attr { c | onInitialFocus : Supported } msg
dialogOnInitialFocus =
    Dialog_.onInitialFocus


{-| See [`Sl.Element.Dialog.onRequestClose`](Sl.Element.Dialog#onRequestClose).
-}
dialogOnRequestClose : msg -> Attr { c | onRequestClose : Supported } msg
dialogOnRequestClose =
    Dialog_.onRequestClose

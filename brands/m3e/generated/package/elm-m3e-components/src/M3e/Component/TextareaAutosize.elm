module M3e.Component.TextareaAutosize exposing (TextareaAutosizeIs, TextareaAutosizeAttrs, TextareaAutosizeBuilder, TextareaAutosizeAttrCaps, TextareaAutosizeSlotCaps, TextareaAutosizeChildAdmittedBy, textareaAutosize, textareaAutosizeDisabled, textareaAutosizeFor, textareaAutosizeMaxRows, textareaAutosizeMinRows)

{-| The **TextareaAutosize** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.TextareaAutosize`](M3e.Element.TextareaAutosize) as `textareaAutosize`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TextareaAutosizeIs, TextareaAutosizeAttrs, TextareaAutosizeBuilder, TextareaAutosizeAttrCaps, TextareaAutosizeSlotCaps, TextareaAutosizeChildAdmittedBy, textareaAutosize, textareaAutosizeDisabled, textareaAutosizeFor, textareaAutosizeMaxRows, textareaAutosizeMinRows

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Element.TextareaAutosize as TextareaAutosize_


{-| The `textareaAutosize` element of this family — delegates to [`M3e.Element.TextareaAutosize.component`](M3e.Element.TextareaAutosize#component).
-}
textareaAutosize :
    List (Attr TextareaAutosizeAttrs msg)
    -> List (Element childAccepts (TextareaAutosizeChildAdmittedBy childAdm) msg)
    -> Element (TextareaAutosizeIs s) admittedBy msg
textareaAutosize =
    TextareaAutosize_.component


{-| See [`M3e.Element.TextareaAutosize.Is`](M3e.Element.TextareaAutosize#Is).
-}
type alias TextareaAutosizeIs s =
    TextareaAutosize_.Is s


{-| See [`M3e.Element.TextareaAutosize.Attrs`](M3e.Element.TextareaAutosize#Attrs).
-}
type alias TextareaAutosizeAttrs =
    TextareaAutosize_.Attrs


{-| See [`M3e.Element.TextareaAutosize.Builder`](M3e.Element.TextareaAutosize#Builder).
-}
type alias TextareaAutosizeBuilder attrCaps slotCaps msg kind =
    TextareaAutosize_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.TextareaAutosize.AttrCaps`](M3e.Element.TextareaAutosize#AttrCaps).
-}
type alias TextareaAutosizeAttrCaps =
    TextareaAutosize_.AttrCaps


{-| See [`M3e.Element.TextareaAutosize.SlotCaps`](M3e.Element.TextareaAutosize#SlotCaps).
-}
type alias TextareaAutosizeSlotCaps =
    TextareaAutosize_.SlotCaps


{-| See [`M3e.Element.TextareaAutosize.ChildAdmittedBy`](M3e.Element.TextareaAutosize#ChildAdmittedBy).
-}
type alias TextareaAutosizeChildAdmittedBy childAdm =
    TextareaAutosize_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.TextareaAutosize.disabled`](M3e.Element.TextareaAutosize#disabled).
-}
textareaAutosizeDisabled : Bool -> Attr { c | disabled : Supported } msg
textareaAutosizeDisabled =
    TextareaAutosize_.disabled


{-| See [`M3e.Element.TextareaAutosize.for`](M3e.Element.TextareaAutosize#for).
-}
textareaAutosizeFor : String -> Attr { c | for : Supported } msg
textareaAutosizeFor =
    TextareaAutosize_.for


{-| See [`M3e.Element.TextareaAutosize.maxRows`](M3e.Element.TextareaAutosize#maxRows).
-}
textareaAutosizeMaxRows : Float -> Attr { c | maxRows : Supported } msg
textareaAutosizeMaxRows =
    TextareaAutosize_.maxRows


{-| See [`M3e.Element.TextareaAutosize.minRows`](M3e.Element.TextareaAutosize#minRows).
-}
textareaAutosizeMinRows : Float -> Attr { c | minRows : Supported } msg
textareaAutosizeMinRows =
    TextareaAutosize_.minRows

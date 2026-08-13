module AssistChipRequiredContentWrongKind exposing (broken)

{-| NEGATIVE probe — REQUIRED content is typed, not merely present.

Components with mandatory content expose `el` / `build` taking a record of the
required slots, so the content cannot be forgotten:

    el :
        { content : Element Content (ChildAdmittedBy childAdm) msg }
        -> List (Attr Attrs msg)
        -> List (Element Content (ChildAdmittedBy childAdm) msg)
        -> Element (Is s) admittedBy msg

`M3e.Component.AssistChip.Content` is the closed row `{ heading : Brand, sharedText :
Shared }`. Supplying the field is therefore not enough — what fills it is
checked too. `M3e.badge` produces `{ s | badge : Brand }`, so this MUST FAIL.

`M3e.text "Add"` in that position compiles, which is what makes the failure
here about the KIND rather than about the required-record shape.

-}

import M3e
import M3e.Component.AssistChip


broken : M3e.Element (M3e.Component.AssistChip.Is s) admittedBy msg
broken =
    M3e.Component.AssistChip.el { content = M3e.badge [] [] } [] []

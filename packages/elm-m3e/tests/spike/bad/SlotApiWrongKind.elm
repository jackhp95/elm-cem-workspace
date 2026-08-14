module SlotApiWrongKind exposing (wrong)

{-| NEGATIVE probe: wrong-kind element into a typed slot token — must FAIL.

SplitButton's leading-button slot has admittance { button : Brand }.
An IconButton element has kind { s | iconButton : Brand }.

The `place` function requires the element's `accepts` row to unify with the
token's admittance row. `{ iconButton : Brand }` does NOT extend
`{ button : Brand }` — these are disjoint fields, not a subset relationship.

The compiler must reject this with a TYPE MISMATCH like:
    the element's `accepts` row `{ s | iconButton : Brand }` does not match
    `SBTypes.LeadingButtonSlot` = `{ button : Brand }`.

This proves the SlotToken phantom row propagates the kind constraint,
making wrong-kind placements a COMPILE ERROR — the core safety property
of Design A (see planning/2026-08-11-slot-api-design.md).

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import M3e.Build exposing (IconButtonIs)
import M3e.Component.IconButton as IconButton
import M3e.Internal.Types.SplitButton as SBTypes


-- Copy of the SlotToken type and place fn from SlotApiOk.elm
-- (in the real API these would be in M3e.Slot.* modules)
type SlotToken admittance
    = SlotToken String


leadingButtonSlot : SlotToken SBTypes.LeadingButtonSlot
leadingButtonSlot =
    SlotToken "leading-button"


place :
    SlotToken admittance
    -> Element admittance parentAdm msg
    -> Element free freeAdm msg
place (SlotToken slotName) el =
    Ir.fromNode
        (Ir.addAttribute
            (Ir.attribute "slot" slotName)
            (El.toNode el)
        )


type Msg
    = NoOp


{-| An IconButton element — kind { s | iconButton : Brand }.
This does NOT extend LeadingButtonSlot = { button : Brand }.
-}
myIconButton : Element (IconButtonIs s) admittedBy Msg
myIconButton =
    IconButton.view [] []


{-| WRONG: IconButton (kind { iconButton : Brand }) into leadingButtonSlot
(admittance { button : Brand }). Disjoint kind rows — TYPE MISMATCH.
-}
wrong : Element free freeAdm Msg
wrong =
    place leadingButtonSlot myIconButton

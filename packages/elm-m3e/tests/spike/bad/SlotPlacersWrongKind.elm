module SlotPlacersWrongKind exposing (wrongKind)

{-| Design-C slot-placer wrong-kind probe.

IMPORTANT: This file COMPILES. The Design-C broad open `accepts` row accepts
any element, so wrong-kind placements are NOT caught at the type level.

Rejection layer: `Cem.ValidSlotKind` (elm-review rule). When that rule is
active, placing an element whose kind does not match the target slot's accepted
kinds produces an elm-review error naming the parent component, slot, and valid
kinds.

Example: passing a text node as the "leading-button" slot of a splitButton.
The `"leading-button"` slot admits only a `button`-kinded element. At the type
level (broad row), this compiles fine. `ValidSlotKind` would flag it.

This file is listed in `check:spike` as a MUST-COMPILE (not must-fail),
because type-level rejection does not apply to Design-C placers — see the
spec §3.2 note and the open-decision friction in the batch-2 worklog.

-}

import HtmlIr.Element exposing (Element)
import M3e exposing (text)


{-| Wrong kind: a text node placed into the "leading-button" slot.

At the type level: COMPILES (broad admittance row).
At elm-review: would be flagged by `Cem.ValidSlotKind` as wrong kind.

-}
wrongKind : Element free freeAdm msg
wrongKind =
    -- `"leading-button"` slot on `splitButton` admits only button-kinded elements.
    -- A plain text node is NOT a button-kinded element.
    -- TYPE LAYER: accepts it (open row). REVIEW LAYER: ValidSlotKind rejects it.
    M3e.slotLeadingButton (text "not a button")

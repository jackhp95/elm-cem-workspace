module SlotApiOk exposing (placedLeading, placedTrailing)

{-| Prototype: Design A slot token API — good placements COMPILE.

This hand-written fixture demonstrates what a generated `M3e.Slot.*` API
would look like and proves the ergonomics work with existing types.

Key invariants proved here:
  - `place (SlotToken admittance) (Element admittance …)` type-checks.
  - Only an element whose kind row extends the token's admittance row compiles.
  - The bad case (wrong kind) fails at compile time — see bad/SlotApiWrongKind.elm.

These types mimic what `elm-cem` would generate into `M3e.Slot.SplitButton`.
The `place` function would live in `M3e.Slot` (the shared placer module).
NEITHER of these IS generated — do NOT merge.

Generator seam for a real implementation:
  - Emit `M3e.Slot.<Component>.elm` per component from `Cem.Facts.slotKinds`.
  - Emit `M3e.Slot.elm` with `place` using `HtmlIr.Internal.fromNode` +
    `HtmlIr.Internal.addAttribute`.
  - Add to `exposed-modules` in the components package.

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import M3e exposing (text)
import M3e.Action exposing (onClick)
import M3e.Build exposing (ButtonIs, IconButtonIs)
import M3e.Build.Button as Button
import M3e.Component.IconButton as IconButton
import M3e.Internal.Types.SplitButton as SBTypes


-- ---------------------------------------------------------------------------
-- Design A: opaque SlotToken — what the generator would emit into M3e.Slot.*
-- ---------------------------------------------------------------------------


{-| An opaque slot token carrying the HTML slot name and a phantom `admittance`
row. The `admittance` row is the union of kind fields the slot accepts
(derived from `Cem.Facts.slotKinds`).

Generated form (one module per component, per slot):

    -- M3e.Slot.SplitButton
    type SlotToken admittance = SlotToken String

-}
type SlotToken admittance
    = SlotToken String


{-| Token for SplitButton's `leading-button` slot.

Admittance = SBTypes.LeadingButtonSlot = { button : Brand }.
Only an element with kind { s | button : Brand } unifies here.

Generated from:
    slotKinds = [ ("leading-button", ["button"]), … ]

-}
leadingButtonSlot : SlotToken SBTypes.LeadingButtonSlot
leadingButtonSlot =
    SlotToken "leading-button"


{-| Token for SplitButton's `trailing-button` slot.

Admittance = SBTypes.TrailingButtonSlot = { iconButton : Brand }.

-}
trailingButtonSlot : SlotToken SBTypes.TrailingButtonSlot
trailingButtonSlot =
    SlotToken "trailing-button"


-- ---------------------------------------------------------------------------
-- The shared placer — what `M3e.Slot.place` would be
-- ---------------------------------------------------------------------------


{-| Place an element into a typed slot.

The phantom `admittance` row on the token must unify with the element's
`accepts` row — passing a wrong-kind element produces a TYPE MISMATCH.

This is the one shared function across all slot tokens. The generator would
put this in `M3e.Slot` alongside all the token modules.

-}
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


-- ---------------------------------------------------------------------------
-- Usage: good placements — kind rows unify, both compile
-- ---------------------------------------------------------------------------


type Msg
    = Save
    | Cancel


{-| A Button element — kind row { s | button : Brand }.
Satisfies LeadingButtonSlot = { button : Brand }. Good placement.
-}
myButton : Element (ButtonIs s) admittedBy Msg
myButton =
    Button.build { content = text "Save", action = onClick Save }
        |> Button.toElement


{-| A good placement: Button kind { button : Brand } into leadingButtonSlot
(admittance { button : Brand }). Kind rows unify — compiles.
-}
placedLeading : Element free freeAdm Msg
placedLeading =
    place leadingButtonSlot myButton


{-| An IconButton element — kind row { s | iconButton : Brand }.
Satisfies TrailingButtonSlot = { iconButton : Brand }. Good placement.

Using the view constructor with empty children (icon content omitted for
brevity — the slot ergonomics, not the content, is what we prove here).
-}
myIconButton : Element (IconButtonIs s) admittedBy Msg
myIconButton =
    IconButton.view [] []


{-| A good placement: IconButton kind { iconButton : Brand } into
trailingButtonSlot (admittance { iconButton : Brand }). Compiles.
-}
placedTrailing : Element free freeAdm Msg
placedTrailing =
    place trailingButtonSlot myIconButton

module BrandKindIntoSharedSlot exposing (broken)

{-| Half one of the CROSSING THEOREM. MUST FAIL.

    a producer can be discriminated by its own brand's slots, or admitted by a
    foreign brand's enumerated slots, but not both.

`Mini.Chip` keeps its brand kind, so it produces `{ acc | chip : Mini.Kind.Brand }`.
`Mini.Component.Button`'s `icon` slot is enumerated over shared atoms alone —
`IconSlot = { sharedIcon : Shared }` — which is exactly the row a FOREIGN brand
would write, since `Shared` is the only marker two packages can both name.

Row unification here is subset-directional: the producer's fields must all be
members of the slot's row. `chip` is not, and no foreign brand could put it there
even if it wanted to — `Mini.Kind.Brand` is nominally private, so naming the field
in another package would not make the types unify.

Sibling: `SharedAtomHasNoBrandKind.elm`, which shows the other half — the field
that would fix this is the same field whose absence stops this brand
discriminating the producer.

-}

import Mini
import Mini.Component.Button


broken =
    Mini.Component.Button.icon (Mini.chip [] [ Mini.text "not an icon" ])

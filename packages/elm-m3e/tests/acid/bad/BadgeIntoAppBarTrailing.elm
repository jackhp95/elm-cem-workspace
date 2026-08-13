module BadgeIntoAppBarTrailing exposing (broken)

{-| NEGATIVE probe — slot kind admittance, brand kind.

`M3e.Component.AppBar.trailing` takes `Element TrailingSlot admittedBy msg`, and
`TrailingSlot` is a CLOSED row:

    type alias TrailingSlot =
        { button : Brand
        , iconButton : Brand
        , searchBar : Brand
        , sharedFlow : Shared
        , sharedPhrasing : Shared
        }

`M3e.badge` produces the open row `{ s | badge : Brand }`. A producer's named
fields must be a subset of the slot's; `badge` is not among them, so this MUST
FAIL with a record `TYPE MISMATCH` naming the missing `badge` field.

The closedness of the slot row is the whole mechanism — see
`app/Good.elm`, where `M3e.searchBar` (which IS named) goes into the same slot.

-}

import M3e
import M3e.Component.AppBar


broken : M3e.Element free freeAdmittedBy msg
broken =
    M3e.Component.AppBar.trailing (M3e.badge [] [])

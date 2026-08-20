module OpenOnButton exposing (view)

{-| NEGATIVE acid probe: `sl-button` has no `open` attribute, so
`Sl.Attributes.open` (whose phantom row demands `{ c | open : Supported }`)
must NOT unify with `Sl.button`'s attribute row. If this compiles, the
capability-row phantom typing has regressed.
-}

import Html exposing (Html)
import Sl
import Sl.Attributes


view : Html msg
view =
    Sl.toHtml
        (Sl.button
            [ Sl.Attributes.open True ]
            [ Sl.text "Save" ]
        )

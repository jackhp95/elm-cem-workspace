module SizeValueAsVariant exposing (view)

{-| NEGATIVE acid probe: `Sl.Values.large` is a `Size` token, not a `Variant`.
Passing it to `Sl.Attributes.variant` (which expects `Value Sl.Values.Variant`)
must fail to unify. If this compiles, the value-vocabulary phantom narrowing
has regressed.
-}

import Html exposing (Html)
import Sl
import Sl.Attributes
import Sl.Values


view : Html msg
view =
    Sl.toHtml
        (Sl.button
            [ Sl.Attributes.variant Sl.Values.large ]
            [ Sl.text "Save" ]
        )

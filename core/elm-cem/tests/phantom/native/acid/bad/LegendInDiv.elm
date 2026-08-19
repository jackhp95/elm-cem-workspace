module LegendInDiv exposing (broken)

{-| legend's closed AdmittedBy { fieldset } excludes div. MUST FAIL (row 2).
-}

import TypedHtml as H


broken =
    H.div [] [ H.legend [] [ H.text "stray caption" ] ]

module TdInDiv exposing (broken)

{-| td's closed AdmittedBy { tr } excludes div. MUST FAIL (row 2).
-}

import TypedHtml as H


broken =
    H.div [] [ H.td [] [ H.text "stray cell" ] ]

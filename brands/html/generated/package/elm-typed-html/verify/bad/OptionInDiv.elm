module OptionInDiv exposing (broken)

{-| THE acid test: kind-permissive div still rejects a direct option — its
closed AdmittedBy { optgroup, select } excludes div. MUST FAIL (row 2).
-}

import TypedHtml as H


broken =
    H.div [] [ H.option [] [ H.text "stray" ] ]

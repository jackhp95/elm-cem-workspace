module OptionInDiv exposing (broken)

{-| THE acid test: a kind-permissive div must still reject a direct <option>,
because option's closed admittedBy excludes div. MUST FAIL (row 2).
-}

import MiniNative as N


broken =
    N.div [] [ N.option [] [ N.text "stray" ] ]

module InferNoAnno exposing (tree)

{-| Zero type annotations — inference must thread both phantom rows through a
mixed cross-brand tree unaided. MUST compile.
-}

import MiniM3e as M
import MiniNative as N


tree =
    N.div []
        [ N.select [] [ N.option [] [ N.text "One" ] ]
        , M.button [ M.variant M.tonal ] [ N.text "Go" ]
        ]

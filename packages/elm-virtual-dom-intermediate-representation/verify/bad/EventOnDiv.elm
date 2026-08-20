module EventOnDiv exposing (broken)

{-| onClick on a non-interactive element: div's closed attrs row has no
onClick field. MUST FAIL (event-as-capability gating).
-}

import MiniNative as N


type Msg
    = Clicked


broken =
    N.div [ N.onClick Clicked ] []

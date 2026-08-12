module WrongEnumString exposing (broken)

{-| A bare String where a typed Value is required. MUST FAIL.
-}

import MiniM3e as M


broken =
    M.button [ M.variant "filled" ] []

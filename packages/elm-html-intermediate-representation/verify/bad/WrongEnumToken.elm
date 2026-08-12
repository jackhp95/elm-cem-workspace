module WrongEnumToken exposing (broken)

{-| A well-formed token from a DIFFERENT enum (dense) against variant's closed
value row ({ filled, tonal }). MUST FAIL.
-}

import MiniM3e as M


broken =
    M.button [ M.variant M.dense ] []

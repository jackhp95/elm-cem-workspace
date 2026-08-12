module WrongSlotKind exposing (broken)

{-| A native div-kind element into m3e button's closed slot row
({ sharedText, icon }). MUST FAIL (row 1).
-}

import MiniM3e as M
import MiniNative as N


broken =
    M.button [] [ N.div [] [] ]

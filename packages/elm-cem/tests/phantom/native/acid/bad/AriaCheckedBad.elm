module AriaCheckedBad exposing (broken)

{-| Value-typed aria state: a raw String is rejected. MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Aria as Aria


broken =
    H.span [ Aria.checked "sortof" ] [ H.text "x" ]

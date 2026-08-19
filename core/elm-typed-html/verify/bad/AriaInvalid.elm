module AriaInvalid exposing (broken)

{-| The ARIA acid test: div's Roles row excludes the widget role `tab`.
MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Aria as Aria


broken =
    H.div [ Aria.role Aria.tab ] [ H.text "not a tab" ]

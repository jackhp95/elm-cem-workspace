module TabindexString exposing (broken)

{-| `tabindex` is an `Int`, so a raw String is rejected. MUST FAIL.

It is an `Int` rather than a natural because negative values are load-bearing
(`tabindex="-1"` = focusable by script only, skipped by sequential navigation),
and not a `String` because `tabindex "one"` would compile into markup the browser
then ignores.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.span [ At.tabindex "0" ] [ H.text "x" ]

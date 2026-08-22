module InteractiveContentInButton exposing (broken)

{-| families/a11y-composition plan, Task 3: `button`'s content model is
"Phrasing content, but there must be no interactive content descendant"
(WHATWG). `button`'s own admits gained `!@interactive`, so `button`'s produced
kind (`sharedPhrasing`) is no longer in its OWN admitted `Content` row. MUST
FAIL.
-}

import TypedHtml as H


broken =
    H.button [] [ H.button [] [] ]

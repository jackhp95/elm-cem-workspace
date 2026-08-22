module ButtonInSummary exposing (broken)

{-| families/a11y-composition plan, Task 3: `summary`'s admits gained
`!@interactive`; `button` is `@interactive`, so it no longer unifies with
`summary`'s admitted `Content` row. MUST FAIL.
-}

import TypedHtml as H


broken =
    H.summary [] [ H.button [] [] ]

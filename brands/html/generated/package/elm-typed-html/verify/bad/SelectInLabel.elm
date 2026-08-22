module SelectInLabel exposing (broken)

{-| families/a11y-composition plan, Task 3: `label`'s admits gained
`!@interactive`; `select` is `@interactive`, so it no longer unifies with
`label`'s admitted `Content` row. MUST FAIL.
-}

import TypedHtml as H


broken =
    H.label [] [ H.select [] [] ]

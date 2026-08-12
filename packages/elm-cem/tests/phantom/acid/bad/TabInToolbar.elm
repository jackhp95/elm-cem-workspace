module TabInToolbar exposing (broken)

{-| Row-1 failure via a kind SET: toolbar's slot closes over Actions
(button | chip); tab's kind is not in the set. MUST FAIL.
-}

import Mini


broken =
    Mini.toolbar [] [ Mini.tab [] [ Mini.text "not an action" ] ]

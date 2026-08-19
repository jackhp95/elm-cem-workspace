module ChipInTabs exposing (broken)

{-| Row-1 failure: tabs' slot closes over { tab }. MUST FAIL.
-}

import Mini


broken =
    Mini.tabs [] [ Mini.chip [] [ Mini.text "not a tab" ] ]

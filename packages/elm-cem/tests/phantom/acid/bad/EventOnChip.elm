module EventOnChip exposing (broken)

{-| Event-as-capability: chip declares no click event, so its Attrs row has no
`onClick` field. MUST FAIL.
-}

import Mini
import Mini.Events


type Msg
    = Clicked


broken =
    Mini.chip [ Mini.Events.onClick Clicked ] [ Mini.text "x" ]

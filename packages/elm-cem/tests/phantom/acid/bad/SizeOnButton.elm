module SizeOnButton exposing (broken)

{-| General-surface setter still element-gated: Button's Attrs row has no
`size` field, so the union setter is rejected on it. MUST FAIL.
-}

import Mini
import Mini.Attributes
import Mini.Values


broken =
    Mini.button [ Mini.Attributes.size Mini.Values.small ] [ Mini.text "x" ]

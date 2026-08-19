module ForeignToken exposing (broken)

{-| Narrowing failure: `small` is a real Mini token, but Button's narrowed
Variant row { filled, tonal } excludes it. MUST FAIL.
-}

import Mini
import Mini.Component.Button
import Mini.Values


broken =
    Mini.button [ Mini.Component.Button.variant Mini.Values.small ] [ Mini.text "x" ]

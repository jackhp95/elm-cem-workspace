module DuplicateVariant exposing (broken)

{-| Pipe-builder cardinality: the second withVariant finds its capability
already Used. MUST FAIL.
-}

import Mini
import Mini.Button
import Mini.Values


broken =
    Mini.Button.build { content = Mini.text "x" }
        |> Mini.Button.withVariant Mini.Values.filled
        |> Mini.Button.withVariant Mini.Values.tonal
        |> Mini.Button.toElement

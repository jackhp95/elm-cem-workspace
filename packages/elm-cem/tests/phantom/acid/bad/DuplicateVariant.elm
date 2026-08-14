module DuplicateVariant exposing (broken)

{-| Pipe-builder cardinality: the second withVariant finds its capability
already Used. MUST FAIL.
-}

import Mini
import Mini.Build.Button
import Mini.Values


broken =
    Mini.Build.Button.build { content = Mini.text "x" }
        |> Mini.Build.Button.withVariant Mini.Values.filled
        |> Mini.Build.Button.withVariant Mini.Values.tonal
        |> Mini.Build.Button.toElement

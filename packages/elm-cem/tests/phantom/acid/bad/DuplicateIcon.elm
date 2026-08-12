module DuplicateIcon exposing (broken)

{-| Pipe-builder slot cardinality: the icon slot is singular; the second
withIcon finds its capability already Used. MUST FAIL.
-}

import Mini
import Mini.Button


broken =
    Mini.Button.build { content = Mini.text "x" }
        |> Mini.Button.withIcon (Mini.icon [] [ Mini.text "a" ])
        |> Mini.Button.withIcon (Mini.icon [] [ Mini.text "b" ])
        |> Mini.Button.toElement

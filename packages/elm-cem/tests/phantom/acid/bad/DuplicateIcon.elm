module DuplicateIcon exposing (broken)

{-| Pipe-builder slot cardinality: the icon slot is singular; the second
withIcon finds its capability already Used. MUST FAIL.
-}

import Mini
import Mini.Build.Button


broken =
    Mini.Build.Button.build { content = Mini.text "x" }
        |> Mini.Build.Button.withIcon (Mini.Build.Button.build { content = Mini.text "a" })
        |> Mini.Build.Button.withIcon (Mini.Build.Button.build { content = Mini.text "b" })
        |> Mini.Build.Button.toElement

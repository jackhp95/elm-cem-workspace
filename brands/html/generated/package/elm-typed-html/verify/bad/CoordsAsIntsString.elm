module CoordsAsIntsString exposing (broken)

{-| `coords` is a COMMA-SEPARATED LIST (`"0,0,82,126"`), so its base setter is a
String and `coordsAsInts` takes the `List Int`. Neither accepts a bare number — which
is exactly what the manifest used to declare it as, making every `<area coords>`
unwritable. MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.area [ At.coordsAsInts "0,0,82,126" ] []

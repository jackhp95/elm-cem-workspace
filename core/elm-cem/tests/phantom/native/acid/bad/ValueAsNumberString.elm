module ValueAsNumberString exposing (broken)

{-| `valueAsNumber` is the NUMERIC form of `value`, not a second string setter: the
base keeps the spec-correct `String` (a submission value is text) and the variant only
adds the convenience. Handing it a string MUST FAIL — otherwise the two would be
interchangeable and the variant would earn nothing.
-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.option [ At.valueAsNumber "1" ] [ H.text "x" ]

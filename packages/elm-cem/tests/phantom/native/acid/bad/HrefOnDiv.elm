module HrefOnDiv exposing (broken)

{-| Canonical shared attr, still element-gated: div's Attrs row has no href.
MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.div [ At.href "/x" ] []

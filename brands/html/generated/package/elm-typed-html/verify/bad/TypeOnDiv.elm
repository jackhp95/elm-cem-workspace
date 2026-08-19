module TypeOnDiv exposing (broken)

{-| B4 type family, still element-gated: `type` is admitted by input / button /
script, but div's Attrs row has no `type_` capability field. MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.div [ At.type_ "checkbox" ] []

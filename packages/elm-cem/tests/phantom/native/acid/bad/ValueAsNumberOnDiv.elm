module ValueAsNumberOnDiv exposing (broken)

{-| A `_variants` setter is element-gated exactly like its base, because it claims the
BASE capability row rather than minting its own: div's `Attrs` row has no `value`
field, so `valueAsNumber` is rejected there just as `value` is. MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.div [ At.valueAsNumber 1 ] []

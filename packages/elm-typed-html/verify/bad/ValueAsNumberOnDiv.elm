module ValueAsNumberOnDiv exposing (broken)

{-| A `_variants` setter is element-gated exactly like its base, because it claims the
BASE capability row rather than minting its own: div's `Attrs` row has no `value`
field, so `valueAsNumber` is rejected there just as `value` is. MUST FAIL.

This is the guarantee that makes the mechanism free — a variant cannot smuggle an
attribute onto an element that does not admit it, and no element's `Attrs` record grew
a field to hold one.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.div [ At.valueAsNumber 1 ] []

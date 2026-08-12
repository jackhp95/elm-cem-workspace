module GridAsIntsOnButton exposing (broken)

{-| A `_variants` setter is element-gated exactly like its base, because it claims the
BASE capability row rather than minting its own. `grid` is Surface's; Button's `Attrs`
row has no `grid` field, so `gridAsInts` is rejected on a Button. MUST FAIL.

This is the guarantee that makes the mechanism free: variants cannot smuggle an
attribute onto an element that does not admit it.

-}

import Mini
import Mini.Attributes


broken =
    Mini.button [ Mini.Attributes.gridAsInts [ 1, 2 ] ] [ Mini.text "x" ]

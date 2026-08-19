module WeightAsNumberKeyword exposing (broken)

{-| The whole reason the BASE setter keeps its String type.

`weight` admits the keyword `"auto"`, which no `Float` expresses — so `weight` is
`String -> Attr` and `weightAsNumber` is the ergonomic extra, not a replacement.
Handing the keyword to the numeric variant MUST FAIL; had the base been narrowed to
`Float` (as `step` and `coords` wrongly were), `"auto"` would have had no expression
at all.

-}

import Mini
import Mini.Attributes


broken =
    Mini.button [ Mini.Attributes.weightAsNumber "auto" ] [ Mini.text "x" ]

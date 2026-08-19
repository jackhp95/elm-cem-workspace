module StepAsNumberKeyword exposing (broken)

{-| The whole reason `step` keeps its String type.

`step="any"` is a legal keyword that disables step-matching, and no `Float` expresses
it — so `step : String` is the spec-correct base and `stepAsNumber : Float` is the
ergonomic extra beside it, not a replacement. Handing the keyword to the numeric
variant MUST FAIL.

The manifest typed `step` as `number`, which made `step "any"` unwritable at all. See
`Good.elm` for the passing half.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.input [ At.stepAsNumber "any" ] []

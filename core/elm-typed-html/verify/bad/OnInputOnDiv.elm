module OnInputOnDiv exposing (broken)

{-| #2 events stay element-gated: `onInput` is admitted by the input / textarea
/ select capability rows, but div's Attrs row has no `onInput` field. Placing
it on a div MUST FAIL (consumers used to hand-forge `Native.onInput` here).
-}

import TypedHtml as H
import TypedHtml.Events as Ev


type Msg
    = Never_


broken =
    H.div [ Ev.onInput (\_ -> Never_) ] []

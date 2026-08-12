module DatetimeFloat exposing (broken)

{-| The regression, pinned. `datetime` is a date/time string on every element that has
it — `<time>` (machine-readable value) and `<ins>`/`<del>` (date of the change).

The manifest typed `<time datetime>` as `number`; all three elements share the `Text`
home module, which emits ONE setter per attribute name, so `Float` won and the string
form was silently dropped. Passing a number MUST FAIL now, and `Good.elm` pins that
all three string forms compile.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.time [ At.datetime 1704110400 ] [ H.text "noon" ]

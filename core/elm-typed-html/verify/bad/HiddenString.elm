module HiddenString exposing (broken)

{-| `hidden` is value-typed, so a raw String is rejected. MUST FAIL.

This is the regression this guard exists for: while every global was emitted as
`String -> Attr`, `hidden "false"` compiled AND HID the element — `hidden` is a
boolean content attribute, so every value except `until-found` is the hidden
state. `Bool` would be wrong too (`hidden="until-found"` keeps the element
findable by find-in-page), hence a two-token enum.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.span [ At.hidden "false" ] [ H.text "x" ]

module EnumNarrowingBuilder exposing (wrong)

{-| NEGATIVE probe: Button.withVariant given a foreign-component token — must FAIL.

Button.Variant = { elevated, filled, outlined, text, tonal } — NO rainbow.
V.rainbow : Value { v | rainbow : Supported } is a valid Theme token but does
NOT extend Button's closed Component.Variant row.

The builder's withVariant signature is:
    Value Component.Variant -> Builder { a | variant : Available } … -> …
    where Component.Variant = { elevated, filled, outlined, text, tonal }

Passing V.rainbow (a Theme token) here must produce a TYPE MISMATCH.

-}

import HtmlIr.Element exposing (Element)
import M3e.Build.Button as Button
import M3e.Build exposing (ButtonIs)
import M3e.Action exposing (onClick)
import M3e exposing (text)
import M3e.Values as V


type Msg
    = Save


wrong : Element (ButtonIs s) admittedBy Msg
wrong =
    Button.build { content = text "Save", action = onClick Save }
        |> Button.withVariant V.rainbow
        |> Button.toElement

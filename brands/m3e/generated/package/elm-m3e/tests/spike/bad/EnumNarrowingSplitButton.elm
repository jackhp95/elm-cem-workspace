module EnumNarrowingSplitButton exposing (wrong)

{-| NEGATIVE probe: SplitButton.variant given V.rainbow — must FAIL.

SplitButton.Variant = { elevated, filled, outlined, tonal } — NO rainbow.
V.rainbow : Value { v | rainbow : Supported } does NOT extend SplitButton.Variant.

The compiler must reject this with a type mismatch between the open-rowed
`rainbow` token and SplitButton's closed Variant row.

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Kind exposing (Supported)
import M3e.Component.SplitButton as SplitButton
import M3e.Values as V


type Msg
    = NoOp


wrong : Attr { c | variant : Supported } Msg
wrong =
    SplitButton.variant V.rainbow

module Theme.Icons exposing (IconStyle(..), defaultStyle, fromString, toString)

{-| Icon style for `m3e-icon`. The Material Symbols font comes in three optical
variants — Outlined, Rounded, Sharp — selected via `<m3e-icon variant="…">`.

No CSS custom property controls this: the variant attribute maps directly to
`font-family` inside `m3e-icon`'s shadow DOM CSS. Controlling it globally
requires passing the model's `iconStyle` down to every `M3e.Icon` call site.

@docs IconStyle, defaultStyle, fromString, toString

-}


{-| The three Material Symbols optical variants.
-}
type IconStyle
    = Outlined
    | Rounded
    | Sharp


{-| The default icon style: Outlined (matches the existing docs app icons).
-}
defaultStyle : IconStyle
defaultStyle =
    Outlined


{-| Wire string used by `m3e-icon`'s `variant` attribute.
-}
toString : IconStyle -> String
toString style =
    case style of
        Outlined ->
            "outlined"

        Rounded ->
            "rounded"

        Sharp ->
            "sharp"


{-| Parse a wire string back to an `IconStyle`. Unknown strings fall back to
`Outlined` so a persisted value that is no longer valid never crashes the app.
-}
fromString : String -> IconStyle
fromString s =
    case s of
        "rounded" ->
            Rounded

        "sharp" ->
            Sharp

        _ ->
            Outlined

module Theme.Scale exposing (ScaleConfig, ScaleMode(..), compute, defaultConfig, modeFromString, modeToString)

{-| The 4-mode scale computation used by the Typography and Shape accordion
sections to derive every token's value from a handful of controls.
-}


type ScaleMode
    = Linear
    | Modular
    | Bump
    | Power


type alias ScaleConfig =
    { mode : ScaleMode
    , factor : Float
    , ratio : Float
    , base : Float
    , bump : Float
    , exponent : Float
    }


defaultConfig : ScaleConfig
defaultConfig =
    { mode = Linear, factor = 1, ratio = 1.2, base = 1, bump = 0, exponent = 1 }


{-| `token` only needs `defaultRem` and `step` — both `Theme.Tokens.TypescaleToken`
and `Theme.Tokens.ShapeToken` carry these, so this works for both sections'
token lists without duplicating the function.
-}
compute : ScaleConfig -> { token | defaultRem : Float, step : Int } -> Float
compute config token =
    case config.mode of
        Linear ->
            token.defaultRem * config.factor

        Modular ->
            config.base * (config.ratio ^ toFloat token.step)

        Bump ->
            token.defaultRem + config.bump

        Power ->
            config.base * ((token.defaultRem / config.base) ^ config.exponent)


modeToString : ScaleMode -> String
modeToString mode =
    case mode of
        Linear ->
            "linear"

        Modular ->
            "modular"

        Bump ->
            "bump"

        Power ->
            "power"


modeFromString : String -> Maybe ScaleMode
modeFromString str =
    case str of
        "linear" ->
            Just Linear

        "modular" ->
            Just Modular

        "bump" ->
            Just Bump

        "power" ->
            Just Power

        _ ->
            Nothing

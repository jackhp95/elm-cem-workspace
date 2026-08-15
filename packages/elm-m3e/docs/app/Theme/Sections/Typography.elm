module Theme.Sections.Typography exposing (view)

{-| The Typography accordion section: display/body font pickers (real
`m3e-select`s), a Linear/Modular/Bump/Power scale-mode segmented control,
per-mode numeric steppers, and a live 15-token size preview
(`Theme.Tokens.typescaleTokens`).
-}

import Json.Decode as Decode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Option
import M3e.Events
import Theme exposing (Msg(..))
import Theme.Fonts
import Theme.Scale as Scale
import Theme.Sections.Shared as Shared
import Theme.Tokens as Tokens
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Component.Grouping


view : Theme.Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ fontSelect "Display font" "display-font" model.displayFont SetDisplayFont
        , fontSelect "Body font" "body-font" model.bodyFont SetBodyFont
        , Shared.modeSegmented SetTypeScaleMode model.typeScale.mode
        , Shared.stepperControls SetTypeScaleParam model.typeScale
        , preview model
        ]


{-| One font picker, an `m3e-select` of `m3e-option`s drawn from
`Theme.Fonts.curatedFonts`. The selected family is read from the `change`
event's `target.value` via `M3e.Events.onChangeWith` (the select binding's
plain `onChange` carries no value). Picking a font fires `SetDisplayFont` /
`SetBodyFont`, which loads the webfont AND applies it globally.
-}
fontSelect : String -> String -> String -> (String -> Msg) -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
fontSelect labelText idSuffix current toMsg =
    let
        inputId : String
        inputId =
            "font-select-" ++ idSuffix
    in
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center justify-between gap-2" ]
        [ TypedHtml.label [ TypedHtml.Attributes.for inputId ] [ M3e.text labelText ]
        , M3e.select
            [ M3e.Attributes.id inputId
            , M3e.Events.onChangeWith
                (Decode.map toMsg (Decode.at [ "target", "value" ] Decode.string))
            ]
            (List.map
                (\font ->
                    M3e.option
                        [ M3e.Component.Option.value font, M3e.Component.Option.selected (font == current) ]
                        [ M3e.text font ]
                )
                Theme.Fonts.curatedFonts
            )
        ]


preview : Theme.Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
preview model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1" ]
        (List.map
            (\token ->
                TypedHtml.div
                    [ TypedHtml.Attributes.class ("[font-size:" ++ String.fromFloat (Scale.compute model.typeScale token) ++ "rem]") ]
                    [ M3e.text token.label ]
            )
            Tokens.typescaleTokens
        )

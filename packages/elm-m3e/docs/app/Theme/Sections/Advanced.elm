module Theme.Sections.Advanced exposing (view)

{-| The Advanced accordion section: raw stepper controls for the 16
motion-duration tokens and 3 state-layer-opacity tokens. Unlike Typography
and Shape's steppers, which drive a `Theme.Scale.ScaleConfig` through
`SetTypeScaleParam`/`SetShapeScaleParam`, these tokens have no scale-mode
computation — each stepper writes a raw CSS custom property directly via
`Theme.SetCssOverride`, reusing `Theme.Sections.Shared.numberStepper` (an
editable `m3e-form-field` with decrement/increment icon buttons) with a
`Float -> Msg` adapter that rounds back to an `Int` and re-serializes the unit
suffix.
-}

import Dict
import M3e exposing (Element)
import M3e.Component.FormField as FormField
import Theme exposing (Msg(..))
import Theme.Sections.Shared as Shared
import Theme.Tokens as Tokens exposing (MotionDurationToken, StateOpacityToken)
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Component.Grouping


view : Theme.Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ -- No m3e component owns standalone muted body prose (see the recipe's
          -- Tier 4 gap note); `text-sm`/`text-on-surface-variant` are deleted
          -- rather than routed sideways into a new CSS class, so this reads in
          -- the plain document body scale/colour until the design system ships
          -- a body-text component.
          TypedHtml.p []
            [ M3e.text "Motion durations and state-layer opacities — raw CSS custom-property overrides for the 16 transition-timing tokens and 3 interaction-state opacity tokens @m3e/web exposes." ]
        , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2" ]
            (List.map (durationRow model) Tokens.motionDurationTokens)
        , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2" ]
            (List.map (opacityRow model) Tokens.stateOpacityTokens)
        ]


{-| Reads the current override off `model.cssOverrides` (falling back to the
token's default), parsing the numeric prefix back out of the stored
`"250ms"`-shaped string.
-}
durationRow : Theme.Model -> MotionDurationToken -> Element (FormField.Is s) admittedBy Msg
durationRow model token =
    let
        currentMs : Int
        currentMs =
            Dict.get token.cssVar model.cssOverrides
                |> Maybe.andThen (String.replace "ms" "" >> String.toInt)
                |> Maybe.withDefault token.defaultMs

        toMsg : Float -> Msg
        toMsg newMs =
            SetCssOverride token.cssVar (String.fromInt (round newMs) ++ "ms")
    in
    Shared.numberStepper token.label (toFloat currentMs) 25 toMsg


opacityRow : Theme.Model -> StateOpacityToken -> Element (FormField.Is s) admittedBy Msg
opacityRow model token =
    let
        currentPercent : Int
        currentPercent =
            Dict.get token.cssVar model.cssOverrides
                |> Maybe.andThen (String.replace "%" "" >> String.toInt)
                |> Maybe.withDefault token.defaultPercent

        toMsg : Float -> Msg
        toMsg newPercent =
            SetCssOverride token.cssVar (String.fromInt (round newPercent) ++ "%")
    in
    Shared.numberStepper token.label (toFloat currentPercent) 1 toMsg

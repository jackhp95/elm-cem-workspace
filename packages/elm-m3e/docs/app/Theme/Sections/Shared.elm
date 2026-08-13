module Theme.Sections.Shared exposing (modeSegmented, numberStepper, stepperControls)

{-| Widgets shared by the Typography and Shape accordion sections — both
drive a `Theme.Scale.ScaleConfig` through the same Linear/Modular/Bump/Power
mode-dependent set of numeric steppers, differing only in which `Msg`
constructor wraps the resulting `Theme.TypeScaleParam` (`SetTypeScaleParam`
for Typography, `SetShapeScaleParam` for Shape — both share the same
`Theme.TypeScaleParam` type). Both also drive the same Linear/Modular/Bump/Power
mode segmented control, differing only in which `Msg` constructor wraps the
resulting `Theme.Scale.ScaleMode`.
-}

import M3e exposing (Element)
import M3e.Component.Icon
import M3e.Kind
import Theme exposing (TypeScaleParam)
import Theme.Scale as Scale exposing (ScaleConfig, ScaleMode)
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes
import TypedHtml.Events
import TypedHtml.Grouping


{-| A `Theme.segmented` control (the shared segmented-button helper also used
for the Scheme control in `Theme.elm`) — its `ButtonSegment`s already carry
their own accessible name from the visible label text, matching the rest of
the app's convention for this control shape.
-}
modeSegmented : (ScaleMode -> Theme.Msg) -> ScaleMode -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Theme.Msg
modeSegmented toMsg current =
    Theme.segmented
        (List.map
            (\mode -> ( Scale.modeToString mode |> Theme.capitalize, mode == current, toMsg mode ))
            [ Scale.Linear, Scale.Modular, Scale.Bump, Scale.Power ]
        )


{-| Only the fields relevant to the active mode are meaningfully editable —
Linear uses `factor`, Modular uses `ratio`+`base`, Bump uses `bump`, Power
uses `exponent`+`base`.
-}
stepperControls : (TypeScaleParam -> Float -> msg) -> ScaleConfig -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
stepperControls toMsg config =
    case config.mode of
        Scale.Linear ->
            TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2" ]
                [ numberStepper "Factor" config.factor 0.05 (toMsg Theme.Factor) ]

        Scale.Modular ->
            TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2" ]
                [ numberStepper "Ratio" config.ratio 0.01 (toMsg Theme.Ratio)
                , numberStepper "Base (rem)" config.base 0.05 (toMsg Theme.Base)
                ]

        Scale.Bump ->
            TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2" ]
                [ numberStepper "Bump (rem)" config.bump 0.05 (toMsg Theme.Bump) ]

        Scale.Power ->
            TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2" ]
                [ numberStepper "Exponent" config.exponent 0.05 (toMsg Theme.Exponent)
                , numberStepper "Base (rem)" config.base 0.05 (toMsg Theme.Base)
                ]


numberStepper : String -> Float -> Float -> (Float -> msg) -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
numberStepper labelText current step toMsg =
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-1" ]
        [ M3e.text labelText
        , M3e.iconButton
            [ TypedHtml.Events.onClick (toMsg (current - step))
            , Aria.label ("Decrease " ++ labelText)
            ]
            [ M3e.icon [ M3e.Component.Icon.name "remove" ] [] ]
        , M3e.text (String.fromFloat current)
        , M3e.iconButton
            [ TypedHtml.Events.onClick (toMsg (current + step))
            , Aria.label ("Increase " ++ labelText)
            ]
            [ M3e.icon [ M3e.Component.Icon.name "add" ] [] ]
        ]

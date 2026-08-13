module Theme.Sections.Color exposing (view)

{-| The Color accordion section: one row per color token, grouped by
`Theme.Tokens.colorGroups` (37 tokens across 9 groups). Each row shows the
current override value (from `model.colorOverrides`, falling back to "not
overridden"), a native color `<input>`, and a reset button.
-}

import Dict
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Icon
import Theme exposing (Msg(..))
import Theme.Tokens as Tokens exposing (ColorToken)
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes
import TypedHtml.Events
import TypedHtml.Grouping
import TypedHtml.Sectioning


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        (List.map (groupView model) Tokens.colorGroups)


groupView : Theme.Model -> ( String, List ColorToken ) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
groupView model ( groupName, tokens ) =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1" ]
        (TypedHtml.Sectioning.h3 [] [ M3e.text groupName ]
            :: List.map (tokenRow model) tokens
        )


tokenRow : Theme.Model -> ColorToken -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
tokenRow model token =
    let
        inputId : String
        inputId =
            "color-" ++ token.cssVar

        current : Maybe String
        current =
            Dict.get token.cssVar model.colorOverrides

        resetLabel : String
        resetLabel =
            if current == Nothing then
                "Reset " ++ token.role ++ " (no override set)"

            else
                "Reset " ++ token.role
    in
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-2" ]
        [ TypedHtml.label [ TypedHtml.Attributes.for inputId ] [ M3e.text token.role ]
        , TypedHtml.input
            [ TypedHtml.Attributes.id inputId
            , TypedHtml.Attributes.type_ "color"
            , TypedHtml.Attributes.value (Maybe.withDefault "#000000" current)
            , TypedHtml.Events.onInput (SetColorOverride token.cssVar)
            ]
            []
        , M3e.iconButton
            [ M3e.Attributes.disabled (current == Nothing)
            , Aria.label resetLabel
            , TypedHtml.Events.onClick (ResetColorOverride token.cssVar)
            ]
            [ M3e.icon [ M3e.Component.Icon.name "restart_alt" ] [] ]
        ]

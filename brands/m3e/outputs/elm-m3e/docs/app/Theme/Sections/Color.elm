module Theme.Sections.Color exposing (view)

{-| The Color accordion section: one compact chip per color token, grouped by
`Theme.Tokens.colorGroups` (37 tokens across 9 groups) and laid out as a WRAPPING
CLUSTER rather than the old one-full-width-row-per-token stack (37 stacked rows
pushed every other section out of the drawer).

Each chip is a real `m3e-form-field` carrying, left to right:

  - a **color circle** in the `prefix` slot — a `<label>` whose `for` points at a
    visually-hidden native `<input type="color">`, so clicking the circle opens
    the OS picker and the native input stays the keyboard-accessible control;
  - a **value entry** — a short hex text input, so a token can be typed exactly
    (`#1a73e8`) instead of only being dialled in through the OS widget;
  - an **unset** icon button in the `suffix` slot, shown only when the token
    actually carries an override.

State lives only in the existing `colorOverrides` dict — an unset token shows an
empty input and a transparent circle (Elm cannot read the live computed CSS
variable, so there is no honest default to display). No new `Theme.Model` field,
no persisted-state change.

-}

import Dict
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.FormField as FormField
import M3e.Component.Icon
import M3e.Values as Value
import Seam
import Theme exposing (Msg(..))
import Theme.Tokens as Tokens exposing (ColorToken)
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes
import TypedHtml.Component.Grouping
import TypedHtml.Events


view : Theme.Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        (List.map (groupView model) Tokens.colorGroups)


groupView : Theme.Model -> ( String, List ColorToken ) -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
groupView model ( groupName, tokens ) =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1" ]
        [ M3e.heading
            [ M3e.Attributes.variant Value.title
            , M3e.Attributes.size Value.small
            , M3e.Attributes.level 3
            ]
            [ M3e.text groupName ]
        , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-wrap items-start gap-2" ]
            (List.map (tokenChip model) tokens)
        ]


{-| One color token as a compact form-field chip: circle + value entry + unset.
-}
tokenChip : Theme.Model -> ColorToken -> Element (FormField.Is s) admittedBy Msg
tokenChip model token =
    let
        current : Maybe String
        current =
            Dict.get token.cssVar model.colorOverrides

        pickerId : String
        pickerId =
            "colorpick-" ++ token.cssVar

        hexId : String
        hexId =
            "colorhex-" ++ token.cssVar

        -- The swatch circle IS the OS-picker trigger: a `<label for>` over a
        -- visually-hidden native `<input type=color>`. Keeping the native input
        -- in the tree (rather than firing a click from Elm) is what keeps the
        -- control keyboard-reachable and screen-reader-labelled.
        -- The circle itself is a bare `M3e.avatar` (round by default, same
        -- swatch idiom `Theme.colorAvatar`/`Theme.sourceColorOption` use for
        -- the curated seed-color picker) instead of a hand-painted
        -- `rounded-full border`. A native `<label>` only admits phrasing
        -- content, which a custom element like `m3e-avatar` is not, so —
        -- exactly like `Theme.sourceColorOption` — the click target is the
        -- native `<input type=color>` itself, stretched transparently over
        -- the decorative avatar rather than wrapped in a `<label for>`.
        swatch : Element (TypedHtml.Component.Grouping.DivIs t) admittedBy Msg
        swatch =
            TypedHtml.div [ TypedHtml.Attributes.class "inline-flex items-center" ]
                [ TypedHtml.label
                    [ TypedHtml.Attributes.for pickerId
                    , TypedHtml.Attributes.class "size-4 shrink-0 cursor-pointer"
                    , Seam.colorSwatchChrome
                    , TypedHtml.Attributes.style "background-color" (Maybe.withDefault "transparent" current)
                    ]
                    []
                , TypedHtml.input
                    [ TypedHtml.Attributes.id pickerId
                    , TypedHtml.Attributes.type_ "color"
                    , TypedHtml.Attributes.value (Maybe.withDefault "#000000" current)
                    , TypedHtml.Attributes.class "sr-only"
                    , TypedHtml.Events.onInput (SetColorOverride token.cssVar)
                    , Aria.label ("Pick " ++ token.role ++ " from the OS color picker")
                    ]
                    []
                ]

        unsetButton : List (Element free freeAdm Msg)
        unsetButton =
            case current of
                Just _ ->
                    [ FormField.suffix
                        (M3e.iconButton
                            [ TypedHtml.Events.onClick (ResetColorOverride token.cssVar)
                            , Aria.label ("Unset " ++ token.role)
                            ]
                            [ M3e.icon [ M3e.Component.Icon.name "close" ] [] ]
                        )
                    ]

                Nothing ->
                    []
    in
    M3e.formField
        [ FormField.variant Value.outlined
        , FormField.floatLabel Value.auto
        , FormField.hideSubscript Value.auto
        , TypedHtml.Attributes.class "w-max max-w-full"
        ]
        (FormField.label
            (TypedHtml.label [ TypedHtml.Attributes.for hexId ] [ M3e.text token.role ])
            :: FormField.prefix swatch
            :: TypedHtml.input
                [ TypedHtml.Attributes.id hexId
                , TypedHtml.Attributes.type_ "text"
                , TypedHtml.Attributes.value (Maybe.withDefault "" current)
                , TypedHtml.Attributes.placeholder "#RRGGBB"

                -- A floor on the width: `field-sizing-content` collapses an
                -- empty input to nothing, leaving an unset token with no visible
                -- typing target at all.
                , TypedHtml.Attributes.class "field-sizing-content min-w-[8ch] px-2"
                , TypedHtml.Events.onInput (SetColorOverride token.cssVar)
                , Aria.label ("Hex value for " ++ token.role)
                ]
                []
            :: unsetButton
        )

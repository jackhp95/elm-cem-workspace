module Theme.Sections.CssVariables exposing (view)

{-| The CSS Variables accordion section — the raw escape hatch. Renders the
NON-COLOR `@m3e/web` CSS custom properties (typescale, shape, motion, state) as
`m3e-form-field`s, clustered into collapsible categories by the hierarchy already
encoded in the variable names, so a visitor can collapse a category and jump
between them instead of scrolling one 40-row list.

Color tokens (`md-sys-color-*`) are deliberately excluded: the Color section owns
`model.colorOverrides` and writes those same properties. Keeping every token under
exactly one control is what prevents last-writer-wins conflicts on the shared
`Theme.Ports.setCssOverride` port.

Grouping: vars cluster by their first three dash-segments (the Material
sys-category — `md-sys-typescale`, `md-sys-shape`, `md-sys-motion`,
`md-sys-state`). Within a cluster we compute the longest common segment-prefix and
strip it from every field's LABEL, so labels stay short (`corner-value-medium`,
`duration-short-1`, …) while the full `--<var>` name stays visible as the field's
supporting text (`hint` slot).

Typing sets the override (`SetCssOverride`, no validation — this IS the raw
hatch); a trailing clear button, shown only when overridden, reverts it
(`UnsetCssOverride`). Elm cannot READ a live computed CSS custom property, so an
un-overridden field shows an empty input with a `(default)` placeholder rather
than the resolved default.

-}

import Dict
import M3e exposing (Element)
import M3e.Component.FormField as FormField
import M3e.Component.Icon
import Theme exposing (Msg(..))
import Theme.Tokens as Tokens
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes
import TypedHtml.Component.Details
import TypedHtml.Component.Grouping
import TypedHtml.Events


{-| The non-color CSS custom property names (without the `--` prefix): typescale,
shape, motion, and state tokens, in that order. Color tokens are excluded — see
the module comment.
-}
knownVars : List String
knownVars =
    List.map .cssVar Tokens.typescaleTokens
        ++ List.map .cssVar Tokens.shapeTokens
        ++ List.map .cssVar Tokens.motionDurationTokens
        ++ List.map .cssVar Tokens.stateOpacityTokens


{-| One hierarchy cluster: the segment prefix every member shares (stripped from
each member's label) and the members themselves.
-}
type alias VarGroup =
    { prefix : List String, vars : List String }


view : Theme.Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ TypedHtml.p [ TypedHtml.Attributes.class "text-sm text-on-surface-variant" ]
            [ M3e.text "Non-color @m3e/web CSS custom properties (typescale, shape, motion, state), grouped by name hierarchy. Color tokens live in the Color section. Type a value to override it; clear it to revert. Live default values are not shown — Elm cannot read computed CSS variables." ]
        , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col" ]
            (List.map (categoryDetails model) (groupVars knownVars))
        ]


{-| One hierarchy category as a NATIVE `<details>` disclosure, deliberately not a
nested `m3e-expansion-panel`: the settings drawer is itself an `m3e-accordion`,
and nesting expansion panels inside it makes the outer accordion re-coordinate off
the inner panels' bubbling `toggle` events, collapsing them a tick after they
open. `<details>` sidesteps that while staying collapsible and keyboard-operable.
-}
categoryDetails : Theme.Model -> VarGroup -> Element (TypedHtml.Component.Details.DetailsIs s) admittedBy Msg
categoryDetails model group =
    TypedHtml.details [ TypedHtml.Attributes.class "border-b border-outline-variant" ]
        [ TypedHtml.summary [ TypedHtml.Attributes.class "cursor-pointer list-none select-none py-2" ]
            -- A `<span>`, not an `m3e-heading`/`<h3>`: `<summary>` admits only
            -- phrasing content, and the disclosure itself is already the
            -- structural affordance. Type scale comes from the utility class.
            [ TypedHtml.span
                [ TypedHtml.Attributes.class "text-title-sm text-on-surface" ]
                [ M3e.text (categoryLabel group) ]
            ]
        , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-2 pt-2 pb-3" ]
            (List.map (cssVarField model group.prefix) group.vars)
        ]


{-| A humanised heading for a cluster: the Material sys-category (the third dash
segment of the shared prefix), title-cased.
-}
categoryLabel : VarGroup -> String
categoryLabel group =
    group.prefix
        |> List.drop 2
        |> List.head
        |> Maybe.withDefault (String.join "-" group.prefix)
        |> Theme.capitalize


{-| One CSS custom property as a form field: short label (the var name minus the
cluster's common prefix), the value input, the full `--<var>` name as supporting
text, and a trailing clear button when — and only when — it is overridden.
-}
cssVarField : Theme.Model -> List String -> String -> Element (FormField.Is s) admittedBy Msg
cssVarField model prefix cssVar =
    let
        current : Maybe String
        current =
            Dict.get cssVar model.cssOverrides

        fieldId : String
        fieldId =
            "cssvar-" ++ cssVar

        shortLabel : String
        shortLabel =
            case String.split "-" cssVar |> List.drop (List.length prefix) |> String.join "-" of
                "" ->
                    cssVar

                short ->
                    short

        clearButton : List (Element free freeAdm Msg)
        clearButton =
            case current of
                Just _ ->
                    [ FormField.suffix
                        (M3e.iconButton
                            [ TypedHtml.Events.onClick (UnsetCssOverride cssVar)
                            , Aria.label ("Clear --" ++ cssVar)
                            ]
                            [ M3e.icon [ M3e.Component.Icon.name "close" ] [] ]
                        )
                    ]

                Nothing ->
                    []
    in
    M3e.formField [ TypedHtml.Attributes.class "w-max max-w-full" ]
        (FormField.label
            (TypedHtml.label [ TypedHtml.Attributes.for fieldId ] [ M3e.text shortLabel ])
            :: FormField.hint
                (TypedHtml.span [ TypedHtml.Attributes.class "font-mono text-xs" ]
                    [ M3e.text ("--" ++ cssVar) ]
                )
            :: TypedHtml.input
                [ TypedHtml.Attributes.id fieldId
                , TypedHtml.Attributes.type_ "text"
                , TypedHtml.Attributes.value (Maybe.withDefault "" current)
                , TypedHtml.Attributes.placeholder "(default)"

                -- A floor on the width: `field-sizing-content` collapses an
                -- empty input to nothing, leaving an un-overridden var with no
                -- visible typing target.
                , TypedHtml.Attributes.class "field-sizing-content min-w-[10ch] px-2"
                , TypedHtml.Events.onInput (SetCssOverride cssVar)
                , Aria.label ("Value for --" ++ cssVar)
                ]
                []
            :: clearButton
        )



-- HIERARCHY


{-| Cluster vars by their first three dash-segments (the sys-category), preserving
first-seen order, and compute each cluster's longest common segment-prefix.
-}
groupVars : List String -> List VarGroup
groupVars vars =
    let
        categoryOf : String -> String
        categoryOf v =
            String.split "-" v |> List.take 3 |> String.join "-"
    in
    List.map
        (\cat ->
            let
                members : List String
                members =
                    List.filter (\v -> categoryOf v == cat) vars
            in
            { prefix = commonPrefix (List.map (String.split "-") members)
            , vars = members
            }
        )
        (uniqueOrder (List.map categoryOf vars))


{-| Dedupe preserving first-seen order. The lists here are tens of entries, so the
quadratic `List.member` scan is cheaper than building a `Set` and re-sorting.
-}
uniqueOrder : List String -> List String
uniqueOrder list =
    List.foldl
        (\x acc ->
            if List.member x acc then
                acc

            else
                acc ++ [ x ]
        )
        []
        list


{-| The longest common leading run of segments across every var in a cluster.
-}
commonPrefix : List (List String) -> List String
commonPrefix lists =
    case lists of
        [] ->
            []

        first :: rest ->
            List.foldl common2 first rest


common2 : List String -> List String -> List String
common2 a b =
    case ( a, b ) of
        ( x :: xs, y :: ys ) ->
            if x == y then
                x :: common2 xs ys

            else
                []

        _ ->
            []

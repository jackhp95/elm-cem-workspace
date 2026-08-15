module Compose.Render exposing (renderNode)

{-| The live preview: a pure fold from `Cem.Compose.Node` to `Html msg`.

This renders through `Html.node` because which component is on screen is
only known at runtime — no typed constructor can produce it. `tagFor` and
`Compose.Attrs.toAttribute` are what keep that plain rendering honest against
the real component/attribute vocabulary.

-}

import Cem.Compose
import Compose.Attrs as Attrs
import Html exposing (Html)
import Html.Attributes


{-| `"appBar"` → `"m3e-app-bar"`. Kebab-casing the fact's component noun is
verified to match `M3e.Html`'s own tag literals for all components, and is
deliberately NOT re-derived from `@m3e/web`'s `custom-elements.json`, which has
at least one known-bad `tagName` (`StepperNextElement` lists
`"m3e-stepper-previous"`).
-}
tagFor : String -> String
tagFor component =
    "m3e-" ++ toKebabCase component


toKebabCase : String -> String
toKebabCase input =
    input
        |> String.toList
        |> List.concatMap
            (\c ->
                if Char.isUpper c then
                    [ '-', Char.toLower c ]

                else
                    [ c ]
            )
        |> String.fromList


renderNode : Cem.Compose.Node -> Html msg
renderNode node =
    Html.node (tagFor (Cem.Compose.componentOf node))
        (List.concatMap Attrs.toAttribute (Cem.Compose.attrsOf node))
        (List.concatMap renderSlot (Cem.Compose.slotsOf node))


renderSlot : ( String, List Cem.Compose.Child ) -> List (Html msg)
renderSlot ( slotName, children ) =
    List.map
        (\child ->
            case child of
                Cem.Compose.ChildText text ->
                    Html.span (placement slotName) [ Html.text text ]

                Cem.Compose.ChildIcon glyph ->
                    Html.node "m3e-icon" (Html.Attributes.attribute "name" glyph :: placement slotName) []

                Cem.Compose.ChildNode inner ->
                    withSlot slotName inner
        )
        children


{-| The facts' name for the default slot is `"unnamed"`, and the default slot
takes no `slot=` attribute. Both folds must special-case it.
-}
placement : String -> List (Html.Attribute msg)
placement slotName =
    if slotName == "unnamed" then
        []

    else
        [ Html.Attributes.attribute "slot" slotName ]


withSlot : String -> Cem.Compose.Node -> Html msg
withSlot slotName node =
    Html.node (tagFor (Cem.Compose.componentOf node))
        (placement slotName ++ List.concatMap Attrs.toAttribute (Cem.Compose.attrsOf node))
        (List.concatMap renderSlot (Cem.Compose.slotsOf node))

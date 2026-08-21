module Good exposing (page, valueEnumeration, valueRoundTripIn, valueRoundTripOut, view)

{-| Everything that MUST compile against the generated (golden) Mini brand:
general + specific surfaces, both phantom rows, narrowing, slots, delegate,
atoms, the render boundary, and the new IR-native vocabulary (key, lazy,
decorators).
-}

import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Node
import Mini
import Mini.Attributes
import Mini.Build.Button
import Mini.Build.Chip
import Mini.Build.Icon
import Mini.Element.Button
import Mini.Element.Chip
import Mini.Element.Surface
import Mini.Events
import Mini.Kind
import Mini.Values


type Msg
    = Pressed
    | RowClicked


page : HtmlIr.Element.Element { s | surface : Mini.Kind.Brand } admittedBy Msg
page =
    Mini.surface [ Mini.Attributes.class "layout", Mini.Events.delegate (Mini.Events.onClick RowClicked) ]
        [ -- general surface, narrowed setter via specific module, named slot, event
          Mini.button
            [ Mini.Element.Button.variant Mini.Values.filled, Mini.Element.Button.onClick Pressed ]
            [ Mini.text "Save"
            , Mini.Element.Button.icon (Mini.icon [] [ Mini.text "star" ])
            ]

        -- component form: required content enforced structurally
        , Mini.Element.Button.component { content = Mini.text "Go" } [] []

        -- union setter from the general vocabulary (chip admits size)
        , Mini.chip [ Mini.Attributes.size Mini.Values.small, Mini.Element.Chip.disabled True ] [ Mini.text "tag" ]

        -- narrowed chip setter via Component module
        , Mini.Element.Chip.component [ Mini.Element.Chip.size Mini.Values.big ] [ Mini.text "big tag" ]

        -- `_variants`: the base setter keeps the spec-correct String and the
        -- AsNumber variant sits beside it, claiming the SAME capability row.
        , Mini.button [ Mini.Attributes.weight "auto" ] [ Mini.text "kw" ]
        , Mini.button [ Mini.Attributes.weightAsNumber 1.5 ] [ Mini.text "num" ]
        , Mini.Element.Button.component { content = Mini.text "narrowed num" } [ Mini.Element.Button.weightAsNumber 2 ] []

        -- the `ints` renderer, from the shared vocabulary and from the co-located
        -- per-component re-export
        , Mini.surface [ Mini.Attributes.gridAsInts [ 2, 3 ] ] []
        , Mini.Element.Surface.component [ Mini.Element.Surface.gridAsInts [ 4, 5 ], Mini.Element.Surface.grid "6x7" ] []

        -- restricted-parent element in its REQUIRED parent
        , Mini.tabs [] [ Mini.tab [] [ Mini.text "One" ] ]

        -- kind-set slot (toolbar admits @actions = button|chip)
        , Mini.toolbar []
            [ Mini.button [] [ Mini.text "act" ]
            , Mini.chip [] [ Mini.text "chip" ]
            ]

        -- IR-native `key`: attach diff keys to children; phantom rows preserved
        , Mini.chip [ Mini.Element.Chip.disabled False ]
            [ Mini.text "keyed-a" |> Mini.key "a"
            , Mini.text "keyed-b" |> Mini.key "b"
            ]

        -- `addClass`: merge a class post-hoc; phantom rows preserved
        , Mini.button [] [ Mini.text "styled" ]
            |> Mini.addClass "primary"

        -- `attrIf`: conditional attribute; phantom rows preserved
        , Mini.button [] [ Mini.text "maybe-disabled" ]
            |> Mini.attrIf True (Mini.Attributes.disabled True)

        -- `when`: collapse to empty when False; identity when True
        , Mini.chip [] [ Mini.text "conditional" ]
            |> Mini.when True

        -- `testId`: stamp a data-testid; phantom rows preserved
        , Mini.button [] [ Mini.text "submit" ]
            |> Mini.testId "submit-btn"

        -- pipe-builder family (compile-time cardinality)
        , Mini.Build.Button.build { content = Mini.text "Built" }
            |> Mini.Build.Button.withVariant Mini.Values.tonal
            |> Mini.Build.Button.withIcon Mini.Build.Icon.build
            |> Mini.Build.Button.withChild Mini.Build.Chip.build
            |> Mini.Build.Button.toElement
        , Mini.Build.Chip.build
            |> Mini.Build.Chip.withSize Mini.Values.big
            |> Mini.Build.Chip.toElement
        ]


view : Html Msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)


{-| Spec A: the out-bound direction is reachable without importing HtmlIr.Value.
-}
valueRoundTripOut : String
valueRoundTripOut =
    Mini.Values.toString Mini.Values.ltr


{-| Spec A: the in-bound direction returns the CLOSED union row, so it feeds a
setter that admits exactly that enum.
-}
valueRoundTripIn : Maybe (Mini.Values.Value Mini.Values.Dir)
valueRoundTripIn =
    Mini.Values.dirFromString "ltr"


{-| Spec A: the enumeration, so a UI built from an enum cannot silently miss a
value added to the manifest.
-}
valueEnumeration : List (Mini.Values.Value Mini.Values.Dir)
valueEnumeration =
    Mini.Values.dirValues

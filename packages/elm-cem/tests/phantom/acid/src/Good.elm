module Good exposing (page, valueEnumeration, valueRoundTripIn, valueRoundTripOut, view)

{-| Everything that MUST compile against the generated (golden) Mini brand:
general + specific surfaces, both phantom rows, narrowing, slots, coerce,
delegate, atoms, the render boundary.
-}

import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Node
import Mini
import Mini.Attributes
import Mini.Button
import Mini.Chip
import Mini.Coerce
import Mini.Events
import Mini.Icon
import Mini.Kind
import Mini.Surface
import Mini.Tab
import Mini.Tabs
import Mini.Toolbar
import Mini.Values


type Msg
    = Pressed
    | RowClicked


page : HtmlIr.Element.Element { s | surface : Mini.Kind.Brand } admittedBy Msg
page =
    Mini.surface [ Mini.Attributes.class "layout", Mini.Events.delegate (Mini.Events.onClick RowClicked) ]
        [ -- general surface, narrowed setter via specific module, named slot, event
          Mini.button
            [ Mini.Button.variant Mini.Values.filled, Mini.Button.onClick Pressed ]
            [ Mini.Button.icon (Mini.icon [] [ Mini.text "star" ])
            , Mini.text "Save"
            ]

        -- el form: required content enforced structurally
        , Mini.Button.el { content = Mini.text "Go" } [] []

        -- union setter from the general vocabulary (chip admits size)
        , Mini.chip [ Mini.Attributes.size Mini.Values.small, Mini.Chip.disabled True ] [ Mini.text "tag" ]

        -- narrowed chip setter
        , Mini.Chip.view [ Mini.Chip.size Mini.Values.big ] [ Mini.text "big tag" ]

        -- `_variants`: the base setter keeps the spec-correct String (it is the only
        -- way to write the `auto` keyword) and the AsNumber variant sits beside it,
        -- claiming the SAME capability row — so both are admitted by the same element
        -- and neither added a field to Button's Attrs.
        , Mini.button [ Mini.Attributes.weight "auto" ] [ Mini.text "kw" ]
        , Mini.button [ Mini.Attributes.weightAsNumber 1.5 ] [ Mini.text "num" ]
        , Mini.Button.view [ Mini.Button.weightAsNumber 2 ] [ Mini.text "narrowed num" ]

        -- the `ints` renderer, from the shared vocabulary and from the co-located
        -- per-component re-export
        , Mini.surface [ Mini.Attributes.gridAsInts [ 2, 3 ] ] []
        , Mini.Surface.view [ Mini.Surface.gridAsInts [ 4, 5 ], Mini.Surface.grid "6x7" ] []

        -- restricted-parent element in its REQUIRED parent
        , Mini.tabs [] [ Mini.tab [] [ Mini.text "One" ] ]

        -- kind-set slot (toolbar admits @actions = button|chip) + coerce
        , Mini.toolbar []
            [ Mini.button [] [ Mini.text "act" ]
            , Mini.chip [] [ Mini.text "chip" ]
            ]
        , Mini.Coerce.asButton (Mini.chip [] [ Mini.text "promoted" ])

        -- the pipe-builder family (compile-time cardinality)
        , Mini.Button.build { content = Mini.text "Built" }
            |> Mini.Button.withVariant Mini.Values.tonal
            |> Mini.Button.withIcon (Mini.icon [] [ Mini.text "gear" ])
            |> Mini.Button.withChild (Mini.text "extra")
            |> Mini.Button.toElement
        , Mini.Chip.build
            |> Mini.Chip.withSize Mini.Values.big
            |> Mini.Chip.toElement
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

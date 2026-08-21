module Good exposing (page, view)

{-| The native brand's MUST-COMPILE case: element homes, both phantom rows,
transparent `<a>` threading, R1 shared parents (option+optgroup), the R2
source/pictureSource split, ARIA hybrid (typed role + value-typed state +
universal), and the render boundary.
-}

import Html
import HtmlIr.Element
import HtmlIr.Node
import TypedHtml as H
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as At
import TypedHtml.Events as Ev
import TypedHtml.Element.Grouping
import TypedHtml.Element.Select
import TypedHtml.Kind


type Msg
    = Never_
    | Picked String


page : HtmlIr.Element.Element (TypedHtml.Element.Grouping.DivIs s) admittedBy Msg
page =
    H.div [ At.class "layout", Aria.role Aria.navigation, Aria.label "Main" ]
        [ -- phrasing nesting + transparent <a> carrying phrasing inside <p>
          H.p [] [ H.span [] [ H.text "hello " ], H.a [ At.href "/x" ] [ H.span [] [ H.text "link" ] ] ]

        -- transparent <a> carrying BLOCK content, legal because div admits it
        , H.a [ At.href "/y" ] [ H.p [] [ H.text "block link content" ] ]

        -- R1: option+optgroup share one parents set; both legal in select.
        --
        -- `At.size 3` is the `integer` CEM spelling arriving as `Int -> Attr`. An Int
        -- LITERAL is the case that matters: it is what a caller writes, and while
        -- `size 3` typechecked when the setter was `Float` too, `size 2.5` did as
        -- well — see acid bad/SizeFloat.
        , H.select [ At.disabled True, At.size 3, Ev.onChange Picked ]
            [ H.option [ At.value "1" ] [ H.text "One" ]
            , H.optgroup [] [ H.option [] [ H.text "Two" ] ]
            ]

        -- `_variants` over a CONTROLLED base: `value`, its `defaultValue` content-attribute
        -- companion and the `valueAsNumber` ergonomic form all claim ONE capability row,
        -- so an element that admits `value` admits every way of writing it and no `Attrs`
        -- record grew a field.
        , H.select []
            [ H.option [ At.valueAsNumber 1 ] [ H.text "num" ]
            , H.option [ At.defaultValue "2" ] [ H.text "default" ]
            , TypedHtml.Element.Select.option [ TypedHtml.Element.Select.valueAsNumber 3 ] [ H.text "narrowed num" ]
            ]

        -- restricted legend in its required fieldset context
        , H.fieldset [] [ H.legend [] [ H.text "Group" ], H.div [] [] ]

        -- R2 split: source+track in video…
        , H.video [] [ H.source [ At.src "v.mp4" ] [], H.track [ At.src "v.vtt" ] [], H.text "fallback" ]

        -- …and pictureSource (same tag!) in picture
        , H.picture [] [ H.pictureSource [ At.srcset "a.png" ] [] ]

        -- value-typed universal aria state on any element
        , H.span [ Aria.checked Aria.mixed ] [ H.text "tristate" ]
        ]


view : Html.Html Msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)

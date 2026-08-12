module Good exposing (page, view)

{-| The payoff case: native and m3e content nest on ONE `Element` type with no
conversion — cross-brand layout, shared atoms in a brand slot, global attrs and
events across brands, typed enums, slot placement, coerce, delegate, map, and
the render boundary. MUST compile.
-}

import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Node
import MiniM3e as M
import MiniNative as N


type Msg
    = Saved
    | RowClicked


page : HtmlIr.Element.Element { acc | div : N.NativeKind } admittedBy Msg
page =
    N.div [ N.class "layout", N.delegate (N.onClick RowClicked) ]
        [ M.button [ N.class "cta", M.variant M.filled, N.onClick Saved ]
            [ M.placeIcon (M.icon "star")
            , N.text "Save"
            ]
        , N.select [] [ N.option [] [ N.text "One" ] ]
        , M.asButton (M.chip "promoted")
        , HtmlIr.Element.map identity (N.text "mapped")
        , N.keyedList
            [ ( "row-1", N.text "first" )
            , ( "row-2", M.chip "second" )
            ]
        ]


view : Html Msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)

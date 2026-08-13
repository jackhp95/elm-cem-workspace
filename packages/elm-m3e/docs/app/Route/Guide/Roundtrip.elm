module Route.Guide.Roundtrip exposing (ActionData, Data, Model, Msg, route)

{-| Round-trip verification report (`data/roundtrip-report.json`). Renders a
per-form summary of the HTML → Elm → HTML round-trip harness plus every cell,
ranked deviations-first. An internal-facing transparency page — utilitarian by
design, no per-component doc shell.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Json.Decode as Decode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Card
import M3e.Component.Heading
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Sectioning
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias SurfaceAgg =
    { total : Int
    , converted : Int
    , clean : Int
    , usedEscapeHatch : Int
    , roundtripMatched : Int
    , roundtripDeviated : Int
    , roundtripFunctionalMatched : Int
    , roundtripFunctionalDeviated : Int
    }


type alias Cell =
    { id : String
    , surface : String
    , title : String
    , converted : Bool
    , seam : Int
    , native : Int
    , charsInside : Int
    , matches : Maybe Bool
    , functionalMatches : Maybe Bool
    , deviationCount : Int
    }


type alias Data =
    { perSurface : List ( String, SurfaceAgg )
    , cells : List Cell
    }


type alias ActionData =
    {}



-- DECODERS


surfaceAggDecoder : Decode.Decoder SurfaceAgg
surfaceAggDecoder =
    Decode.map8 SurfaceAgg
        (Decode.field "total" Decode.int)
        (Decode.field "converted" Decode.int)
        (Decode.field "clean" Decode.int)
        (Decode.field "usedEscapeHatch" Decode.int)
        (Decode.field "roundtripMatched" Decode.int)
        (Decode.field "roundtripDeviated" Decode.int)
        (Decode.oneOf [ Decode.field "roundtripFunctionalMatched" Decode.int, Decode.succeed 0 ])
        (Decode.oneOf [ Decode.field "roundtripFunctionalDeviated" Decode.int, Decode.succeed 0 ])


type alias Roundtrip =
    { matches : Bool, functionalMatches : Bool, deviations : List Decode.Value }


roundtripDecoder : Decode.Decoder Roundtrip
roundtripDecoder =
    Decode.map3 Roundtrip
        (Decode.field "matches" Decode.bool)
        (Decode.oneOf [ Decode.field "functionalMatches" Decode.bool, Decode.field "matches" Decode.bool ])
        (Decode.field "deviations" (Decode.list Decode.value))


cellDecoder : Decode.Decoder Cell
cellDecoder =
    Decode.map8
        (\id surface title converted seam native charsInside rt ->
            { id = id
            , surface = surface
            , title = title
            , converted = converted
            , seam = seam
            , native = native
            , charsInside = charsInside
            , matches = Maybe.map .matches rt
            , functionalMatches = Maybe.map .functionalMatches rt
            , deviationCount =
                rt
                    |> Maybe.map (.deviations >> List.length)
                    |> Maybe.withDefault 0
            }
        )
        (Decode.field "id" Decode.string)
        (Decode.field "surface" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "converted" Decode.bool)
        (Decode.at [ "escapeHatch", "seam", "count" ] Decode.int)
        (Decode.at [ "escapeHatch", "native", "count" ] Decode.int)
        (Decode.at [ "escapeHatch", "charsInside" ] Decode.int)
        (Decode.field "roundtrip" (Decode.nullable roundtripDecoder))


{-| Canonical form display order; anything unrecognised falls to the end.
-}
surfaceOrder : List String
surfaceOrder =
    [ "top", "record", "build", "barrel" ]


orderSurfaces : List ( String, SurfaceAgg ) -> List ( String, SurfaceAgg )
orderSurfaces pairs =
    let
        rank : String -> Int
        rank name =
            case indexOf name surfaceOrder of
                Just i ->
                    i

                Nothing ->
                    List.length surfaceOrder
    in
    List.sortBy (\( name, _ ) -> rank name) pairs


indexOf : a -> List a -> Maybe Int
indexOf target xs =
    xs
        |> List.indexedMap Tuple.pair
        |> List.filter (\( _, x ) -> x == target)
        |> List.head
        |> Maybe.map Tuple.first


dataDecoder : Decode.Decoder Data
dataDecoder =
    Decode.map2 Data
        (Decode.field "perSurface" (Decode.keyValuePairs surfaceAggDecoder)
            |> Decode.map orderSurfaces
        )
        (Decode.field "cells" (Decode.list cellDecoder))



-- ROUTE


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.jsonFile dataDecoder "data/roundtrip-report.json"
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image =
            { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-m3e"
            , dimensions = Just { width = 1200, height = 630 }
            , mimeType = Just (MimeType.Image MimeType.Png)
            }
        , description = "Round-trip verification report: HTML → Elm → HTML fidelity across every elm-m3e API."
        , locale = Nothing
        , title = "Round-trip report · elm-m3e"
        }
        |> Seo.website



-- RANKING


rankedCells : List Cell -> List Cell
rankedCells cells =
    let
        -- Rank on FUNCTIONAL deviations: true functional mismatches surface
        -- first, then escape-hatch users, then cosmetic-only deviations, then
        -- fully clean cells. A cosmetic-only-deviating cell (functionalMatches
        -- True, matches False) ranks below a genuine functional deviation.
        rank : Cell -> Int
        rank c =
            if c.functionalMatches == Just False then
                0

            else if c.charsInside > 0 then
                1

            else if c.matches == Just False then
                2

            else
                3
    in
    List.sortBy (\c -> ( rank c, negate c.charsInside )) cells



-- VIEW


pageHeading : Element { s | heading : M3e.Kind.Brand } admittedBy msg
pageHeading =
    M3e.heading
        [ M3e.Component.Heading.variant Value.display
        , M3e.Component.Heading.size Value.small
        , M3e.Attributes.level 1
        ]
        [ M3e.text "Round-trip report" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromElement "Round-trip report"
        (Doc.pane
            [ pageHeading
            , TypedHtml.div [ TA.class "mt-2 max-w-2xl" ]
                [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "Every example is converted from HTML to Elm and back to HTML. This page reports, per API, how many examples convert, stay clean of escape hatches, and survive the round-trip. A clean round-trip means no functional deviations — cosmetic differences (class/style, unreferenced ids, and typed-layer role/slot normalization) are recorded but not scored. Cells are ranked functional-deviations-first so real regressions surface at the top." ]
                ]
            , surfaceLegend
            , summarySection app.data.perSurface
            , cellsSection app.data.cells
            ]
        )


{-| Legend mapping this page's row names (top/record/build/barrel) to the Guide's
vocabulary, so the form names aren't undefined jargon. `top`/`record`/`build`/`barrel`
are the four interchangeable [surfaces](/guide/the-layers).
-}
surfaceLegend : Element (TypedHtml.Sectioning.SectionIs s) adm_ msg
surfaceLegend =
    TypedHtml.section
        [ TA.class "mt-8 max-w-2xl rounded-md-corner-medium bg-surface-container p-4 space-y-2" ]
        [ TypedHtml.p [ TA.class "text-label-lg tracking-wide text-primary" ] [ M3e.text "What the form names mean" ]
        , TypedHtml.div [ TA.class "text-on-surface-variant" ] [ Doc.markdown surfaceLegendText ]
        ]


surfaceLegendText : String
surfaceLegendText =
    """Each row is one API **surface** — a call *shape* for the same typed value, not a rank. The names are the harness's original column keys; the [surface map](/guide/the-layers) is the current vocabulary.

| Row | What it is | Surface map |
| --- | --- | --- |
| **top** | `M3e.Component.Button.view` — the standard form: typed, slot-safe, composes anywhere. | the standard `view` surface ([surface map](/guide/the-layers)) |
| **record** | `M3e.Component.Button.el { … }` — the required-record form: the parts a component can't omit are demanded by the compiler (the 29 components that have a required record). | the `el` surface ([surface map](/guide/the-layers)) |
| **build** | `M3e.Build.Button.build { … }` piped through `M3e.Build.Button.toElement` — one-only setters unwritable twice, order-free. | the `build` surface ([surface map](/guide/the-layers)) |
| **barrel** | `M3e.button` — one import that re-exports every component's `view`, with the shared `M3e.Attributes.variant Value.filled` vocabulary. | the barrel surface the Guide teaches ([reference](/guide/reference)) |

These are **peers, not a ranking** — interchangeable call shapes that all produce the same slottable value."""


summarySection : List ( String, SurfaceAgg ) -> Element (TypedHtml.Sectioning.SectionIs s) adm_ msg
summarySection perSurface =
    TypedHtml.section
        [ TA.class "mt-12 space-y-4" ]
        [ M3e.heading
            [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, M3e.Attributes.level 2 ]
            [ M3e.text "Per-form summary" ]
        , TypedHtml.div [ TA.class "space-y-3" ]
            (List.map surfaceRow perSurface)
        ]


surfaceRow : ( String, SurfaceAgg ) -> Element { s | card : M3e.Kind.Brand } admittedBy msg
surfaceRow ( name, agg ) =
    M3e.card
        [ M3e.Component.Card.variant Value.outlined ]
        [ M3e.Component.Card.content
            (TypedHtml.div
                [ TA.class "space-y-1" ]
                [ TypedHtml.div
                    []
                    [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class "text-primary" ] [ M3e.text name ] ]
                , TypedHtml.span [ TA.class "text-body-md text-on-surface-variant" ]
                    [ M3e.text
                        (String.fromInt agg.converted
                            ++ " / "
                            ++ String.fromInt agg.total
                            ++ " converted · "
                            ++ String.fromInt agg.clean
                            ++ " clean · "
                            ++ String.fromInt agg.usedEscapeHatch
                            ++ " used escape hatch"
                        )
                    ]
                , TypedHtml.span [ TA.class "text-body-md" ]
                    [ M3e.text
                        (String.fromInt agg.roundtripFunctionalMatched
                            ++ " functional clean · "
                            ++ String.fromInt agg.roundtripFunctionalDeviated
                            ++ " functional deviated"
                        )
                    ]
                , TypedHtml.span [ TA.class "text-body-sm text-on-surface-variant" ]
                    [ M3e.text
                        ("(strict: "
                            ++ String.fromInt agg.roundtripMatched
                            ++ " matched · "
                            ++ String.fromInt agg.roundtripDeviated
                            ++ " deviated)"
                        )
                    ]
                ]
            )
        ]


cellsSection : List Cell -> Element (TypedHtml.Sectioning.SectionIs s) adm_ msg
cellsSection cells =
    TypedHtml.section
        [ TA.class "mt-12 space-y-4" ]
        [ M3e.divider [] []
        , M3e.heading
            [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, M3e.Attributes.level 2 ]
            [ M3e.text "Cells (deviations first)" ]
        , TypedHtml.div [ TA.class "space-y-3" ]
            (List.map cellRow (rankedCells cells))
        ]


cellRow : Cell -> Element { s | card : M3e.Kind.Brand } admittedBy msg
cellRow c =
    let
        deviationText : String
        deviationText =
            if not c.converted then
                "not converted"

            else
                case c.functionalMatches of
                    Just False ->
                        String.fromInt c.deviationCount ++ " deviation(s), functional"

                    Just True ->
                        if c.matches == Just False then
                            String.fromInt c.deviationCount ++ " cosmetic deviation(s)"

                        else
                            "round-trip matched"

                    Nothing ->
                        "round-trip not run"

        escapeText : String
        escapeText =
            "seam " ++ String.fromInt c.seam ++ " · native " ++ String.fromInt c.native ++ " · chars " ++ String.fromInt c.charsInside

        deviationColor : String
        deviationColor =
            if c.functionalMatches == Just False then
                "text-error"

            else
                "text-on-surface-variant"
    in
    M3e.card
        [ M3e.Component.Card.variant Value.outlined ]
        [ M3e.Component.Card.content
            (TypedHtml.div
                [ TA.class "space-y-1" ]
                [ TypedHtml.div
                    []
                    [ TypedHtml.span [ TA.class "text-title-md" ]
                        [ TypedHtml.code [] [ M3e.text c.id ] ]
                    ]
                , TypedHtml.span [ TA.class ("text-body-md " ++ deviationColor) ] [ M3e.text deviationText ]
                , TypedHtml.span [ TA.class "text-body-sm text-on-surface-variant" ] [ M3e.text escapeText ]
                ]
            )
        ]

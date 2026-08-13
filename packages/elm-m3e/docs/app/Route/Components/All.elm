module Route.Components.All exposing (ActionData, Data, Model, Msg, route)

{-| The **kitchen-sink** page (`/components/all`): every component's Usage section
stacked on one page, in the same category order the drawer uses. Each component's
block is `id`-anchored (so `/components/all#button` deep-links straight to it) and
carries the hand-authored `.cv-auto` class (`content-visibility: auto`) so the
browser skips laying out off-screen blocks — 329 examples stay snappy.

The tab state for every example lives in one shared `Usage.Model`, keyed by a
page-global index. Each component is rendered with a **running offset** equal to
the count of examples already placed, so no two components' tab strips share an
index — their selections stay independent.

-}

import BackendTask exposing (BackendTask)
import Dict exposing (Dict)
import Doc
import Doc.Data exposing (Component, allComponents, allUsage)
import Doc.Usage as Usage exposing (UsageExample)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Events
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Grouping
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { usage : Usage.Model
    , revealed : Bool
    }


type Msg
    = UsageMsg Usage.Msg
    | Reveal


type alias RouteParams =
    {}


type alias Data =
    { components : List Component, usage : Dict String (List UsageExample) }


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


data : BackendTask FatalError Data
data =
    BackendTask.map2 Data allComponents allUsage


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init app _ =
    -- Deep-links (`/components/all#button`) carry a URL fragment; reveal the
    -- stacked content immediately so the browser can scroll to the anchor.
    ( { usage = Usage.init
      , revealed = app.url |> Maybe.andThen .fragment |> (/=) Nothing
      }
    , Effect.none
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        UsageMsg um ->
            ( { model | usage = Usage.update um model.usage }, Effect.none )

        Reveal ->
            ( { model | revealed = True }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


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
        , description = "Every elm-m3e component's Usage examples stacked on one kitchen-sink page."
        , locale = Nothing
        , title = "All components · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app _ model =
    let
        heading : Element { s | html : M3e.Kind.Brand, heading : M3e.Kind.Brand } adm_ Msg
        heading =
            M3e.heading
                [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
                [ M3e.text "All components" ]

        content : List (Element (TypedHtml.Grouping.DivIs s) adm_ Msg)
        content =
            if model.revealed then
                stackedBlocks model.usage app.data
                    |> List.map (M3e.mapMsg UsageMsg)

            else
                [ overview app.data ]
    in
    View.fromElement "All components"
        (M3e.mapMsg PagesMsg.fromMsg
            (Doc.pane
                [ TypedHtml.div [ TA.class "space-y-12" ] (heading :: content) ]
            )
        )


{-| The opt-in gate shown before the user reveals the stacked kitchen sink.

Rendering every component's live examples up front upgrades ~1800 custom
elements at once (~30s to interactive), so we defer that cost: a short blurb,
a summary line, the category names, and a **Show all components** button that
flips `revealed` on click.

-}
overview : Data -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
overview d =
    let
        withExamples : List Component
        withExamples =
            d.components
                |> List.filter
                    (\c ->
                        Dict.get c.slug d.usage
                            |> Maybe.withDefault []
                            |> List.isEmpty
                            |> not
                    )

        exampleCount : Int
        exampleCount =
            d.usage |> Dict.values |> List.map List.length |> List.sum

        -- Two honest, distinct counts (issue #188): `withExamples` is how many
        -- documented components carry at least one live Usage example; the home
        -- page's headline count is the full documented catalogue (every
        -- categorised component in `data/reference.json`). They differ when a
        -- component is documented but has no runnable example yet — we say so
        -- rather than round them to look equal.
        catalogueCount : Int
        catalogueCount =
            d.components |> List.filter (\c -> c.category /= "") |> List.length

        summary : String
        summary =
            String.fromInt (List.length withExamples)
                ++ " of "
                ++ String.fromInt catalogueCount
                ++ " documented components have live examples · "
                ++ String.fromInt exampleCount
                ++ " examples · "
                ++ String.fromInt (List.length Shared.componentCategories)
                ++ " categories"
    in
    TypedHtml.div [ TA.class "max-w-2xl space-y-6" ]
        [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
            [ M3e.text "This page stacks every component's live Usage examples on a single page. Loading them all at once upgrades hundreds of interactive custom elements, so it can take a moment to become fully interactive." ]
        , TypedHtml.p [ TA.class "text-body-md text-on-surface" ]
            [ M3e.text summary ]
        , TypedHtml.p [ TA.class "text-body-md text-on-surface-variant" ]
            [ M3e.text (Shared.componentCategories |> List.map Tuple.first |> String.join " · ") ]
        , TypedHtml.button
            [ M3e.Events.onClick Reveal
            , TA.class "inline-flex items-center rounded-full bg-primary px-6 py-3 text-label-lg text-on-primary hover:opacity-90 cursor-pointer"
            ]
            [ M3e.text "Show all components" ]
        ]


{-| Every component's Usage section, ordered by `Shared.componentCategories`, each
wrapped in an `id`-anchored `.cv-auto` block. A running offset (the count of
examples already placed) is threaded through `Usage.usageBlocks` so each
component's tab strips occupy a disjoint index range in the shared model.
-}
stackedBlocks : Usage.Model -> Data -> List (Element (TypedHtml.Grouping.DivIs s) adm_ Usage.Msg)
stackedBlocks model d =
    let
        orderedComponents : List Component
        orderedComponents =
            Shared.componentCategories
                |> List.concatMap (\( category, _ ) -> List.filter (\c -> c.category == category) d.components)

        step : Component -> ( Int, List (Element (TypedHtml.Grouping.DivIs s) adm_ Usage.Msg) ) -> ( Int, List (Element (TypedHtml.Grouping.DivIs s) adm_ Usage.Msg) )
        step component ( offset, acc ) =
            let
                examples : List UsageExample
                examples =
                    Dict.get component.slug d.usage |> Maybe.withDefault []

                block : List (Element (TypedHtml.Grouping.DivIs s) adm_ Usage.Msg)
                block =
                    if List.isEmpty examples then
                        []

                    else
                        [ TypedHtml.div
                            [ TA.id component.slug
                            , TA.class "cv-auto space-y-6 scroll-mt-24"
                            ]
                            (M3e.heading
                                [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.medium, M3e.Attributes.level 2 ]
                                [ M3e.text component.name ]
                                :: Usage.usageBlocks offset model examples
                            )
                        ]
            in
            ( offset + List.length examples, acc ++ block )
    in
    List.foldl step ( 0, [] ) orderedComponents |> Tuple.second

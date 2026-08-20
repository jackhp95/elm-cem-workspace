module Route.Guide.Glossary exposing (ActionData, Data, Model, Msg, route)

{-| Guide · Glossary (`/guide/glossary`): the vocabulary spine. One canonical
place for the kept terms, each defined in plain words — the same glosses the
chapters use on first mention. Insider jargon is deliberately absent; this is
the reader's dictionary, not the maintainer's.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/Glossary.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "The Guide glossary: the kept terms — surface, loose producer, escape, barrel, component module, shared/per-component vocabulary, kind, slot, token, seam, component facts, manifest — each defined in plain words."
        , locale = Nothing
        , title = "Glossary · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        terms : String
        terms =
            Doc.section "terms" d
    in
    View.fromElement "Glossary"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-8" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Glossary"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown terms ]
                ]
            ]
        )

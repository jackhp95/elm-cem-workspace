module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Head
import Head.Seo as Seo
import M3e
import M3e.Component.Button
import M3e.Values as Value
import MimeType
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
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Head.nonLoadingNode "meta"
        [ ( "http-equiv", Head.raw "refresh" )
        , ( "content", Head.raw "0;url=/getting-started/welcome" )
        ]
        :: (Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "elm-m3e"
                , image =
                    { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
                    , alt = "elm-m3e"
                    , dimensions = Just { width = 1200, height = 630 }
                    , mimeType = Just (MimeType.Image MimeType.Png)
                    }
                , description = "Type-safe Material 3 Expressive web components for Elm."
                , locale = Nothing
                , title = "elm-m3e"
                }
                |> Seo.website
           )


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "elm-m3e"
        (TypedHtml.div [ TA.class "flex flex-col items-center justify-center gap-4 p-8" ]
            [ TypedHtml.p []
                [ M3e.text "Redirecting to Welcome…" ]
            , M3e.button
                [ M3e.Component.Button.variant Value.filled
                , M3e.Component.Button.href "/getting-started/welcome"
                ]
                [ M3e.text "Go to Welcome" ]
            ]
        )

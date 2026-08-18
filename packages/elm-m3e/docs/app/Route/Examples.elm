module Route.Examples exposing (ActionData, Data, Model, Msg, route)

{-| Landing page for the Examples area — composed, real-world app screens showing
many `M3e.*` components working together. The five examples are responsive routes
that the sidebar links to; this page is the gallery.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Button
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
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image =
            { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-m3e"
            , dimensions = Just { width = 1200, height = 630 }
            , mimeType = Just (MimeType.Image MimeType.Png)
            }
        , description = "Composed, real-world app screens built with elm-m3e."
        , locale = Nothing
        , title = "Examples · elm-m3e"
        }
        |> Seo.website


examples : List ( String, String, String )
examples =
    [ ( "dashboard", "Dashboard", "An analytics dashboard — adaptive navigation, KPI stat cards with trend deltas, budget meters via progress indicators, and a recent-activity data table." )
    , ( "shop", "Shop", "An e-commerce storefront — filter chips, a responsive product-card grid with shape-clipped media, a cart badge in the app bar, and quick actions." )
    , ( "mail", "Mail", "An email client — adaptive navigation, a message list beside a reading pane that stacks on mobile, labels as chips, and a compose FAB." )
    , ( "travel", "Travel", "A trip-planning app — a search hero, horizontally scrolling destination rails, category tabs, and richly-composed destination cards." )
    , ( "settings", "Settings", "A system settings surface — sectioned preference groups built from list items, switches, radios, sliders, and dividers." )
    , ( "list-detail", "List-detail", "The canonical adaptive list-detail pattern — a contacts list beside a detail pane on desktop that reflows to a single column on mobile, with nav-rail↔nav-bar switching." )
    , ( "supporting-pane", "Supporting pane", "The adaptive supporting-pane pattern — a wide primary region with a narrower supporting pane that sits beside it on expanded windows and reflows beneath on compact." )
    , ( "feed", "Feed", "The adaptive feed pattern — a responsive card grid whose column count grows with the window size class, driven by a filter-chip toolbar." )
    ]


pageHeading : Element { s | heading : M3e.Kind.Brand } admittedBy msg
pageHeading =
    M3e.heading
        [ M3e.Component.Heading.variant Value.display
        , M3e.Component.Heading.size Value.small
        , M3e.Attributes.level 1
        ]
        [ M3e.text "Examples" ]


exampleCard : ( String, String, String ) -> Element { s | card : M3e.Kind.Brand } admittedBy msg
exampleCard ( slug, cardTitle, cardBody ) =
    let
        exampleHref : String
        exampleHref =
            "/examples/" ++ slug
    in
    M3e.card
        [ M3e.Component.Card.variant Value.elevated ]
        [ M3e.Component.Card.header (M3e.heading [ M3e.Component.Heading.variant Value.title ] [ M3e.text cardTitle ])
        , M3e.Component.Card.content (TypedHtml.p [] [ M3e.text cardBody ])
        , M3e.Component.Card.actions
            (M3e.button
                [ M3e.Component.Button.variant Value.filled, M3e.Component.Button.href exampleHref ]
                [ M3e.text ("Open " ++ cardTitle) ]
            )
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Examples"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p []
                        [ M3e.text "Examples are composed, real-world app screens that show many elm-m3e components working together — the way the library is meant to be used. Each one is a real, responsive route, not a screenshot." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "grid gap-4 sm:grid-cols-2" ]
                (List.map exampleCard examples)
            ]
        )

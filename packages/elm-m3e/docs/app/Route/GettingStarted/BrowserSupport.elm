module Route.GettingStarted.BrowserSupport exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Card
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
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
        , description = "Browser support for @m3e/web and elm-m3e."
        , locale = Nothing
        , title = "Browser Support · elm-m3e"
        }
        |> Seo.website


supportRow : String -> String -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
supportRow browser note =
    TypedHtml.div [ TA.class "flex items-baseline justify-between gap-4 py-2.5" ]
        [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text browser ]
        , TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ] [ M3e.text note ]
        ]


featureItem : String -> Element (TypedHtml.Component.Grouping.LiIs s) TypedHtml.Component.Grouping.LiAdmittedBy msg
featureItem note =
    TypedHtml.li [] [ TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ] [ M3e.text note ] ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Browser Support" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Browser Support"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "elm-m3e renders @m3e/web custom elements, so it runs anywhere standard Web Components and ES modules run — the modern-browser baseline." ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Supported browsers") "Supported browsers"
                , M3e.card
                    [ M3e.Attributes.variant Value.outlined ]
                    [ M3e.Component.Card.content
                        (TypedHtml.div [ TA.class "flex flex-col px-2" ]
                            (List.intersperse (M3e.divider [] [])
                                [ supportRow "Chrome / Edge" "Latest 2 versions"
                                , supportRow "Firefox" "Latest 2 versions"
                                , supportRow "Safari" "Latest 2 versions"
                                , supportRow "Mobile Safari / Chrome Android" "Latest 2 versions"
                                ]
                            )
                        )
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Platform features used") "Platform features used"
                , TypedHtml.ul [ TA.class "list-disc space-y-1.5 pl-5" ]
                    [ featureItem "Custom Elements v1 and Shadow DOM for the @m3e/web components."
                    , featureItem "ES modules for component registration (no-bundler import-map usage is also supported upstream)."
                    , featureItem "CSS custom properties and the light-dark() function for the M3 token cascade and dark mode."
                    , featureItem "Variable fonts for the self-hosted Material Symbols icon axes."
                    ]
                ]
            ]
        )

module Route.Styles.Typography exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Doc
import Head
import Head.Seo as Seo
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
import TypedHtml.Component.Grouping
import TypedHtml.Kind
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
        , description = "The M3 type scale, rendered live."
        , locale = Nothing
        , title = "Typography · elm-m3e"
        }
        |> Seo.website


{-| The 15 M3 type-scale roles, each a live exhibit (the matching typed
producer), the Tailwind class it maps to, and the role's concrete
font-size / line-height / weight from `--md-sys-typescale-*` (see
`sys/typescale.css`). The demo dogfoods the producers: the exhibit _is_
`M3e.heading` (display/headline/title/label) / `TypedHtml.span` (body).
-}
scale : List ( Element (M3e.Component.Heading.Is { a | sharedPhrasing : TypedHtml.Kind.Shared }) admittedBy msg, String, String )
scale =
    [ ( M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Display Large" ], "text-display-lg", "3.5625rem / 4rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Display Medium" ], "text-display-md", "2.8125rem / 3.25rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Display Small" ], "text-display-sm", "2.25rem / 2.75rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Headline Large" ], "text-headline-lg", "2rem / 2.5rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Headline Medium" ], "text-headline-md", "1.75rem / 2.25rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Headline Small" ], "text-headline-sm", "1.5rem / 2rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Title Large" ], "text-title-lg", "1.375rem / 1.75rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Title Medium" ], "text-title-md", "1rem / 1.5rem · 500" )
    , ( M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Title Small" ], "text-title-sm", "0.875rem / 1.25rem · 500" )
    , ( TypedHtml.span [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "Body Large" ], "text-body-lg", "1rem / 1.5rem · 400" )
    , ( TypedHtml.span [ TA.class "text-body-md text-on-surface" ] [ M3e.text "Body Medium" ], "text-body-md", "0.875rem / 1.25rem · 400" )
    , ( TypedHtml.span [ TA.class "text-body-sm text-on-surface" ] [ M3e.text "Body Small" ], "text-body-sm", "0.75rem / 1rem · 400" )
    , ( M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Label Large" ], "text-label-lg", "0.875rem / 1.25rem · 500" )
    , ( M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Label Medium" ], "text-label-md", "0.75rem / 1rem · 500" )
    , ( M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Label Small" ], "text-label-sm", "0.6875rem / 1rem · 500" )
    ]


row : ( Element (TypedHtml.Component.Grouping.DivIs { a | heading : M3e.Kind.Brand, sharedPhrasing : TypedHtml.Kind.Shared }) (TypedHtml.Component.Grouping.DivChildAdmittedBy childAdm) msg, String, String ) -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
row ( exhibit, cls, metrics ) =
    TypedHtml.div [ TA.class "flex flex-wrap items-baseline justify-between gap-2 py-3" ]
        [ exhibit
        , TypedHtml.div [ TA.class "flex flex-col items-end" ]
            [ TypedHtml.code [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text cls ]
            , TypedHtml.code [ TA.class "text-body-sm text-on-surface-variant" ] [ M3e.text metrics ]
            ]
        ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Typography" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Typography"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "The M3 type scale has 15 standard roles (display, headline, title, body, label — each large/medium/small), each encoding font-size, line-height, weight, and tracking via --md-sys-typescale-* tokens. The bridge maps every role to a Tailwind utility. Each row below shows its font-size / line-height · weight from the tokens." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "The scale, live") "The scale, live"
                , M3e.card
                    [ M3e.Attributes.variant Value.outlined ]
                    [ M3e.Component.Card.content
                        (TypedHtml.div [ TA.class "flex flex-col px-2" ]
                            (List.intersperse (M3e.divider [] []) (List.map row scale))
                        )
                    ]
                ]
            ]
        )

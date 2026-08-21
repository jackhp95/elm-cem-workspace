module Route.Styles.Typography exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Json.Decode as Decode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Element.Card
import M3e.Element.Heading
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Element.Grouping
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
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


{-| The per-role metrics string (`font-size / line-height · weight`), keyed by
Tailwind class, derived at build time from `--md-sys-typescale-*` by
`scripts/gen-style-tokens.mjs` (-> `data/style-tokens.json`). The live exhibits
and their classes stay structural in `scale`; only the drift-prone metric
literals are sourced from the token manifest.
-}
data : BackendTask FatalError Data
data =
    BackendTask.File.jsonFile
        (Decode.field "typography"
            (Decode.list
                (Decode.map2 Tuple.pair
                    (Decode.field "class" Decode.string)
                    (Decode.field "metrics" Decode.string)
                )
                |> Decode.map Dict.fromList
            )
        )
        "data/style-tokens.json"
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
        , description = "The M3 type scale, rendered live."
        , locale = Nothing
        , title = "Typography · elm-m3e"
        }
        |> Seo.website


{-| The 15 M3 type-scale roles, each a live exhibit (the matching typed
producer) and the Tailwind class it maps to. The role's concrete
font-size / line-height / weight is NOT hand-typed here — it is looked up per
class from `data/style-tokens.json` (derived from `--md-sys-typescale-*`, see
`scripts/gen-style-tokens.mjs`). The demo dogfoods the producers: the exhibit
_is_ `M3e.heading` (display/headline/title/label) / `TypedHtml.span` (body).
-}
scale : List ( Element (M3e.Element.Heading.Is { a | sharedPhrasing : TypedHtml.Kind.Shared }) admittedBy msg, String )
scale =
    [ ( M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Display Large" ], "text-display-lg" )
    , ( M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Display Medium" ], "text-display-md" )
    , ( M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Display Small" ], "text-display-sm" )
    , ( M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Headline Large" ], "text-headline-lg" )
    , ( M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Headline Medium" ], "text-headline-md" )
    , ( M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Headline Small" ], "text-headline-sm" )
    , ( M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Title Large" ], "text-title-lg" )
    , ( M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Title Medium" ], "text-title-md" )
    , ( M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Title Small" ], "text-title-sm" )
    , ( TypedHtml.span [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "Body Large" ], "text-body-lg" )
    , ( TypedHtml.span [ TA.class "text-body-md text-on-surface" ] [ M3e.text "Body Medium" ], "text-body-md" )
    , ( TypedHtml.span [ TA.class "text-body-sm text-on-surface" ] [ M3e.text "Body Small" ], "text-body-sm" )
    , ( M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text "Label Large" ], "text-label-lg" )
    , ( M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text "Label Medium" ], "text-label-md" )
    , ( M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text "Label Small" ], "text-label-sm" )
    ]


row : Dict String String -> ( Element (TypedHtml.Element.Grouping.DivIs { a | heading : M3e.Kind.Brand, sharedPhrasing : TypedHtml.Kind.Shared }) (TypedHtml.Element.Grouping.DivChildAdmittedBy childAdm) msg, String ) -> Element (TypedHtml.Element.Grouping.DivIs s) adm_ msg
row metricsByClass ( exhibit, cls ) =
    let
        metrics : String
        metrics =
            Dict.get cls metricsByClass |> Maybe.withDefault ""
    in
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
view app _ =
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
                    [ M3e.Element.Card.content
                        (TypedHtml.div [ TA.class "flex flex-col px-2" ]
                            (List.intersperse (M3e.divider [] []) (List.map (row app.data) scale))
                        )
                    ]
                ]
            ]
        )

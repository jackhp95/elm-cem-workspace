module Route.Styles.Density exposing (ActionData, Data, Model, Msg, route)

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
        , description = "The M3 density axis and how it scales component sizing."
        , locale = Nothing
        , title = "Density · elm-m3e"
        }
        |> Seo.website


{-| Elm can't set a CSS custom property (`style`/`TA.style` use
`node.style[key]=…`, which ignores `--vars`), so scope `--md-sys-density-scale`
to this subtree via a Tailwind arbitrary-property class. Literal strings per
scale so Tailwind's scanner emits all four rules.
-}
densityScaleClass : Int -> String
densityScaleClass n =
    if n <= -3 then
        "[--md-sys-density-scale:-3]"

    else if n == -2 then
        "[--md-sys-density-scale:-2]"

    else if n == -1 then
        "[--md-sys-density-scale:-1]"

    else
        "[--md-sys-density-scale:0]"


demoBar : Int -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
demoBar scaleValue =
    TypedHtml.div [ TA.class "space-y-2" ]
        [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-on-surface-variant" ]
            [ M3e.text ("density scale " ++ String.fromInt scaleValue) ]
        , TypedHtml.div
            [ TA.class (densityScaleClass scaleValue ++ " flex flex-wrap gap-2") ]
            (List.range 1 4
                |> List.map
                    (\_ ->
                        M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Action" ]
                    )
            )
        ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Density" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Density"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Density compacts components for information-dense UIs. The --md-sys-density-scale token runs 0 (default, comfortable) through negative values (more compact). Set it globally via the app bar Density control, or scope it to a subtree. The scales below run 0 to -3." ]
                    ]
                ]
            , M3e.card
                [ M3e.Attributes.variant Value.outlined ]
                [ M3e.Component.Card.header (M3e.heading [ M3e.Attributes.variant Value.title ] [ M3e.text "Density scale, 0 to -3" ])
                , M3e.Component.Card.content
                    (TypedHtml.div [ TA.class "space-y-6" ]
                        [ demoBar 0
                        , demoBar -1
                        , demoBar -2
                        , demoBar -3
                        ]
                    )
                ]
            ]
        )

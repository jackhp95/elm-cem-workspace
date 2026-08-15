module Route.Styles.StateLayers exposing (ActionData, Data, Model, Msg, route)

{-| **State layers** — the translucent overlay every interactive M3 surface paints
on hover, focus, and press. Three opacity tokens (`--md-sys-state-*-state-layer-opacity`,
see `sys/state.css`) drive it, tinted with the element's on-color. Rendered live:
the m3e buttons below carry real state layers — hover, focus (Tab), and press them.
-}

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
        , description = "The M3 state-layer opacities for hover, focus, and press."
        , locale = Nothing
        , title = "State Layers · elm-m3e"
        }
        |> Seo.website


{-| `(token, value, what triggers it)` for the three state-layer opacities.
-}
states : List ( String, String, String )
states =
    [ ( "--md-sys-state-hover-state-layer-opacity", "8%", "Pointer over the element." )
    , ( "--md-sys-state-focus-state-layer-opacity", "10%", "Keyboard focus (Tab to the element)." )
    , ( "--md-sys-state-pressed-state-layer-opacity", "10%", "Active press / touch-down." )
    ]


stateRow : ( String, String, String ) -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
stateRow ( token, value, trigger ) =
    TypedHtml.div [ TA.class "flex flex-col gap-1 py-2.5" ]
        [ TypedHtml.div [ TA.class "flex flex-wrap items-baseline justify-between gap-2" ]
            [ TypedHtml.code [ TA.class "text-body-md text-on-surface" ] [ M3e.text token ]
            , TypedHtml.code [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text value ]
            ]
        , TypedHtml.span [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text trigger ]
        ]


demoButtons : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
demoButtons =
    TypedHtml.div [ TA.class "flex flex-wrap gap-3 p-2" ]
        [ M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Filled" ]
        , M3e.button [ M3e.Attributes.variant Value.tonal ] [ M3e.text "Tonal" ]
        , M3e.button [ M3e.Attributes.variant Value.outlined ] [ M3e.text "Outlined" ]
        , M3e.button [ M3e.Attributes.variant Value.text ] [ M3e.text "Text" ]
        ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "State Layers" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "State Layers"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Every interactive M3 surface paints a translucent state layer over itself to signal interaction. The layer takes the element's on-color and one of three opacities — hover, focus, or pressed — from the --md-sys-state-* tokens. It is additive: a focused-and-hovered element stacks both. m3e components render this for you; the tokens are here so you can match it in custom surfaces." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "The three opacities") "The three opacities"
                , M3e.card
                    [ M3e.Attributes.variant Value.outlined ]
                    [ M3e.Component.Card.content
                        (TypedHtml.div [ TA.class "flex flex-col px-2" ]
                            (List.intersperse (M3e.divider [] []) (List.map stateRow states))
                        )
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Live") "Live"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "These buttons carry real state layers. Hover one for the 8% overlay, Tab to it for the 10% focus overlay, or press and hold for the 10% pressed overlay." ]
                    ]
                , M3e.card [ M3e.Attributes.variant Value.outlined ] [ M3e.Component.Card.content demoButtons ]
                ]
            ]
        )

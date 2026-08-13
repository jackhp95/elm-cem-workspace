module Route.Styles.Motion exposing (ActionData, Data, Model, Msg, route)

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
import TypedHtml.Grouping
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
        , description = "The M3 motion system: easing and duration tokens."
        , locale = Nothing
        , title = "Motion · elm-m3e"
        }
        |> Seo.website


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Motion" ]


{-| A `(token, value)` reference table: the CSS custom property on the left, its
literal value on the right, divider-separated inside an outlined card.
-}
tokenTable : List ( String, String ) -> Element { r | card : M3e.Kind.Brand } adm_ msg
tokenTable rows =
    M3e.card
        [ M3e.Attributes.variant Value.outlined ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col px-2" ]
                (List.intersperse (M3e.divider [] []) (List.map tokenRow rows))
            )
        ]


tokenRow : ( String, String ) -> Element (TypedHtml.Grouping.DivIs s) adm_ msg
tokenRow ( token, value ) =
    TypedHtml.div [ TA.class "flex flex-wrap items-baseline justify-between gap-2 py-2.5" ]
        [ TypedHtml.code [ TA.class "text-body-md text-on-surface" ] [ M3e.text token ]
        , TypedHtml.code [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text value ]
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Motion"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Material 3 motion is encoded as easing and duration tokens. The standard set drives functional transitions; the expressive set adds spring-like emphasis. <m3e-theme> exposes a motion attribute, surfaced in M3e.Theme as Theme.withMotion." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Schemes") "Schemes"
                , TypedHtml.ul [ TA.class "list-disc space-y-1.5 pl-5" ]
                    [ TypedHtml.li []
                        [ TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ]
                            [ TypedHtml.code [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "Value.motionStandard" ]
                            , M3e.text " — functional, restrained transitions."
                            ]
                        ]
                    , TypedHtml.li []
                        [ TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ]
                            [ TypedHtml.code [ TA.class "text-body-lg text-on-surface" ] [ M3e.text "Value.motionExpressive" ]
                            , M3e.text " — emphasized, spring-driven motion for M3 Expressive surfaces."
                            ]
                        ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Easing curves") "Easing curves"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Six --md-sys-motion-easing-* cubic-beziers. The emphasized set drives prominent transitions; the standard set drives small, utility-focused ones. Each has an accelerate (entering) and decelerate (exiting) variant." ]
                    ]
                , tokenTable
                    [ ( "--md-sys-motion-easing-emphasized", "cubic-bezier(0.2, 0, 0, 1)" )
                    , ( "--md-sys-motion-easing-emphasized-decelerate", "cubic-bezier(0.05, 0.7, 0.1, 1)" )
                    , ( "--md-sys-motion-easing-emphasized-accelerate", "cubic-bezier(0.3, 0, 0.8, 0.15)" )
                    , ( "--md-sys-motion-easing-standard", "cubic-bezier(0.2, 0, 0, 1)" )
                    , ( "--md-sys-motion-easing-standard-decelerate", "cubic-bezier(0, 0, 0, 1)" )
                    , ( "--md-sys-motion-easing-standard-accelerate", "cubic-bezier(0.3, 0, 1, 1)" )
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Durations") "Durations"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Sixteen --md-sys-motion-duration-* steps in four bands. Short for small utility transitions, medium for traversing part of the screen, long for expressive moves, extra-long for ambient motion." ]
                    ]
                , tokenTable
                    [ ( "--md-sys-motion-duration-short-1", "50ms" )
                    , ( "--md-sys-motion-duration-short-2", "100ms" )
                    , ( "--md-sys-motion-duration-short-3", "150ms" )
                    , ( "--md-sys-motion-duration-short-4", "200ms" )
                    , ( "--md-sys-motion-duration-medium-1", "250ms" )
                    , ( "--md-sys-motion-duration-medium-2", "300ms" )
                    , ( "--md-sys-motion-duration-medium-3", "350ms" )
                    , ( "--md-sys-motion-duration-medium-4", "400ms" )
                    , ( "--md-sys-motion-duration-long-1", "450ms" )
                    , ( "--md-sys-motion-duration-long-2", "500ms" )
                    , ( "--md-sys-motion-duration-long-3", "550ms" )
                    , ( "--md-sys-motion-duration-long-4", "600ms" )
                    , ( "--md-sys-motion-duration-extra-long-1", "700ms" )
                    , ( "--md-sys-motion-duration-extra-long-2", "800ms" )
                    , ( "--md-sys-motion-duration-extra-long-3", "900ms" )
                    , ( "--md-sys-motion-duration-extra-long-4", "1000ms" )
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Springs") "Springs"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "M3 Expressive replaces some easings with springs: a duration paired with an overshooting curve. Spatial springs move layout and position; effects springs animate visual properties like color and opacity." ]
                    ]
                , tokenTable
                    [ ( "--md-sys-motion-spring-fast-spatial", "350ms cubic-bezier(0.27, 1.06, 0.18, 1)" )
                    , ( "--md-sys-motion-spring-default-spatial", "500ms cubic-bezier(0.27, 1.06, 0.18, 1)" )
                    , ( "--md-sys-motion-spring-slow-spatial", "750ms cubic-bezier(0.27, 1.06, 0.18, 1)" )
                    , ( "--md-sys-motion-spring-fast-effects", "150ms cubic-bezier(0.31, 0.94, 0.34, 1)" )
                    , ( "--md-sys-motion-spring-default-effects", "200ms cubic-bezier(0.34, 0.8, 0.34, 1)" )
                    , ( "--md-sys-motion-spring-slow-effects", "200ms cubic-bezier(0.34, 0.88, 0.34, 1)" )
                    ]
                ]
            ]
        )

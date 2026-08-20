module Route.Styles.Elevation exposing (ActionData, Data, Model, Msg, route)

{-| **Elevation** — the six M3 elevation levels (0–5). Each level is a three-layer
box-shadow (umbra + penumbra + ambient) tinted with `--md-sys-color-shadow`,
surfaced as the `shadow-md-level*` Tailwind utility (→ `--md-sys-elevation-level*`,
see `sys/elevation.css`). Rendered live: each swatch actually carries its level's
shadow.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
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
        , description = "The M3 elevation system: six shadow levels, rendered live."
        , locale = Nothing
        , title = "Elevation · elm-m3e"
        }
        |> Seo.website


{-| `(shadow utility, label, elevation token)` for each of the six levels. The
`shadow-md-level*` utility resolves `--md-sys-elevation-level*`.
-}
levels : List ( String, String, String )
levels =
    [ ( "shadow-md-level0", "Level 0", "--md-sys-elevation-level0" )
    , ( "shadow-md-level1", "Level 1", "--md-sys-elevation-level1" )
    , ( "shadow-md-level2", "Level 2", "--md-sys-elevation-level2" )
    , ( "shadow-md-level3", "Level 3", "--md-sys-elevation-level3" )
    , ( "shadow-md-level4", "Level 4", "--md-sys-elevation-level4" )
    , ( "shadow-md-level5", "Level 5", "--md-sys-elevation-level5" )
    ]


swatch : ( String, String, String ) -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
swatch ( shadow, label, token ) =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ TypedHtml.div
            [ TA.class ("bg-surface-container-high text-on-surface rounded-md-corner-large " ++ shadow ++ " flex min-h-24 items-center justify-center p-4")
            ]
            [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-on-surface" ] [ M3e.text label ] ]
        , TypedHtml.code [ TA.class "text-body-sm text-on-surface-variant" ] [ M3e.text token ]
        ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Elevation" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Elevation"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Material 3 expresses depth with six elevation levels, 0 through 5. Each --md-sys-elevation-level* token is a three-layer shadow — a tight umbra, a softer penumbra, and a wide ambient layer — tinted with --md-sys-color-shadow. Higher levels read as closer to the viewer. Components pick their resting level (a card sits at level 1, a menu or dialog at level 3) and raise it on interaction." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "The six levels, live") "The six levels, live"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Each swatch is a surface-container-high tile carrying its own shadow-md-level* utility, so the shadow you see is the real token. The caption is the CSS custom property it resolves." ]
                    ]
                , Doc.showcase
                    (TypedHtml.div [ TA.class "grid grid-cols-1 gap-6 p-2 sm:grid-cols-2 lg:grid-cols-3" ]
                        (List.map swatch levels)
                    )
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Tinting the shadow") "Tinting the shadow"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Every level resolves its color through --m3e-elevation-color → --md-sys-color-shadow → #000000. Override --m3e-elevation-color on a subtree to tint all six levels at once without touching the shadow geometry." ]
                    ]
                ]
            ]
        )

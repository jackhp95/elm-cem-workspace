module Route.Styles.Color exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Json.Decode as Decode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Element.Card
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
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { accents : List Accent
    , surfaces : List ( String, String, String )
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


{-| The accent-pairing and neutral-surface role lists, derived at build time from
the `--md-sys-color-*` inventory by `scripts/gen-style-tokens.mjs`
(-> `data/style-tokens.json`). The swatch color itself is resolved from the token
by the browser; deriving the LISTS means every role name the page references is
validated to exist in the manifest at build time — a renamed/removed role fails
the generator instead of shipping a dead utility. (The surface list is the page's
curated selection, not the exhaustive ladder; the full inventory lives in the
data file's `colorRoleInventory`.)
-}
data : BackendTask FatalError Data
data =
    BackendTask.File.jsonFile
        (Decode.map2 Data
            (Decode.field "colorAccents" (Decode.list accentDecoder))
            (Decode.field "colorSurfaces" (Decode.list surfaceDecoder))
        )
        "data/style-tokens.json"
        |> BackendTask.allowFatal


accentDecoder : Decode.Decoder Accent
accentDecoder =
    Decode.map5 Accent
        (Decode.field "name" Decode.string)
        (Decode.field "base" Decode.string)
        (Decode.field "baseBg" Decode.string)
        (Decode.field "container" Decode.string)
        (Decode.field "containerBg" Decode.string)


surfaceDecoder : Decode.Decoder ( String, String, String )
surfaceDecoder =
    Decode.map3 (\label bg role -> ( label, bg, role ))
        (Decode.field "label" Decode.string)
        (Decode.field "bg" Decode.string)
        (Decode.field "role" Decode.string)


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
        , description = "The M3 color roles, rendered live from the dynamic scheme."
        , locale = Nothing
        , title = "Color · elm-m3e"
        }
        |> Seo.website


type alias Accent =
    { name : String
    , base : String
    , baseBg : String
    , container : String
    , containerBg : String
    }


{-| A container/on-container pairing row: the bold role beside its container, so the
"on" color is read directly off each layer/form.
-}
accentRow : Accent -> Element (TypedHtml.Element.Grouping.DivIs s) adm_ msg
accentRow accent =
    TypedHtml.div [ TA.class "grid grid-cols-2 gap-3" ]
        [ swatch ( accent.name, accent.baseBg, accent.base )
        , swatch ( accent.name ++ " Container", accent.containerBg, accent.container )
        ]


swatch : ( String, String, String ) -> Element (TypedHtml.Element.Grouping.DivIs s) adm_ msg
swatch ( label, bg, role ) =
    TypedHtml.div
        [ TA.class (role ++ " rounded-md-corner-medium border border-outline-variant flex flex-col justify-between p-4 min-h-24")
        ]
        [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text label ]
        , TypedHtml.code [ TA.class "text-body-sm" ] [ M3e.text bg ]
        ]


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Color" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromElement "Color"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Material 3 derives a full set of semantic color roles from a single source color via the dynamic-color engine in <m3e-theme>. Every role is a --md-sys-color-* token; the swatches below are live — change the source color, scheme, or contrast in the app bar settings and they re-derive." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Container pairings") "Container pairings"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "Each accent comes as a bold role and a lower-emphasis container, and every role carries a paired on-* color for legible content. The swatch text is painted with that on-color, so if the label is readable the pairing is correct." ]
                    ]
                , Doc.showcase
                    (TypedHtml.div [ TA.class "grid grid-cols-1 gap-3 lg:grid-cols-2" ]
                        (List.map accentRow app.data.accents)
                    )
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Surface roles") "Surface roles"
                , Doc.showcase
                    (TypedHtml.div [ TA.class "grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4" ]
                        (List.map swatch app.data.surfaces)
                    )
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Dynamic color") "Dynamic color"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "<m3e-theme> wraps Material's material-color-utilities to derive a full scheme from a seed at runtime. Swap the source color in the app bar to see every role above re-derive instantly." ]
                    ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ Doc.sectionHeadingWithId (Doc.slugify "Forced colors") "Forced colors"
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                        [ M3e.text "When the OS reports forced-colors (Windows High Contrast), components map their semantic roles onto the system palette automatically. No app changes required." ]
                    ]
                , forcedColorsCard
                ]
            ]
        )


forcedColorsCard : Element { s | card : M3e.Kind.Brand } adm_ msg
forcedColorsCard =
    M3e.card
        [ M3e.Attributes.variant Value.outlined ]
        [ M3e.Element.Card.header (M3e.heading [ M3e.Attributes.variant Value.title ] [ M3e.text "Test it" ])
        , M3e.Element.Card.content
            (M3e.text "Enable Windows High Contrast or `forced-colors: active` in dev tools. The swatches above stay legible because every role respects the forced palette.")
        ]

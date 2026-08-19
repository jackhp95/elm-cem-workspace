module Route.GettingStarted.Welcome exposing (ActionData, Data, Model, Msg, route)

{-| The Start section's welcome page for `m3e-builder` / `elm-m3e` — the
type-safe, MISI Elm builder layer (`M3e.*`) over matraic's `@m3e/web`
Material 3 Expressive web components.

The app shell (`Shared.elm`) owns the `<m3e-theme>`, the top app bar, and the
sidebar nav, so this page is just the hero + highlights + theme reel content.

This is a **minimal stateful route** (`buildWithLocalState`) whose only local
state is the action of picking a theme. The page fires `Theme.Ports.requestPreset`
via a port (the sanctioned page→Shared bridge — see §D3 of the plan), which is
echoed back to `Shared`'s `onPresetRequested` subscription to call `ApplyPreset`.
The active preset id is read from `shared.theme.activePresetId` on each render.

-}

import BackendTask exposing (BackendTask)
import Doc
import Doc.Data
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Button
import M3e.Component.Card
import M3e.Component.Heading
import M3e.Component.Icon
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Theme.Ports
import Theme.Presets
import Theme.Reel
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Sectioning
import UrlPath
import View exposing (View)


type alias Model =
    {}


type Msg
    = PickTheme String


type alias RouteParams =
    {}


type alias Data =
    { componentCount : Int }


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            }


data : BackendTask FatalError Data
data =
    Doc.Data.allComponents
        |> BackendTask.map
            (\components ->
                { componentCount =
                    components |> List.filter (\c -> c.category /= "") |> List.length
                }
            )


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( {}, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        PickTheme presetId ->
            ( model, Effect.fromCmd (Theme.Ports.requestPreset presetId) )


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
        , description = "Type-safe Material 3 Expressive web components for Elm."
        , locale = Nothing
        , title = "elm-m3e · type-safe Material 3 Expressive for Elm"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app shared _ =
    View.fromElement "Welcome"
        (Doc.pane
            [ hero
            , highlights app.data.componentCount
            , themeReel shared
            , statusGrid
            ]
        )


hero : Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ msg
hero =
    TypedHtml.section [ TA.class "space-y-5" ]
        [ M3e.heading
            [ M3e.Component.Heading.variant Value.display
            , M3e.Component.Heading.size Value.large
            , M3e.Attributes.level 1
            ]
            [ M3e.text "Type-safe Material 3 Expressive for Elm" ]
        , TypedHtml.div [ TA.class "max-w-2xl" ]
            [ TypedHtml.p []
                [ M3e.text "Material 3 Expressive for Elm, over matraic's "
                , TypedHtml.code [] [ M3e.text "@m3e/web" ]
                , M3e.text " web components — where invalid UIs don't compile. Typed slots, enforced accessible names, and docs whose every example is machine-proven against the real components."
                ]
            ]
        , TypedHtml.div [ TA.class "flex flex-wrap items-center gap-3 pt-2" ]
            [ M3e.button [ M3e.Component.Button.variant Value.filled, M3e.Component.Button.href "/getting-started/installation" ] [ M3e.text "Get started" ]
            , M3e.button [ M3e.Component.Button.variant Value.outlined, M3e.Component.Button.href "/guide/reference" ] [ M3e.text "Browse the API reference" ]
            ]
        ]


{-| The "Why elm-m3e" highlight cards. The "Real M3 tokens" card's copy
points users downward to the live theme reel below it.
-}
highlights : Int -> Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ msg
highlights componentCount =
    TypedHtml.section [ TA.class "space-y-6" ]
        [ Doc.sectionHeadingWithId (Doc.slugify "Why elm-m3e") "Why elm-m3e"
        , TypedHtml.div [ TA.class "grid gap-4 sm:grid-cols-3" ]
            [ highlightCard "verified"
                "Type-safe slots"
                "Containers take typed children — an icon slot can only hold a M3e.Icon. Invalid compositions are compile errors — the wrong UI is never a value you can build."
            , highlightCard "category"
                "One import"
                (String.fromInt componentCount ++ " components behind a single import M3e — or component modules when you want tighter types.")
            , highlightCard "palette"
                "Real M3 tokens"
                "Dynamic color, shape, elevation, state layers, density, motion and the full type scale flow from a single <m3e-theme> — switch them live in the reel below."
            ]
        ]


highlightCard : String -> String -> String -> Element { s | card : M3e.Kind.Brand } admittedBy msg
highlightCard iconName cardTitle cardBody =
    M3e.card
        [ M3e.Component.Card.variant Value.elevated ]
        [ M3e.Component.Card.header (M3e.heading [ M3e.Component.Heading.variant Value.title ] [ M3e.text cardTitle ])
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex gap-3" ]
                [ TypedHtml.div [ TA.class "shrink-0" ]
                    [ M3e.icon [ M3e.Component.Icon.name iconName ] [] ]
                , TypedHtml.p [] [ M3e.text cardBody ]
                ]
            )
        ]


{-| The live theme reel section — the "themes work by inheritance" demo.
Each card is wrapped in its own `<m3e-theme>`, so colors are derived live.
Clicking a card fires `PickTheme presetId` which routes through
`Theme.Ports.requestPreset` → `index.ts` → `Shared.onPresetRequested` →
`Theme.update (ApplyPreset preset)`, re-theming the whole app.

`HtmlIr.Element.map PagesMsg.fromMsg` lifts the page `Msg` to `PagesMsg Msg`
as required by the elm-pages route contract.

-}
themeReel : Shared.Model -> Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ (PagesMsg Msg)
themeReel shared =
    TypedHtml.section [ TA.class "space-y-4 -mx-4 sm:-mx-8" ]
        [ TypedHtml.div [ TA.class "px-4 sm:px-8" ]
            [ Doc.sectionHeadingWithId (Doc.slugify "Themes") "Themes" ]
        , Theme.Reel.view
            { presets = Theme.Presets.presets
            , activeId = shared.theme.activePresetId
            , onPick = \preset -> PagesMsg.fromMsg (PickTheme preset.id)
            }
        ]


statusGrid : Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ msg
statusGrid =
    TypedHtml.section [ TA.class "space-y-3" ]
        [ Doc.sectionHeadingWithId (Doc.slugify "Status") "Status"
        , TypedHtml.div [ TA.class "max-w-2xl" ]
            [ Doc.markdown "Prerelease — breaking changes are embraced while the API settles. Every example in these docs is round-tripped against the real components; the [report](/guide/roundtrip) shows the current score." ]
        ]

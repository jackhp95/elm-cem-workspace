module Route.Guide.Motion exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/motion`): the motion division of responsibility. Material 3
Expressive motion (spring physics, shape morphing, state-layer ripples, enter/exit
choreography) ships _inside_ the `@m3e/web` custom elements and is driven by the
`M3e.Theme` motion scheme — you do not hand-animate it. What the Elm author controls
is the motion _between_ those components: the AVT snackbar in `js/avt-snackbar.js`,
cross-route view transitions, and honoring reduced-motion. Deep motion physics
(spring constants, duration/easing tokens) lives in the m3e-okf knowledge base and the
`/styles/motion` token page; this page draws the boundary.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
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
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/Motion.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "Material 3 Expressive motion ships inside the @m3e/web components — springs, shape morph, ripples. The Elm author controls the motion between them: the AVT snackbar, view transitions, and reduced-motion."
        , locale = Nothing
        , title = "Motion: what ships, what you wire · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        shippedBody : String
        shippedBody =
            Doc.section "shippedBody" d

        shippedNote : String
        shippedNote =
            Doc.section "shippedNote" d

        authorBody : String
        authorBody =
            Doc.section "authorBody" d

        snackbarBody : String
        snackbarBody =
            Doc.section "snackbarBody" d

        viewTransBody : String
        viewTransBody =
            Doc.section "viewTransBody" d

        reducedBody : String
        reducedBody =
            Doc.section "reducedBody" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Motion: what ships, what you wire"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Motion: what ships, what you wire"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Inside the components (you don't animate this)") "Inside the components (you don't animate this)"
                    , Doc.markdown shippedBody
                    , Doc.codeBlock Doc.Elm shippedCode
                    , Doc.markdown shippedNote
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "The motion between components (you wire this)") "The motion between components (you wire this)"
                    , Doc.markdown authorBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "The AVT snackbar") "The AVT snackbar"
                    , Doc.markdown snackbarBody
                    , Doc.codeBlock Doc.Elm snackbarCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "View transitions") "View transitions"
                    , Doc.markdown viewTransBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Reduced motion is not optional") "Reduced motion is not optional"
                    , Doc.markdown reducedBody
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


shippedCode : String
shippedCode =
    """import M3e.Element.Theme as Theme

Theme.component
    [ Theme.color model.seed
    , Theme.motion M3e.Values.expressive  -- spring-like emphasis (M3E's signature)
    -- , Theme.motion M3e.Values.standard   -- functional, restrained transitions
    ]
    [ appBody ]"""


snackbarCode : String
snackbarCode =
    """-- Elm owns WHEN the snackbar exists; the element owns the slide-in animation.
-- Render the <avt-snackbar> element (via `M3e.Unsafe.customElement`) only while
-- shown — mounting it is what triggers the toast:
snackbar : Toast -> Element (TypedHtml.Element.Grouping.DivIs s) adm_ msg
snackbar t =
    M3e.Unsafe.customElement "avt-snackbar"
        [ M3e.Unsafe.Attributes.customAttribute "message" t.message
        , M3e.Unsafe.Attributes.customAttribute "action" "Undo"
        , M3e.Unsafe.Attributes.customAttribute "dismissible" ""
        ]
        []

-- The `avt-snackbar-action` CustomEvent (detail.id) comes back through a
-- port/subscription and becomes a Msg — see Ui.Snackbar in the docs kit."""

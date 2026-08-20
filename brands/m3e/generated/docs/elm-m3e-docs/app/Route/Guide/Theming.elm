module Route.Guide.Theming exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/theming`): theming an elm-m3e app the Material way —
one root `M3e.Theme` fed a seed color plus scheme / contrast / density, the
derived `--md-sys-*` token roles, dark and dynamic color as swaps not stylesheets,
a worked brand re-skin, and the layout-only Tailwind boundary. The governing
principle is "components paint, Tailwind lays out, stylesheets never" — reach for
the component, then its attributes/slots, then its own `m3e-*` property, and treat
anything you still cannot express as an m3e gap to file rather than CSS to write.
`NoProprietaryDsClasses` enforces the layout boundary mechanically. Deep color-system theory
(tonal palettes, dynamic-color derivation) lives in the m3e-okf knowledge base;
this page is the Elm/`M3e.Theme` practice.
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
    BackendTask.File.rawFile "content/guides/Theming.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "Theme an elm-m3e app the Material way: one root M3e.Theme fed a seed color plus scheme, contrast, and density derives every --md-sys-* role. Re-skin with tokens, don't restyle with class overrides."
        , locale = Nothing
        , title = "Theming with tokens · elm-m3e"
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

        rootBody : String
        rootBody =
            Doc.section "rootBody" d

        rootNote : String
        rootNote =
            Doc.section "rootNote" d

        rolesBody : String
        rolesBody =
            Doc.section "rolesBody" d

        tokenFamilies : String
        tokenFamilies =
            Doc.section "tokenFamilies" d

        darkBody : String
        darkBody =
            Doc.section "darkBody" d

        reskinBody : String
        reskinBody =
            Doc.section "reskinBody" d

        reskinNote : String
        reskinNote =
            Doc.section "reskinNote" d

        bridgeBody : String
        bridgeBody =
            Doc.section "bridgeBody" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Theming with tokens"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Theming with tokens"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "One theme at the root") "One theme at the root"
                    , Doc.markdown rootBody
                    , Doc.codeBlock Doc.Elm rootCode
                    , Doc.markdown rootNote
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Paint with roles, not hex") "Paint with roles, not hex"
                    , Doc.markdown rolesBody
                    , Doc.codeBlock Doc.Elm rolesCode
                    , Doc.markdown tokenFamilies
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Dark and dynamic color are swaps") "Dark and dynamic color are swaps"
                    , Doc.markdown darkBody
                    , Doc.codeBlock Doc.Elm darkCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "A brand re-skin, end to end") "A brand re-skin, end to end"
                    , Doc.markdown reskinBody
                    , Doc.codeBlock Doc.Elm reskinCode
                    , Doc.markdown reskinNote
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "The Tailwind bridge: layout only") "The Tailwind bridge: layout only"
                    , Doc.markdown bridgeBody
                    , Doc.codeBlock Doc.Elm bridgeCode
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


rootCode : String
rootCode =
    """import M3e.Component.Theme as Theme

Theme.component
    [ Theme.color model.seed                    -- the brand/seed color, e.g. "#4285F4"
    , Theme.scheme model.scheme                 -- M3e.Values.light | M3e.Values.dark
    , Theme.contrast model.contrast             -- standard | medium | high
    , Theme.density model.density               -- 0 (default) down to -3 (compact)
    ]
    [ appBody ]"""


rolesCode : String
rolesCode =
    """-- The container-surface role: a filled card. It paints its own background
-- AND its own foreground from the theme.
M3e.card [ M3e.Attributes.variant M3e.Values.filled ] rows

-- The de-emphasized role: a list item's own slot. Correct color and type
-- scale, no class involved.
M3e.listItem []
    [ M3e.text "Primary line"
    , M3e.Component.ListItem.supportingText (M3e.text "Secondary text")
    ]

-- The primary-action role: a filled button, with the state layer and focus
-- ring that come with it.
M3e.button [ M3e.Attributes.variant M3e.Values.filled ] [ M3e.text "Continue" ]

-- WRONG — the right ROLES, but hand-painted onto bare elements. Themed, and
-- still a card and a list item reimplemented in CSS: no state layer, no
-- density, no accessibility.
TypedHtml.div [ TypedHtml.Attributes.class "bg-surface-container" ] rows
TypedHtml.span [ TypedHtml.Attributes.class "text-body-lg text-on-surface-variant" ] [ M3e.text "Secondary text" ]

-- WRONG — a raw color, decoupled from the scheme, wrong in dark mode:
TypedHtml.div [ TypedHtml.Attributes.class "bg-[#4285F4] text-white" ] children"""


darkCode : String
darkCode =
    """-- Light/dark is one input, held in the model and flipped:
Theme.scheme (if model.dark then M3e.Values.dark else M3e.Values.light)

-- Dynamic color is one input too — a new seed re-derives every role:
Theme.color model.brandSeed"""


reskinCode : String
reskinCode =
    """-- Before: the default seed, standard density, default corners.
Theme.component
    [ Theme.color "#4285F4"
    , Theme.scheme M3e.Values.light
    , Theme.density 0
    ]
    [ appBody ]

-- After: a brand re-skin. New seed re-derives the ENTIRE palette;
-- density and corner language shift globally. appBody is untouched.
Theme.component
    [ Theme.color "#6750A4"          -- brand accent — every role re-derives
    , Theme.scheme M3e.Values.light
    , Theme.contrast M3e.Values.medium -- a touch more contrast for the new palette
    , Theme.density -1                 -- slightly more compact
    ]
    -- Shapes are not a Theme input: set the corner on the COMPONENT that owns
    -- the surface -- its shape attribute, or its own generated utility, e.g.
    -- TA.class "m3e-card-shape-md-corner-large" on that card.
    [ appBody ]"""


bridgeCode : String
bridgeCode =
    """-- GOOD: the component owns the surface. `m3e-card` paints its own container
-- color, corner and foreground from the theme; Tailwind only lays out inside it.
M3e.card
    [ M3e.Attributes.variant M3e.Values.filled ]
    [ TypedHtml.div
        [ TypedHtml.Attributes.class "flex flex-col gap-3 p-4 overflow-hidden" ]
        rows
    ]

-- GOOD: a non-default value for one of the card's OWN documented properties,
-- via the generated utility for it. Still a Tailwind class, still themed.
M3e.card
    [ M3e.Attributes.variant M3e.Values.filled
    , TypedHtml.Attributes.class "m3e-card-shape-md-corner-large"
    ]
    rows

-- WRONG: token classes hand-painting a card. Themed, yes — but it is an
-- `m3e-card` reimplemented in CSS, with no state layer and no density.
TypedHtml.div
    [ TypedHtml.Attributes.class "bg-surface-container rounded-md-corner-large" ]
    rows

-- WRONG: a raw corner and a raw color doing a token's job — adrift from the
-- shape scale, and wrong the moment the scheme flips.
TypedHtml.div [ TypedHtml.Attributes.class "rounded-3xl bg-[#4285F4] p-4" ] rows

-- WRONG, and the worst of the three: moving the paint into a stylesheet. The
-- call site now says nothing about how it looks, and the missing component
-- knob never gets reported.
--     .my-panel { background: var(--md-sys-color-surface-container); }
TypedHtml.div [ TypedHtml.Attributes.class "my-panel" ] rows"""

module Route.Guide.Seams exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/seams`): the real escapes — a third-party custom element,
raw `Html`, a break-glass `recast` — ship _with the library_, fenced into one
lint-guarded place: `M3e.Unsafe` and `M3e.Unsafe.Attributes`. There is no
userland adapter module to hand-write anymore. Most code needs none of it:
standard HTML stays typed (`TypedHtml`), and most "custom" content just fills
a typed slot. This page shows the real reach (`M3e.Unsafe.customElement` for
`<model-viewer>`) next to the close calls that only look like one. The
two-column layout is live; the producers are shown as code.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Guide.Samples as Samples
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Component.AppBar
import M3e.Component.Button
import M3e.Component.Card
import M3e.Component.FormField
import M3e.Component.Icon
import M3e.Component.NavMenuItem
import M3e.Kind
import M3e.Unsafe
import M3e.Unsafe.Attributes
import M3e.Values as Value
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Aria
import TypedHtml.Attributes
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
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/Seams.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "A seam is the practice of reaching for the library's own fenced escapes — M3e.Unsafe, for raw Html or a custom element the types can't express — instead of improvising around the type system. Everything else stays typed."
        , locale = Nothing
        , title = "Your own seam · elm-m3e"
        }
        |> Seo.website


saveButton : Element { s | button : M3e.Kind.Brand } admittedBy msg
saveButton =
    M3e.button [ M3e.Component.Button.variant Value.filled ]
        [ M3e.Component.Button.icon (M3e.icon [ M3e.Component.Icon.name "save" ] [])
        , M3e.text "Save"
        ]


emailField : Element { s | formField : M3e.Kind.Brand } admittedBy msg
emailField =
    M3e.formField [ M3e.Component.FormField.variant Value.outlined ]
        [ M3e.Component.FormField.label
            (TypedHtml.label [ TypedHtml.Attributes.for "email-field" ] [ M3e.text "Email address" ])
        , TypedHtml.input
            [ TypedHtml.Attributes.id "email-field"
            , TypedHtml.Attributes.type_ "email"
            , TypedHtml.Attributes.name "email"
            ]
            []
        ]


{-| Userland layout — **not** a seam. Standard HTML is already typed, so a
two-column grid is a plain `TypedHtml.div` with a class attribute; the class
string is contained in one named producer instead of sprinkled at every call
site. No escape, no door.
-}



-- @sample-source seamsTwoColumn


twoColumn : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
twoColumn =
    -- NOT a seam: standard HTML is already typed, so layout is a plain div.
    TypedHtml.div [ TypedHtml.Attributes.class "grid grid-cols-1 gap-4 md:grid-cols-2" ]
        [ emailField, saveButton ]


{-| A **genuine seam.** `<model-viewer>` is a third-party web component the typed
tree has no producer for, so building it means stepping outside: `M3e.Unsafe.customElement`
forges the custom tag and `M3e.Unsafe.Attributes.customAttribute` sets its bespoke attributes. That
escape is exactly what a seam is _for_ — and it lives in one named userland
producer, contained and greppable, not scattered through feature code.
-}



-- @sample-source seamsModelViewer


modelViewer : Element (M3e.Component.Card.Is k) freeAdm msg
modelViewer =
    -- a real seam: a custom element the types can't express, contained once.
    -- The surface the third-party tag renders on comes from `m3e-card` (filled
    -- variant — same rung the layout-only-styling rule wants for any painted
    -- container), not hand-rolled `rounded-lg bg-surface-container`: `<model-viewer>`
    -- has no background/shape of its own, so it needs a container to read as a
    -- box while its 3D content loads.
    M3e.card
        [ M3e.Component.Card.variant Value.filled, TypedHtml.Attributes.class "h-48 w-full" ]
        [ M3e.Unsafe.customElement "model-viewer"
            [ TypedHtml.Attributes.src "/models/chair.glb"
            , M3e.Unsafe.Attributes.customAttribute "camera-controls" ""
            , M3e.Unsafe.Attributes.customAttribute "auto-rotate" ""
            , TypedHtml.Attributes.class "block h-full w-full"
            ]
            []
        ]


{-| A typed anchor filling a _typed slot_. A nav-menu item's `label` slot accepts
the `text` and `link` kinds, so `TypedHtml.a` drops straight in as an `<a href>`
label — no raw HTML, no seam, no break-glass `recast`. The slot's phantom row
admits exactly the kinds the design system declared for it.
-}



-- @sample-source seamsLinkNav


linkNav : Element { s | navMenu : M3e.Kind.Brand } admittedBy msg
linkNav =
    -- the label slot admits { text : M3e.Kind.Brand, link : M3e.Kind.Brand }, so a
    -- typed `TypedHtml.a` fills it directly — a nav item that IS an anchor. The
    -- required-record form (`M3e.Component.NavMenuItem.component`) enforces the required `label`.
    M3e.navMenu []
        [ M3e.Component.NavMenuItem.component { label = TypedHtml.a [ TypedHtml.Attributes.href "/guide/seams" ] [ M3e.text "Seams" ] } [] []
        , M3e.Component.NavMenuItem.component { label = TypedHtml.a [ TypedHtml.Attributes.href "/guide/the-layers" ] [ M3e.text "The surfaces" ] } [] []
        ]


{-| Native HTML filling an M3e slot that says "arbitrary content goes here".

`AppBar.trailing` declares `shared:flow` and `shared:phrasing` — the two WHATWG
content categories — so `TypedHtml.div` drops in as itself. No `recast`, and the
compiler still checks what goes _inside_ the div.

-}



-- @sample-source seamsHtmlInSlot


htmlInSlot : Element { s | appBar : M3e.Kind.Brand } admittedBy msg
htmlInSlot =
    -- AppBar.TrailingSlot admits { button, iconButton, searchBar, sharedFlow, sharedPhrasing }.
    -- `TypedHtml.div` produces `sharedFlow`, so the wrapper goes in as itself — and the
    -- iconButton and badge INSIDE it are still checked against the div's content model.
    M3e.appBar [ TypedHtml.Attributes.class "px-2" ]
        [ M3e.Component.AppBar.title (M3e.heading [] [ M3e.text "Inbox" ])
        , M3e.Component.AppBar.trailing
            (TypedHtml.div [ TypedHtml.Attributes.class "inline-flex items-center gap-1" ]
                [ M3e.iconButton [ TypedHtml.Aria.label "Search" ] [ M3e.icon [ TypedHtml.Attributes.name "search" ] [] ]
                , M3e.badge [] [ M3e.text "3" ]
                ]
            )
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        userland : String
        userland =
            Doc.section "userland" d

        realSeam : String
        realSeam =
            Doc.section "realSeam" d

        slotSeam : String
        slotSeam =
            Doc.section "slotSeam" d

        crossBrand : String
        crossBrand =
            Doc.section "crossBrand" d

        oneWay : String
        oneWay =
            Doc.section "oneWay" d

        payoff : String
        payoff =
            Doc.section "payoff" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Your own seam"
        (Doc.pane
            [ TypedHtml.div [ TypedHtml.Attributes.class "space-y-12" ]
                [ TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.pageHeading "Your own seam — one place for your escapes"
                    , TypedHtml.div [ TypedHtml.Attributes.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown userland
                    , Doc.showcase twoColumn
                    , Doc.codeBlock Doc.Elm Samples.seamsTwoColumn
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown realSeam
                    , Doc.showcase modelViewer
                    , Doc.codeBlock Doc.Elm Samples.seamsModelViewer
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown slotSeam
                    , Doc.showcase linkNav
                    , Doc.codeBlock Doc.Elm Samples.seamsLinkNav
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown crossBrand
                    , Doc.showcase htmlInSlot
                    , Doc.codeBlock Doc.Elm Samples.seamsHtmlInSlot
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown oneWay
                    , Doc.codeBlock Doc.Elm oneWayRejected
                    , Doc.codeBlock Doc.Elm oneWayAccepted
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown payoff ]
                , Doc.recapBox recap
                ]
            ]
        )



-- @sample expect-compile-error: the whole point of the block — `span`'s content
-- row has no field for `heading`, and this page says so. Verified to be rejected.


oneWayRejected : String
oneWayRejected =
    """TypedHtml.span [] [ M3e.heading [] [ M3e.text "hi" ] ]   -- ✗ rejected"""


oneWayAccepted : String
oneWayAccepted =
    """TypedHtml.div [] [ M3e.heading [] [ M3e.text "hi" ] ]        -- ✓ div takes any children
TypedHtml.span [] [ M3e.text "hi" ]                          -- ✓ text is a shared atom
TypedHtml.span [] [ M3e.icon [ TA.name "star" ] [] ]         -- ✓ so is icon"""

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

import BackendTask
import Doc
import Guide.Samples as Samples
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Component.AppBar
import M3e.Component.Button
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


modelViewer : Element (TypedHtml.Component.Grouping.DivIs k) freeAdm msg
modelViewer =
    -- a real seam: a custom element the types can't express, contained once.
    M3e.Unsafe.customElement "model-viewer"
        [ TypedHtml.Attributes.src "/models/chair.glb"
        , M3e.Unsafe.Attributes.customAttribute "camera-controls" ""
        , M3e.Unsafe.Attributes.customAttribute "auto-rotate" ""
        , TypedHtml.Attributes.class "block h-48 w-full rounded-lg bg-surface-container"
        ]
        []


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
view _ _ =
    View.fromElement "Your own seam"
        (Doc.pane
            [ TypedHtml.div [ TypedHtml.Attributes.class "space-y-12" ]
                [ TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.pageHeading "Your own seam — one place for your escapes"
                    , TypedHtml.div [ TypedHtml.Attributes.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
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


intro : String
intro =
    """Everything you write on top of the library is **userland** — your own code. Most of it needs no escape at all: standard HTML is already typed (`TypedHtml.div`, `TypedHtml.label`, …), and "custom" content usually just fills a component's *typed slot*. A **seam** isn't something you build — it's the *practice* of reaching for the library's own fenced escapes, `M3e.Unsafe` and `M3e.Unsafe.Attributes`, instead of improvising a way around the type system. They ship in one lint-guarded place so every real crossing is loud, named, and greppable — no userland adapter module required. This page shows the two things worth telling apart: a genuine escape (`modelViewer`, below) and typed code that only looks like one (`twoColumn`, `linkNav`)."""


userland : String
userland =
    """Start with what is **not** a seam. A two-column layout is standard HTML, and standard HTML is typed — a `TypedHtml.div` with a class attribute. Naming it in one userland producer keeps the class string in one place, but there is no escape here and nothing for the linter to fence. Reaching for `M3e.Unsafe.fromHtml` to build this would be the mistake: it drags plain typed markup through an escape door it never needed to walk through — the compiler already gives you `TypedHtml.div` for free."""


realSeam : String
realSeam =
    """Now a **real** seam. `<model-viewer>` is a third-party web component — the typed tree has no producer for it, so building it means genuinely stepping outside: `M3e.Unsafe.customElement` forges the custom tag and `M3e.Unsafe.Attributes.customAttribute` sets its bespoke attributes. This is what the seam is *for*. Because it lives in one named userland producer, the escape is contained, greppable, and lint-fenced — you stepped outside on purpose, in one auditable place, instead of calling `M3e.Unsafe.customElement` inline wherever a `<model-viewer>` happens to show up."""


slotSeam : String
slotSeam =
    """Most "custom" content needs no escape at all — it fills the *typed slots* a component declares. A nav-menu item's `label` slot accepts the `text` **and** `link` kinds, so a nav item can be an ordinary `<a href>` with no raw HTML at the call site: `TypedHtml.a` produces the `link` kind, so it drops into the slot directly — no seam, no door, no break-glass `recast`. The slot's phantom row admits exactly the kinds the design system declared for it."""



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


crossBrand : String
crossBrand =
    """Slots that mean *"arbitrary content goes here"* say so in a vocabulary **both libraries speak**. `M3e.Component.AppBar.trailing` declares the two WHATWG content categories, `shared:flow` and `shared:phrasing`, and `TypedHtml.div` produces `sharedFlow` — so a native wrapper drops straight into an M3e slot with no escape at all.

The important half is what *stays* checked. `M3e.Unsafe.recast` would also have got the div in, by throwing away every row on the way; this keeps them. The div still has to be legal where it sits, and its children still have to be legal inside a div. You didn't buy admission by going blind."""


oneWay : String
oneWay =
    """**The other direction is a designed limit, not a gap to route around.** An M3e component will not go inside a native container whose content model is enumerated — `<span>`, `<p>`, `<h1>`, `<li>`, `<td>`:

The reason is the same rule that makes slots work at all: a producer's named kinds must be a **subset** of the slot's. `M3e.heading` names `heading` so that `AppBar.title` can tell a heading from a card — and that same field is what `SpanContent` has no name for. Erasing it would let M3e components into native containers *and* let a Card into a Menu. You can have a component discriminated by its own design system, or admitted by a foreign library's enumerated slots. Not both.

In practice it rarely bites, and there are three honest answers before you reach for an escape:

1. **Use a flow container.** `TypedHtml.div`, `section`, `article`, `header`, `footer`, `main_`, `nav`, `form`, `figure`, `aside`, `details`, `dialog` and 20-odd others take any children at all. Wrapping a component in a `<div>` is not a workaround — it is what the content model already says.
2. **Check the slot first.** Text and icons cross both ways as shared atoms, so `M3e.text` and `M3e.icon` sit inside native phrasing content directly.
3. **`M3e.Unsafe.recast`** for the case where the design system is genuinely wrong — a specific, recurring crossing gets a small named function built on `recast`, kept next to the feature that needs it. Loud, named and lint-fenced — which is the point of this page.

Two smaller residues, for completeness: a bare `<img>` or `<area>` keeps a per-tag kind (so `<picture>` and `<map>` stay exact) and needs a wrapper to enter an M3e slot; and `<dl>`/`<option>` accept any flow content rather than the narrower set the spec names."""


payoff : String
payoff =
    """That is the whole discipline: **type everything you can, seam only what you must, and keep the seams in one place.** Layout and text are typed producers. Slots take typed kinds. The genuine escapes — a custom element, raw `Html` via `fromHtml`, or the break-glass `recast` when the design system is truly wrong for a case — are named, lint-fenced, and already live in one place: `M3e.Unsafe` and `M3e.Unsafe.Attributes`. Your job is narrower than it used to be — call them from a small, named producer (like `modelViewer` above) instead of inline at every call site. You escaped the types where you had to and **kept** the guarantees everywhere else, because every real escape is loud, contained, and greppable."""


recap : String
recap =
    """- A **seam** isn't something you build — it's the *practice* of reaching for the library's fenced escapes (a custom element, raw `Html`, a `recast`) instead of improvising around the type system.
- Most userland is **not** a seam: standard HTML is typed (`TypedHtml`), and custom content usually fills a **typed slot** — no escape needed.
- The genuine escapes go through the library's one fenced door for userland — `M3e.Unsafe` (`fromHtml`/`fromNode`/`recast`/`recastAll`/`customElement`) and `M3e.Unsafe.Attributes` (`fromHtmlAttribute`/`customAttribute`) — named once so every use is auditable.
- **Next: [The tooling refactors for you](/guide/tooling-refactors) →** the linter doesn't just flag escapes — it extracts and rewrites them *for* you."""

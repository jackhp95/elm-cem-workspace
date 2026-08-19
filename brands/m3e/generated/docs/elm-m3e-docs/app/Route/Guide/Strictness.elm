module Route.Guide.Strictness exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/strictness`): choose how strict your project is.
The compiler enforces kinds and valid tokens but deliberately leaves the softer
"did you fill the required slot?" loose on the standard surface, so that tax
doesn't land on every call site. You dial those back up two ways: a linter that knows
your components, and stricter call-shapes you opt into per component (options
list, required record, pipeline) — peers, each promoting one advisory check to a
compile guarantee. The live demo stays the barrel Save button; the alternative
shapes are shown as code with their real compiler output.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Button
import M3e.Kind
import M3e.Values as Value
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
        , description = "Start easy and turn safety up by choice. A linter that knows your components, plus stricter call-shapes you opt into per component — no all-or-nothing."
        , locale = Nothing
        , title = "The strictness dial · elm-m3e"
        }
        |> Seo.website


{-| The running Save button, in the default options-list shape — the standard,
easy top. The stricter shapes are shown as code below, each rendering the same
button; they only change what you're allowed to leave out.
-}
saveButton : Element { s | button : M3e.Kind.Brand } adm_ msg
saveButton =
    M3e.button [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Button.icon (M3e.icon [ TA.name "save" ] [])
        , M3e.text "Save"
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "The strictness dial"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The strictness dial"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown linter ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown shapes
                    , Doc.showcase saveButton
                    , Doc.codeBlock Doc.Elm shapesCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown recordAha
                    , Doc.codeBlock Doc.NoLang recordError
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """The compiler holds a lot for you — kinds line up, and only real tokens exist. But it *deliberately* stays quiet about softer questions like "did you fill the slot this component needs?" on the standard surface, because forcing that on every call site would tax the easy path. Strictness here isn't all-or-nothing: **you start easy and turn it up where it's worth it** — project-wide with the linter, or per call site with a stricter surface.

A quick word on vocabulary, since it shows up below: a **surface** is one of a component's interchangeable call-shapes you'll map in full at [the surface map](/guide/the-layers), the **barrel** is the one-import `M3e` API, and a **component module** is a per-component import (`import M3e.Button`) with tighter, component-scoped types."""


linter : String
linter =
    """A linter that knows your components reads the same component list the API was generated from, so it can flag things the types leave loose: an enum token that type-checked through the shared `M3e.Attributes.*` vocabulary but isn't valid for *this* component, a required content slot you left empty, or a child placed in a slot the container doesn't declare (`Cem.ValidSlotKind`). These are **linter-guaranteed, not compiler-guaranteed** — the linter is a separate pass, so it only protects you if you **run elm-review in CI**. Run there, it catches the soft misses the compiler waves through on purpose. (One caveat worth naming: `Cem.ValidSlotKind` is `Lenient` by default and can't resolve a child's kind through a `List.map` or a let-binding, so it's a strong net, not an absolute one.)"""


shapes : String
shapes =
    """Stricter call-shapes, chosen per component. A component isn't one function shape; each ships several **surfaces**, and they all render the *same* button. They differ only in what you're allowed to leave out — they are **peers, not a ranking**, and you pick per call site:"""


shapesCode : String
shapesCode =
    """-- the standard form — everything optional; the tersest, easiest form
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- required-record form (`component`) — the compiler now DEMANDS the parts a button can't do without
M3e.Component.Button.component
    { content = M3e.text "Save", action = M3e.Action.onClick SaveClicked }
    []
    []

-- builder pipe (`build`/`toElement`) — a one-only setter becomes UNWRITABLE twice; order-free
M3e.Build.Button.build
    { content = M3e.text "Save", action = M3e.Action.onClick SaveClicked }
    |> M3e.Build.Button.toElement"""


recordAha : String
recordAha =
    """The standard-form Save button lets you forget its action — that's the easy path's cost. Switch the same button to the **required-record** form (`component`) and forgetting the action is no longer possible: leave it out and the build stops, because the record spells out the parts a button can't render without."""


recordError : String
recordError =
    """The 1st argument to `component` is not what I expect:

4| M3e.Component.Button.component { content = M3e.text "Save" } [] []
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This argument is a record of type:

    { content : … }

But `component` needs the 1st argument to be:

    { action : Action { … } msg, content : … }"""


recap : String
recap =
    """- The compiler enforces **kinds and valid tokens**; it leaves softer checks loose on the standard surface on purpose.
- **Project-wide:** a linter that knows your components (invalid token for *this* component, empty required slot, foreign slot child) — **linter-guaranteed, so run elm-review in CI**.
- **Per call site:** three call-shapes — the standard form, required record, pipeline — **peers**, each promoting one check to a compile guarantee.
- **Next: [Accessibility you can't forget](/guide/accessible-by-construction) →** the one place strictness is not optional — an accessible name you cannot forget."""

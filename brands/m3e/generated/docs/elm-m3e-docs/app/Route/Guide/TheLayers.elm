module Route.Guide.TheLayers exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/the-layers`): the orienting map. A component is not a
stack of layers you descend; it is one typed value you can write through a
handful of interchangeable **surfaces** (barrel, `component`, `build`), plus a
few loud **escapes** for leaving the typed tree. The running example doesn't
change; the same Save button is shown live once and its surfaces are shown as
code, with the "hand-writing raw HTML the library already ships" tell.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
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
        , description = "A component is one typed value written through interchangeable surfaces — barrel, view, el, build. You leave the typed tree only through a few loud, named escapes."
        , locale = Nothing
        , title = "The surface map · elm-m3e"
        }
        |> Seo.website


{-| The running Save button, written through the barrel surface — the one you
reach for by default. The chapter shows the other surfaces as code; they all
produce this same slottable value, so one live demo covers them all.
-}
saveButton : Element { s | button : M3e.Kind.Brand } adm_ msg
saveButton =
    M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "The surface map"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The surface map"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown layers
                    , Doc.codeBlock Doc.NoLang layersDiagram
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown sameButton
                    , Doc.showcase saveButton
                    , Doc.codeBlock Doc.Elm descentCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown tell ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """One thesis organizes this whole library: **a component is a single typed value, and the correct way is also the easy way.** There is no ladder of safety to climb down. What looks like "levels" is really two independent choices — *which surface* you write the value through, and *whether* you step outside the typed tree at all. This chapter is the map of both."""


layers : String
layers =
    """Every component ships a handful of interchangeable **surfaces** — different call *shapes* for the same value. They are **peers, not a ranking**: pick whichever reads best at a given call site, and they all produce the identical, slottable element. Reach *past* the components only to **escape** the typed tree, and escapes are always a loud, named step — never an accident."""


layersDiagram : String
layersDiagram =
    """SURFACES — same typed value, different call shape (a horizontal choice)
  M3e.button …                     barrel: one import, every component's `component`
  M3e.Component.Divider.component [ … ] …           the standard/list form (no required record)
  M3e.Component.Button.component { … } …            required-record form (the 29 with a required record)
  M3e.Build.Button.build { … } |> …      builder pipe, closed by M3e.Build.Button.toElement

LOOSENESS — opt out of the strict phantom rows, still in the IR
  M3e.Html.button …                the loose producer (open rows, no slot checking)

ESCAPES — leave the typed tree (loud, greppable, lint-fenced)
  M3e.Unsafe.fromHtml …            wrap raw elm/html; free rows, checks nothing
  M3e.Unsafe.recast …              re-kind an Element so it fits any slot
  M3e.Unsafe.customElement …       forge a custom-element tag as a slot-ready Element"""


sameButton : String
sameButton =
    """Here is the running Save button, written through the barrel — the surface you'll reach for by default. It's a value that composes into a card, a list, anywhere a button belongs. Every surface below produces this *same* value with the same guarantees; they differ only in ergonomics (how much you may leave out, how you set one-only options). The escapes at the bottom are the only calls that give up the typed value — that's the whole reason they're loud."""


descentCode : String
descentCode =
    """-- barrel: one import, the standard form — the default
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- component module: same output, component-scoped tighter types
M3e.Component.Button.component { content = M3e.text "Save", action = M3e.Action.none } [ M3e.Component.Button.variant Value.filled ] []

-- required-record form: the compiler demands the parts a button can't omit
M3e.Component.Button.component { content = M3e.text "Save", action = M3e.Action.onClick Save } [] []

-- builder pipe: a one-only setter is unwritable twice; order-free
M3e.Build.Button.build { content = M3e.text "Save", action = M3e.Action.onClick Save }
    |> M3e.Build.Button.withVariant Value.filled
    |> M3e.Build.Button.toElement"""


tell : String
tell =
    """There's a simple tell that you escaped when you didn't need to: **if you're hand-writing raw HTML (`M3e.Unsafe.fromHtml`, a bare `M3e.Unsafe.customElement`) for something the library already ships as a component, you reached too far.** The typed component already carries the tag, the slots, and the tokens — spelling them out by hand throws that away. Escapes exist for what the library genuinely can't express; reaching for one otherwise is the mistake."""


recap : String
recap =
    """- A component is **one typed value**, written through interchangeable **surfaces** (barrel, `component`, `build`) — **peers, not a ranking**.
- `M3e.Html.*` is the **loose** producer: opt out of strict phantom rows while staying in the IR (it is *not* plain HTML).
- You leave the typed tree only through loud, named **escapes**: `M3e.Unsafe` / `M3e.Unsafe.Attributes` (`fromHtml`, `fromNode`, `recast`, `customElement`, …) — shipped with the library, built on the raw forge `HtmlIr.Internal` that application code never touches directly. There is no second, config-blessed kind-crossing module — a specific, recurring crossing is a small named function built on `recast`.
- The tell that you over-escaped: **hand-writing raw HTML the library already ships as a component.**
- **Next: [Your own seam](/guide/seams) →** when you *do* need to step outside, do it through one of the sanctioned escapes."""

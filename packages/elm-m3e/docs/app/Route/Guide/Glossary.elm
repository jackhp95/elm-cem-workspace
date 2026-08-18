module Route.Guide.Glossary exposing (ActionData, Data, Model, Msg, route)

{-| Guide · Glossary (`/guide/glossary`): the vocabulary spine. One canonical
place for the kept terms, each defined in plain words — the same glosses the
chapters use on first mention. Insider jargon is deliberately absent; this is
the reader's dictionary, not the maintainer's.
-}

import BackendTask
import Doc
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
        , description = "The Guide glossary: the kept terms — surface, loose producer, escape, barrel, component module, shared/per-component vocabulary, kind, slot, token, seam, component facts, manifest — each defined in plain words."
        , locale = Nothing
        , title = "Glossary · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Glossary"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-8" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Glossary"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown terms ]
                ]
            ]
        )


intro : String
intro =
    """The words this guide keeps, each defined once and used freely afterward. If a chapter uses one of these, this is what it means — no hidden second meaning."""


terms : String
terms =
    """| Term | What it means |
| --- | --- |
| **surface** | One of a component's interchangeable call-shapes for the *same* typed value — **peers, not a ranking**: the **standard** form (`M3e.button …` or `M3e.Button.component […] […]`, everything optional), the **required-record** form (`M3e.Button.component { content = …, action = … } …`, the compiler demands the required parts — both forms share the name `component`), and the **builder** `build` / `toElement` (a pipe where a one-only setter can't be written twice). |
| **loose producer** | `M3e.Html.*` — one open-rowed constructor per component (no slot/attribute checking), which each strict `M3e.<Component>` surface tightens. Reach for it to opt out of the strict phantom rows while staying in the IR. **Not plain HTML** — it exposes the `m3e-*` elements, not `div`/`span`. |
| **escape** | A call that leaves the typed tree — always loud, greppable, and lint-fenced. The one userland surface: `M3e.Unsafe` / `.Unsafe.Attributes` (`fromHtml` / `fromNode` / `fromHtmlAttribute` lift raw `Html`; `recast` / `recastAll` / `recastAttr` / `recastAttrAll` re-kind to free phantom rows; `customElement` / `customAttribute` forge a tag or attribute the library has no producer for). It ships with the library — there is no userland module to hand-write. Underneath, these are built on the raw forge `HtmlIr.Internal` (`fromNode`, `node` / `attribute` / `property` / `on`, `lazy`), which application code never imports directly. There is no second, config-blessed kind-crossing module — a specific, recurring crossing is a small named function built on `recast`, not a generated one. |
| **barrel** | The one-import API: `import M3e`, every component's constructor in one place, plus `text` — and the whole substrate, re-exported so consumers never import `HtmlIr`: `Element` / `Attr` / `Node` / `toHtml` / `toNode` / `mapMsg` / `mapNode` (also on `M3e.Html`), plus `Value` (via `M3e.Values`) and `Supported` / `Shared` (via `M3e.Kind`) one import away. |
| **component module** | The per-component import (`import M3e.Button`) — same components, tighter types, and where the required-record `component` form / `build` and the compile-tight setters live. |
| **shared / per-component vocabulary** | `M3e.Attributes.*` and `M3e.Values.*` close over the library-wide **union** of values (cross-component misuse is caught by elm-review); the per-component `M3e.<Component>.<attr>` setters are **compile-tight**. |
| **kind** | The category a piece of content is — icon, text, button. |
| **slot** | A labeled place a component puts content; each slot declares the kinds it accepts. |
| **token** | An enum value that exists as a name (`M3e.Values.filled`) — invalid tokens aren't names at all. |
| **seam** | Not something you build — the *practice* of reaching for the library's escapes instead of improvising around the type system. The mechanism is a brand `Unsafe` module, shipped with the library: `M3e.Unsafe.recast` re-kinds an element to fit any slot ("the design system is wrong here"). This docs app calls it from small, named producers, kept next to the code that needs them. |
| **component facts** | The generated per-component list (required slots, valid tokens, required attributes) that the linter reads — the same list the API was generated from. |
| **manifest** | The components' machine-readable self-description that everything above is generated from. |"""

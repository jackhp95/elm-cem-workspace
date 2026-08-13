module Route.Guide.CheatSheet exposing (ActionData, Data, Model, Msg, route)

{-| Guide · Cheat sheet (`/guide/cheat-sheet`): the return-worthy tables in one
place — the surfaces, the strictness dial, loose vs. tight vocabulary, and where
a seam is allowed to live. Scannable reference, not narrative; the chapters teach
these, this is where you come back to look them up.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e
import M3e.Attributes
import M3e.Component.Heading
import M3e.Values as Value
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Sectioning
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
        , description = "The Guide cheat sheet: the surfaces, the strictness dial, loose vs. tight vocabulary, and the seam allow-list — the return-worthy tables in one place."
        , locale = Nothing
        , title = "Cheat sheet · elm-m3e"
        }
        |> Seo.website


card : String -> List (M3e.Element (M3e.Component.Heading.Is s) (TypedHtml.Sectioning.SectionChildAdmittedBy childAdm) msg) -> M3e.Element (TypedHtml.Sectioning.SectionIs s2) adm_ msg
card title items =
    TypedHtml.section [ TA.class "space-y-3" ]
        (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text title ] :: items)


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Cheat sheet"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-10" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Cheat sheet"
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
                    , Doc.userlandNote
                    ]
                , card "The surfaces" [ Doc.markdown layers ]
                , card "Barrel vs component module" [ Doc.markdown barrelVsSpecific, Doc.codeBlock Doc.Elm barrelVsSpecificCode ]
                , card "The three forms" [ Doc.markdown shapes, Doc.codeBlock Doc.Elm shapesCode ]
                , card "The strictness dial" [ Doc.markdown dial ]
                , card "Where a seam may live" [ Doc.markdown seams ]
                ]
            ]
        )


intro : String
intro =
    """Look-up tables for the ideas the [Guide](/guide) teaches. Come back here; keep the chapters for the story."""


layers : String
layers =
    """From [the surface map](/guide/the-layers). A component is one typed value; the surfaces are peer call-shapes, and `M3e.Html.*` / the escapes are how you loosen or leave the typed tree.

| Surface | What it is | You reach for it |
| --- | --- | --- |
| **barrel / `view`** | The standard form — typed, slot-safe, composes into other components. | Almost always — the default. |
| **`el` (required record)** | Same value; the compiler demands the required parts. | The 29 components with a required record, when you must not forget it. |
| **`build` + `toElement`** | Same value via a pipe; one-only setters unwritable twice. | Conditional or order-free construction. |
| **`M3e.Html.*` (loose)** | The open-rowed producer — no slot/attr checking, still in the IR. Not plain HTML. | Opting out of the strict rows on purpose. |
| **`M3e.Coerce` / `M3e.Unsafe`** | Escapes: kind crossing / raw `Html`. Loud, greppable, lint-flagged. | Leaving the typed tree when nothing else fits. |"""


barrelVsSpecific : String
barrelVsSpecific =
    """A second axis, orthogonal to the surfaces: *which import you reach through*. Same output either way; the [reference](/guide/reference) documents both.

| Import | Statement | You get |
| --- | --- | --- |
| **barrel** | `import M3e` | One import for every component's `view` form, plus `text` and `toHtml`. Pair it with the shared `M3e.Attributes` / `M3e.Values` / `M3e.Events` vocabulary (library-wide unions, lint-checked). |
| **component module** | `import M3e.Button` | Component-scoped types and setters — a token or slot child wrong for *this* component won't compile; also where `el` / `build` live. |"""


barrelVsSpecificCode : String
barrelVsSpecificCode =
    """-- barrel — one import, shared vocabulary (M3e.Attributes.* unions, lint-checked)
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.Component.Button.icon (M3e.icon [ TA.name "save" ] []), M3e.text "Save" ]

-- component module — component-scoped setters, compile-tight tokens
M3e.Component.Button.view [ M3e.Component.Button.variant Value.filled ] [ M3e.text "Save" ]"""


shapes : String
shapes =
    """From [the strictness dial](/guide/strictness). All three render the *same* component; they differ only in what you may leave out. **Peers, not a ranking.**"""


shapesCode : String
shapesCode =
    """-- the standard form — everything optional; the tersest
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- required-record form — the compiler demands the parts it can't do without
M3e.Component.Button.el { content = M3e.text "Save", action = M3e.Action.onClick Save } [] []

-- builder pipe — a one-only setter is unwritable twice; order-free
M3e.Build.Button.build { content = M3e.text "Save", action = M3e.Action.onClick Save }
    |> M3e.Build.Button.toElement"""


dial : String
dial =
    """The compiler always checks that kinds line up and only real tokens exist. Everything softer is opt-in, two ways — turn on either, or both:

| You add | How | Caught |
| --- | --- | --- |
| Invalid token for *this* component · empty required slot · foreign slot child · missing accessible name | run the **linter** in CI | project-wide |
| Required parts can't be forgotten | the **required-record** form | per call site |
| A one-only setter can't be written twice | the **pipeline** form | per call site |"""


seams : String
seams =
    """From [your own seam](/guide/seams). Everything is a typed `Element` from `M3e.*` / `TypedHtml.*`, composed directly — you never import `HtmlIr` (the barrel re-exports `M3e.Element` / `M3e.Attr` and `M3e.mapMsg`). To bring in something *foreign*, there is exactly one loud, greppable, lint-fenced escape surface, shipped with the library itself:

| Escape | What it gives you |
| --- | --- |
| **`<Brand>.Unsafe`** / **`.Unsafe.Attributes`** | `fromHtml` / `fromHtmlAttribute` lift raw `Html`; `recast` / `recastAttr` re-kind to free rows so anything drops into any slot; `customElement` / `customAttribute` forge a tag or attribute the library has no producer for. Fenced by `NoUnsafeImportOutsideAllowed`. |

Underneath, `Unsafe` is built on the raw forge `HtmlIr.Internal` (`fromNode`, `node` / `attribute` / `property` / `on`, `lazy`..`lazy8`) — but that forge is fenced to the library's own generated code by `NoInternalImportOutsideAllowed`; application code has no reason to import it.

A "seam" isn't a library feature — it's the *practice* of corralling those escapes into one greppable place, a small named producer next to the code that needs it. Anywhere else a raw escape is flagged, and the linter offers to lift it into an escape for you."""

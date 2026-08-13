module Route.Guide.ToolingRefactors exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/tooling-refactors`): the wow chapter. The linter
isn't only a catch-net — it _refactors for you_. Two moves: it extracts an
inline raw escape into a named seam and rewrites your call site; and it converts
your whole codebase to one approved form, routing anything the target can't
express through seams (which the boundary check then flags). Shown as real
before/after code, not invented.
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
        , description = "The linter doesn't just flag — it rewrites a needless escape to the typed setter that already covers it, and converts your codebase to one approved form, with autofix."
        , locale = Nothing
        , title = "The tooling refactors for you · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "The tooling refactors for you"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The tooling refactors for you"
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown extract
                    , Doc.codeBlock Doc.Elm extractBefore
                    , Doc.codeBlock Doc.Elm extractAfter
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown convert
                    , Doc.codeBlock Doc.Elm convertBefore
                    , Doc.codeBlock Doc.Elm convertAfter
                    , Doc.markdown pipeline
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """Everything so far had you *reading* the tooling's output — a compile error, a lint message. This chapter flips it: the linter **writes code for you**. It knows your components (it reads the same manifest the API was generated from), so it can not only flag a problem but apply the fix. Here are the two moves that matter."""


extract : String
extract =
    """**One — it removes the escapes you never needed.** You inline a raw escape in a feature module — a stray `class` on an element. The linter flags it *and names the typed setter that already covers it*: it reads the same component manifest the API was generated from, so it knows `class` has one. Run the autofix and the call site is rewritten to that setter. The escape doesn't move somewhere tidier — it stops existing. Before:"""



-- @sample expect-review NoRedundantAttributeEscape: this IS the finding the
-- section is about. Verified to be flagged by the named rule, so the "before"
-- can never quietly become something the linter would accept.


extractBefore : String
extractBefore =
    """-- a raw escape inlined in a feature module, for something the library
-- already models: `class` has a typed setter, so this is a needless escape
M3e.button [ M3e.Unsafe.Attributes.fromHtmlAttribute (Html.Attributes.class "flex-auto") ] [ M3e.text "Save" ]"""


extractAfter : String
extractAfter =
    """-- after autofix: the typed setter, no escape at all
M3e.button [ TypedHtml.Attributes.class "flex-auto" ] [ M3e.text "Save" ]"""


convert : String
convert =
    """**Two — it converts your codebase to one approved form.** Pin a canonical form and run the autofix; every call site is rewritten to it. This is real: these docs pin the one-import **barrel** form (`preferBarrel`, in `review/src/ReviewConfig.elm`), and the linter rewrote every per-component call site to it automatically. Before and after, from an actual autofix run:"""


convertBefore : String
convertBefore =
    """-- the per-component surface — what you might write, or arrive with
M3e.Component.Button.view [ M3e.Component.Button.variant Value.filled ] [ M3e.text "Save" ]"""


convertAfter : String
convertAfter =
    """-- after autofix: the pinned form — one import, the shared vocabulary
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]"""


pipeline : String
pipeline =
    """Anything the target form can't express doesn't vanish — it falls out as **residue routed through a seam**, and the seam-boundary check flags that on the next pass. So the rules interplay as a pipeline: *convert → residue → flag → extract*. You didn't refactor; the linter did, and it converges. Discipline is maintained **for** you."""


recap : String
recap =
    """- The linter **applies fixes**, not just warnings — it knows your components.
- It **removes escapes the typed layer already covers** — naming the setter and rewriting the call site for you, so the escape is gone rather than relocated.
- It **converts your codebase to one approved form**; residue routes through seams and gets flagged next pass.
- **Next: [Troubleshooting](/guide/troubleshooting) →** when something does go wrong, how to read and rescue it."""

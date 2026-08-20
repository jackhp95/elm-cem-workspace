module Route.Guide.ToolingRefactors exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/tooling-refactors`): the wow chapter. The linter
isn't only a catch-net — it _refactors for you_. Two moves: it extracts an
inline raw escape into a named seam and rewrites your call site; and it converts
your whole codebase to one approved form, routing anything the target can't
express through seams (which the boundary check then flags). Shown as real
before/after code, not invented.
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
    BackendTask.File.rawFile "content/guides/ToolingRefactors.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


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
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        extract : String
        extract =
            Doc.section "extract" d

        convert : String
        convert =
            Doc.section "convert" d

        pipeline : String
        pipeline =
            Doc.section "pipeline" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "The tooling refactors for you"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The tooling refactors for you"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
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


convertBefore : String
convertBefore =
    """-- the per-component surface — what you might write, or arrive with
M3e.Component.Button.component { content = M3e.text "Save", action = M3e.Action.none } [ M3e.Component.Button.variant Value.filled ] []"""


convertAfter : String
convertAfter =
    """-- after autofix: the pinned form — one import, the shared vocabulary
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]"""

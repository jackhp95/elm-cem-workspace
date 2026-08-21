module Route.Guide.AccessibleByConstruction exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/accessible-by-construction`): accessibility as
structure, not a checklist. An icon-only control has no visible text, so its
accessible name is required. The Aria setters are first-class on every
component, and the codegen-aware `missingRequiredAttribute` rule reads the
per-component facts and refuses a nameless control when elm-review runs in CI.
The running example gains an icon-only help button (labeled, live); the nameless
version is shown as code beside the rule's real output.
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
import M3e.Action
import M3e.Element.IconButton
import M3e.Kind
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
    BackendTask.File.rawFile "content/guides/AccessibleByConstruction.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "An icon-only control's accessible name is required. The Aria setters are first-class, and the codegen-aware missingRequiredAttribute linter rule refuses a nameless control when elm-review runs in CI."
        , locale = Nothing
        , title = "Accessibility you can't forget · elm-m3e"
        }
        |> Seo.website


{-| An icon-only help button — WITH its accessible name. This is the version
you should ship and it renders. The nameless version is shown only as code,
beside the real output of the `missingRequiredAttribute` rule.
-}



-- @sample-source-body guideHelpButton


helpButton : Element { s | iconButton : M3e.Kind.Brand } adm_ msg
helpButton =
    M3e.Element.IconButton.component { content = M3e.icon [ TA.name "help" ] [], ariaLabel = "Help", action = M3e.Action.none } [] []


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        labeled : String
        labeled =
            Doc.section "labeled" d

        nameless : String
        nameless =
            Doc.section "nameless" d

        wiring : String
        wiring =
            Doc.section "wiring" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Accessibility you can't forget"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Accessibility you can't forget"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown labeled
                    , Doc.showcase helpButton
                    , Doc.codeBlock Doc.Elm Samples.guideHelpButton
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown nameless
                    , Doc.codeBlock Doc.Elm namelessCode
                    , Doc.codeBlock Doc.NoLang linterText
                    , Doc.markdown wiring
                    ]
                , Doc.recapBox recap
                ]
            ]
        )



-- @sample expect-compile-error: the page's claim, in one line. It does NOT
-- compile — that is the point — the required-record `el` shape is what
-- refuses it, so this is checked against a real `elm make` run, not a lint
-- pass. (Pre `el`-unification this was `expect-review MissingRequiredAttribute`
-- — a linter guarantee; the required-record collapse promoted the SAME check
-- to a compiler guarantee.)


namelessCode : String
namelessCode =
    """M3e.Element.IconButton.component
    { content = M3e.icon [ TA.name "help" ] [], action = M3e.Action.none }
    []
    []"""


linterText : String
linterText =
    """-- TYPE MISMATCH --

The 1st argument to `component` is not what I expect:

17|     M3e.Element.IconButton.component
18|>        { content = M3e.icon [ TA.name "help" ] [], action = M3e.Action.none }
19|         []
20|         []

This argument is a record of type:

    { action : M3e.Action.Action capability msg1
    , content : M3e.Element (M3e.Element.Icon.Is s) admittedBy msg
    }

But `component` needs the 1st argument to be:

    { action : M3e.Action.Action M3e.Element.IconButton.ActionCaps msg
    , ariaLabel : String
    , content :
          HtmlIr.Element.Element
              M3e.Element.IconButton.Content
              (M3e.Element.IconButton.ChildAdmittedBy childAdm)
              msg
    }

Hint: Looks like the ariaLabel field is missing."""

module Route.Guide.AccessibleByConstruction exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/accessible-by-construction`): accessibility as
structure, not a checklist. An icon-only control has no visible text, so its
accessible name is required. The Aria setters are first-class on every
component, and the codegen-aware `missingRequiredAttribute` rule reads the
per-component facts and refuses a nameless control when elm-review runs in CI.
The running example gains an icon-only help button (labeled, live); the nameless
version is shown as code beside the rule's real output.
-}

import BackendTask
import Doc
import Guide.Samples as Samples
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Action
import M3e.Component.IconButton
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
    M3e.Component.IconButton.component { content = M3e.icon [ TA.name "help" ] [], ariaLabel = "Help", action = M3e.Action.none } [] []


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
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


intro : String
intro =
    """Accessibility here is built into the shape of the components, not bolted on as a checklist at the end. The clearest case: a control with no visible text. Our settings panel needs a small **help** button that's just an icon. A sighted user sees a "?"; a screen-reader user needs a name to read. So that name is **required** — and the accessible-name attributes (`Aria.label`, `labelledby`, `describedby`) are first-class setters on every component, right where you'd reach for them."""


labeled : String
labeled =
    """Add the help button *with* its accessible name and it's fine — this renders, and it announces itself as "Help":"""


nameless : String
nameless =
    """Now drop the name. Since the `el`-unification, an icon button's accessible name isn't a linter-checked attribute anymore — `ariaLabel` is a **required record field** on `IconButton.component` itself, the same required-record mechanism that makes forgetting a Button's `action` impossible (see [the strictness dial](/guide/strictness)). Try to omit it and the build stops — the message below is the compiler's real output:"""



-- @sample expect-compile-error: the page's claim, in one line. It does NOT
-- compile — that is the point — the required-record `el` shape is what
-- refuses it, so this is checked against a real `elm make` run, not a lint
-- pass. (Pre `el`-unification this was `expect-review MissingRequiredAttribute`
-- — a linter guarantee; the required-record collapse promoted the SAME check
-- to a compiler guarantee.)


namelessCode : String
namelessCode =
    """M3e.Component.IconButton.component
    { content = M3e.icon [ TA.name "help" ] [], action = M3e.Action.none }
    []
    []"""


linterText : String
linterText =
    """-- TYPE MISMATCH --

The 1st argument to `component` is not what I expect:

17|     M3e.Component.IconButton.component
18|>        { content = M3e.icon [ TA.name "help" ] [], action = M3e.Action.none }
19|         []
20|         []

This argument is a record of type:

    { action : M3e.Action.Action capability msg1
    , content : M3e.Element (M3e.Component.Icon.Is s) admittedBy msg
    }

But `component` needs the 1st argument to be:

    { action : M3e.Action.Action M3e.Component.IconButton.ActionCaps msg
    , ariaLabel : String
    , content :
          HtmlIr.Element.Element
              M3e.Component.IconButton.Content
              (M3e.Component.IconButton.ChildAdmittedBy childAdm)
              msg
    }

Hint: Looks like the ariaLabel field is missing."""


wiring : String
wiring =
    """This is "accessible by construction" in practice: the requirement lives in the component's own required-record shape, so `elm make` refuses the unlabeled control instead of a human having to remember. It is a **compiler** guarantee now — no elm-review run required, no CI step to forget to wire up. And when a control has a visible label — like the text fields we build next — the label and input are wired from one shared id, so you never hand-type a matching `for`/`id` pair."""


recap : String
recap =
    """- An icon-only control has no visible text, so its **accessible name is required**.
- `ariaLabel` is a **required record field** on `IconButton.component` — omitting it is a **compile error**, not a lint finding, so there's no CI step to forget.
- Visible labels are **wired to their input for you** from one shared id — no hand-typed `for`/`id`.
- **Next: [Composition, not injection](/guide/composition-text-field) →** build a text field that doesn't exist as a component — by composition."""

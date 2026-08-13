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
import M3e.Kind
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
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
    M3e.iconButton [ Aria.label "Help" ]
        [ M3e.icon [ TA.name "help" ] [] ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Accessibility you can't forget"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Accessibility you can't forget"
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
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
    """Now drop the name. The component list the API was generated from records that an icon button **requires** an accessible name — and the codegen-aware `missingRequiredAttribute` rule reads that same list, so in a project that runs elm-review this does not pass CI. The message below is the rule's real output:"""



-- @sample expect-review MissingRequiredAttribute: the page's claim, in one line.
-- It compiles — that is the point — and the linter is what refuses it, so the
-- rule name below is checked against the real elm-review run.


namelessCode : String
namelessCode =
    """M3e.iconButton []
    [ M3e.icon [ TA.name "help" ] [] ]"""


linterText : String
linterText =
    """MissingRequiredAttribute: Component `iconButton` requires attribute `aria-label`
but this call doesn't provide it

The Material 3 spec (and accessibility guidance) treats `aria-label` as required
for iconButton.

Add `Aria.label "..."` (from `import TypedHtml.Aria as Aria`) to the attrs list."""


wiring : String
wiring =
    """This is "accessible by construction" in practice: the requirement lives in the component's own definition — the same facts file the rest of the linter reads — so CI refuses the unlabeled control instead of a human having to remember. It is a linter guarantee, not a compiler one, so it protects you when elm-review runs in CI. And when a control has a visible label — like the text fields we build next — the label and input are wired from one shared id, so you never hand-type a matching `for`/`id` pair."""


recap : String
recap =
    """- An icon-only control has no visible text, so its **accessible name is required**.
- The Aria setters are **first-class**, and `missingRequiredAttribute` **refuses a nameless control in CI** — a linter guarantee, so run elm-review there.
- Visible labels are **wired to their input for you** from one shared id — no hand-typed `for`/`id`.
- **Next: [Composition, not injection](/guide/composition-text-field) →** build a text field that doesn't exist as a component — by composition."""

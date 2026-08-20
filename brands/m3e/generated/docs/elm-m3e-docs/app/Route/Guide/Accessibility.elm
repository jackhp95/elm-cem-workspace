module Route.Guide.Accessibility exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/accessibility`): the accessibility reference for elm-m3e —
the named-slot vs `M3e.Component.Aria.label` / `Aria.label` decision, focus behavior in
Dialog / Menu / BottomSheet (what `@m3e/web` handles vs what the Elm author wires),
keyboard interaction per component family, and testing with the Playwright a11y-tree
harness in `docs/tests-browser/`. The narrow "accessible name is required" teaching
moment lives at `/guide/accessible-by-construction`; this is the fuller how-to and
mirrors the `making-m3e-accessible` skill. WCAG theory (contrast ratios,
name/role/value, focus-visible) lives in the m3e-okf knowledge base.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
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
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/Accessibility.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "The elm-m3e accessibility reference: named slot vs Aria.label, focus in dialogs/menus/sheets, keyboard per component family, and testing with the Playwright a11y-tree harness."
        , locale = Nothing
        , title = "Accessibility reference · elm-m3e"
        }
        |> Seo.website


{-| The one live example on this page: an icon-only control WITH its accessible
name, so the page itself passes the a11y-tree check it describes.
-}
labeledBack : Element { s | iconButton : M3e.Kind.Brand } adm_ msg
labeledBack =
    M3e.iconButton [ Aria.label "Back" ]
        [ M3e.icon [ TA.name "arrow_back" ] [] ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        nameBody : String
        nameBody =
            Doc.section "nameBody" d

        nameLayers : String
        nameLayers =
            Doc.section "nameLayers" d

        focusBody : String
        focusBody =
            Doc.section "focusBody" d

        focusNote : String
        focusNote =
            Doc.section "focusNote" d

        keyboardBody : String
        keyboardBody =
            Doc.section "keyboardBody" d

        divisionBody : String
        divisionBody =
            Doc.section "divisionBody" d

        reviewBody : String
        reviewBody =
            Doc.section "reviewBody" d

        testingBody : String
        testingBody =
            Doc.section "testingBody" d

        testingNote : String
        testingNote =
            Doc.section "testingNote" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Accessibility reference"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Accessibility reference"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Accessible name: named slot vs ARIA label") "Accessible name: named slot vs ARIA label"
                    , Doc.markdown nameBody
                    , Doc.showcase labeledBack
                    , Doc.codeBlock Doc.Elm nameCode
                    , Doc.markdown nameLayers
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Focus: dialogs, menus, sheets") "Focus: dialogs, menus, sheets"
                    , Doc.markdown focusBody
                    , Doc.codeBlock Doc.Elm focusCode
                    , Doc.markdown focusNote
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Keyboard interaction by component family") "Keyboard interaction by component family"
                    , Doc.markdown keyboardBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "What ships vs what you wire") "What ships vs what you wire"
                    , Doc.markdown divisionBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Read the review errors as a11y guidance") "Read the review errors as a11y guidance"
                    , Doc.markdown reviewBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Testing with the a11y-tree harness") "Testing with the a11y-tree harness"
                    , Doc.markdown testingBody
                    , Doc.codeBlock Doc.NoLang testingCode
                    , Doc.markdown testingNote
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


nameCode : String
nameCode =
    """-- Visible text: the slot content is the name. Nothing extra.
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- Icon-only: the name is REQUIRED — supply it explicitly.
M3e.iconButton [ Aria.label "Back" ]
    [ M3e.icon [ TA.name "arrow_back" ] [] ]

-- Sneaky case: a Switch/Radio in a list row whose visible label is a SIBLING
-- ListItem text, not its own — it still needs its own name.
M3e.switch [ Aria.label "Push notifications", M3e.Attributes.checked on ] []"""


focusCode : String
focusCode =
    """-- Elm owns the open STATE; @m3e/web owns the focus trap + Escape + return-focus.
M3e.dialog
    [ M3e.Attributes.open model.dialogOpen
    , M3e.Component.Dialog.onClosed CloseDialog
    ]
    [ M3e.Component.Dialog.header (M3e.text "Delete file?")
    , M3e.text "This cannot be undone."
    , M3e.Component.Dialog.actions confirmButtons
    ]"""


testingCode : String
testingCode =
    """// After the elements have upgraded (poll for shadowRoot first):
const snapshot = await page.accessibility.snapshot();

// Walk the tree; fail if any interactive node has an empty accessible name.
function unnamed(node, acc = []) {
  const interactive = ["button", "link", "switch", "radio", "checkbox", "slider"];
  if (interactive.includes(node.role) && !node.name) acc.push(node);
  (node.children || []).forEach((c) => unnamed(c, acc));
  return acc;
}
expect(unnamed(snapshot)).toEqual([]);"""

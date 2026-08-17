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

import BackendTask
import Doc
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
view _ _ =
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


intro : String
intro =
    """Accessibility in elm-m3e is largely *structural*, not a checklist you run at the end — an icon-only control has no visible text, so its accessible name is *required* by the component's own facts (the [Accessibility you can't forget](/guide/accessible-by-construction) chapter shows that one idea live). This page is the fuller reference: how to name every control, who owns focus in dialogs and menus, what keyboard behavior each family gives you for free, and how to spot-check the result.

For WCAG *rationale* — the contrast ratios, the name/role/value model, why focus-visible matters — read the **m3e-okf knowledge base** (`github.com/jackhp95/m3e-okf`, `foundations/accessibility`). This page is the Elm practice that applies it, and it is kept in lockstep with the `making-m3e-accessible` skill."""


nameBody : String
nameBody =
    """Every interactive control needs an accessible name. Decide by whether the control already has visible text:

- **Has visible text** (a labelled button, a nav item with a label) — the text *is* the name. The named/text slot supplies it; add nothing.
- **Icon-only** (icon button, icon-only FAB, a `Switch`/`Radio` whose label sits in a sibling) — there is no text, so an explicit ARIA name is **required**.
- **Name lives in another visible element** — reference it with `Aria.labelledby "that-id"` instead of duplicating the string.

The shipped, correct icon-only control (this one renders and announces as "Back"):"""


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


nameLayers : String
nameLayers =
    """The ARIA name is a *global HTML attribute*, so it comes from one place: the shared native IR's `TypedHtml.Aria` axis. Import it once (`import TypedHtml.Aria as Aria`) and reach for `Aria.label "Back"` or `Aria.labelledby "…"` on *any* component — every `M3e.*` attribute list accepts these globals, so elm-m3e does **not** re-expose a per-component `ariaLabel` setter. (The exception is icon-only `FAB`/`IconButton`, where the accessible name is a *required* argument of the component itself, not an optional attribute — see [Accessibility you can't forget](/guide/accessible-by-construction).) The trailing `Switch`/`Radio` in the [Settings example](/examples/settings) pass `Aria.label label` on every control for exactly the sibling-label reason above."""


focusBody : String
focusBody =
    """Overlay components — `Dialog`, `Menu`, `BottomSheet`, `Select` — carry the *intra*-component focus contract themselves: when `@m3e/web` opens the overlay it moves focus into it, **traps** focus inside while open (Tab cycles within, does not escape to the page behind), closes on `Escape`, and returns focus to the trigger on close. You do not write a focus trap. What you *do* own is the decision of *when* the overlay is open (its `open` state lives in your model) and any focus you want to place on a *specific* element once it opens."""


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


focusNote : String
focusNote =
    """The one thing to get right yourself: **focus across *route* or app-state changes** that are not an overlay — e.g. after a client-side navigation, moving focus to the new page's heading so a screen-reader user is not stranded at the top of a stale document. No component can see a route change, so that is app-shell work. Rule of thumb: `@m3e/web` owns focus *inside* a component's own lifecycle; *you* own focus *between* components and across navigation."""


keyboardBody : String
keyboardBody =
    """Each component family ships its own keyboard model — roving focus and the expected keys — so a keyboard user gets native behavior without you binding a single handler:

| Family | Keys you get for free |
|--------|-----------------------|
| **Buttons / FAB / chips** | `Enter` / `Space` activate; `Tab` moves between them |
| **Menu / Select** | `↑` `↓` move the active item (roving focus), `Enter` selects, `Esc` closes, typeahead jumps |
| **List / NavRail / NavBar** | Arrow keys move within the group; `Tab` enters/leaves the group once |
| **Tabs** | `←` `→` move the active tab, `Home`/`End` jump to ends, the panel follows |
| **Radio group** | Arrow keys move selection *within* the group; the group is one `Tab` stop |
| **Slider** | Arrow keys step the value; `Home`/`End` go to min/max |
| **Dialog / BottomSheet** | `Esc` closes; `Tab` is trapped within |

Two things this table implies you own: give a `Radio` group **one shared `name`** so it reads and arrows as a single control (the Settings `themeRow` uses `TA.name "theme"`), and keep **DOM/slot children in meaningful order**, because screen readers and Tab both follow source order."""


divisionBody : String
divisionBody =
    """The clean split, stated once:

| Handled by `@m3e/web` (the element) | You wire (Elm side) |
|-------------------------------------|---------------------|
| Roving focus / arrow-key nav within a component | The **accessible name** of icon-only controls (`Aria.label`) |
| Focus trap, `Escape`, return-focus on its own overlays | **Focus across route/state changes** (into a new page's heading) |
| Focus ring / focus-visible (strengthen with `Theme.strongFocus`) | **Grouping semantics** you own (shared `name` on a radio group) |
| `disabled` / `checked` state on the element | **Live-region / status** announcements for your app's state changes |

And never signal state by **color alone** — the knowledge base's `color-only-state-signaling` anti-pattern — pair it with an icon, text, or an `aria-*`."""


reviewBody : String
reviewBody =
    """The codegen-aware review rules (from `elm-review-cem`, wired in `review/src/ReviewConfig.elm`) are accessibility feedback, not bureaucracy. `missingRequiredAttribute` on a control that lists `aria-label` in its required attributes means "this control has no accessible name; add `Aria.label`" — it reads the per-component facts and refuses the nameless control when elm-review runs in CI. `RequireSlot` means a required semantic slot (a label, a title) is absent — often the same "no accessible name" problem seen as structure. These are **advisory / report-only** for content the analyzer can't resolve statically (dynamic, `List.map`-built rows): a static-analysis limit, not a bug. A green `elm-review` is *necessary but not sufficient* — still spot-check the a11y tree."""


testingBody : String
testingBody =
    """The docs ship a Playwright browser harness (`docs/tests-browser/`, `docs/playwright.config.ts`) plus a one-shot transform (`docs/scripts/a11y-icon-button-labels.mjs`) that gives every icon-only example an accessible name. The recipe for spot-checking *your own* app:

1. Serve the app and **wait until the custom elements upgrade** — poll for a component's `shadowRoot` rather than `networkidle`, which never fires under the dev SSE stream.
2. Snapshot the accessibility tree and assert every interactive node has a non-empty accessible name.
3. `Tab` through and assert the focus order is sensible and a visible focus ring appears.
4. For dialogs/menus, assert `Escape` closes and focus returns to the trigger."""


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


testingNote : String
testingNote =
    """This is exactly the class of guarantee `elm-review` *cannot* give for dynamic content, so it is the backstop, not a duplicate. See `docs/tests-browser/contract.spec.ts` for how the repo waits for shadow-DOM upgrade before asserting anything against these elements."""


recap : String
recap =
    """- **Accessible name**: visible text names itself; **icon-only controls require** `Aria.label` (or `labelledby`) — first-class on every component.
- **Overlays own their focus**: `@m3e/web` traps focus, handles `Escape`, and returns focus on close for `Dialog`/`Menu`/`BottomSheet`. You own the **open state** and **focus across route/state changes**.
- **Keyboard is free per family** — roving focus, arrows, `Enter`/`Esc`. You still own a radio group's **shared `name`** and **source order**.
- Read `missingRequiredAttribute` / `RequireSlot` as a11y guidance; they are **advisory for dynamic content**, so **spot-check the a11y tree** with the Playwright harness.
- WCAG theory lives in **m3e-okf** (`foundations/accessibility`); this page is the Elm practice, kept in sync with the `making-m3e-accessible` skill."""

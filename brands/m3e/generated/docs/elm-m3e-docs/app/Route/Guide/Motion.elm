module Route.Guide.Motion exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/motion`): the motion division of responsibility. Material 3
Expressive motion (spring physics, shape morphing, state-layer ripples, enter/exit
choreography) ships _inside_ the `@m3e/web` custom elements and is driven by the
`M3e.Theme` motion scheme — you do not hand-animate it. What the Elm author controls
is the motion _between_ those components: the AVT snackbar in `js/avt-snackbar.js`,
cross-route view transitions, and honoring reduced-motion. Deep motion physics
(spring constants, duration/easing tokens) lives in the m3e-okf knowledge base and the
`/styles/motion` token page; this page draws the boundary.
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
        , description = "Material 3 Expressive motion ships inside the @m3e/web components — springs, shape morph, ripples. The Elm author controls the motion between them: the AVT snackbar, view transitions, and reduced-motion."
        , locale = Nothing
        , title = "Motion: what ships, what you wire · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Motion: what ships, what you wire"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Motion: what ships, what you wire"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Inside the components (you don't animate this)") "Inside the components (you don't animate this)"
                    , Doc.markdown shippedBody
                    , Doc.codeBlock Doc.Elm shippedCode
                    , Doc.markdown shippedNote
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "The motion between components (you wire this)") "The motion between components (you wire this)"
                    , Doc.markdown authorBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "The AVT snackbar") "The AVT snackbar"
                    , Doc.markdown snackbarBody
                    , Doc.codeBlock Doc.Elm snackbarCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "View transitions") "View transitions"
                    , Doc.markdown viewTransBody
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.sectionHeadingWithId (Doc.slugify "Reduced motion is not optional") "Reduced motion is not optional"
                    , Doc.markdown reducedBody
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """Material 3 Expressive is, in large part, a *motion* system: springy emphasis, shape that morphs under pressure, state layers that ripple, containers that expand and collapse with choreographed enter/exit. The good news for an Elm author is that almost none of this is yours to implement. It ships **inside** the `@m3e/web` custom elements, and you turn its character up or down with a single `M3e.Theme` input. What you *do* own is the motion *between* components — the transitions your app state drives.

For the neutral motion *theory* — the spring model, the duration and easing token scale, why expressive emphasis reads as more alive — see the **m3e-okf knowledge base** (`github.com/jackhp95/m3e-okf`, `styles/motion`) and the token catalog on the [Styles → Motion](/styles/motion) page. This guide draws the boundary between the two."""


shippedBody : String
shippedBody =
    """The custom elements animate themselves. A `Button` ripples its state layer on press; a `Fab` and the shape components morph corner geometry; a `Dialog`, `BottomSheet`, `Menu`, and `Accordion` run their own choreographed enter/exit; a `Switch`/`Slider` thumb springs to its new position; `NavItem` indicators slide. You never write a keyframe or a transition for any of it. You choose its *character* once, at the root, with the `M3e.Theme` motion scheme:"""


shippedCode : String
shippedCode =
    """import M3e.Component.Theme as Theme

Theme.component
    [ Theme.color model.seed
    , Theme.motion M3e.Values.expressive  -- spring-like emphasis (M3E's signature)
    -- , Theme.motion M3e.Values.standard   -- functional, restrained transitions
    ]
    [ appBody ]"""


shippedNote : String
shippedNote =
    """`M3e.Values.standard` gives the restrained, functional easing of classic Material; `M3e.Values.expressive` turns on the springy, higher-energy emphasis that is the point of Material 3 *Expressive*. It is one input, published to every nested component through the `--md-sys-motion-*` tokens — the same theme-at-the-root pattern as color (see [Theming](/guide/theming)). Do not try to reproduce a spring by hand in Elm; you would fight the element's own animation and lose the token-scheme coupling."""


authorBody : String
authorBody =
    """Elm owns the transitions your *application* drives — the ones no single component can see, because they cross component or route boundaries:

| Motion | Owner | How |
|--------|-------|-----|
| Ripple / press feedback, shape morph, thumb spring | `@m3e/web` | Ships in the element; tune via `Theme.motion` |
| Dialog / sheet / menu enter + exit | `@m3e/web` | The element choreographs its own open/close |
| A **snackbar** sliding in on app state | **You** | Render the AVT snackbar element (below) |
| **Cross-route** page transition | **You** | The browser View Transitions API, opt-in |
| A list reordering, a filtered set reflowing | **You** | Your own state + a transition you author |
| Respecting `prefers-reduced-motion` | **Shared** | The elements honor it; your own transitions must too |

Rule of thumb: if the motion belongs to *one component's own lifecycle*, it is already handled. If the motion expresses *your app changing state*, it is yours to wire."""


snackbarBody : String
snackbarBody =
    """A snackbar is the clearest "you wire it" case: it appears because *your app* decided to announce something, so its visibility and timing are Elm's. `@m3e/web`'s snackbar is imperative (`M3eSnackbar.open(...)`), which does not fit Elm's declarative render. The repo bridges that gap with a tiny declarative custom element, [`js/avt-snackbar.js`](https://github.com/jackhp95/elm-m3e/blob/main/js/avt-snackbar.js): Elm owns visibility (render the element when you want a toast shown), and the element drives the imperative singleton on connect. It reads `message` / `action` / `dismissible` / `duration` attributes and dispatches a bubbling `avt-snackbar-action` event you round-trip back to a `Msg`:"""


snackbarCode : String
snackbarCode =
    """-- Elm owns WHEN the snackbar exists; the element owns the slide-in animation.
-- Render the <avt-snackbar> element (via `M3e.Unsafe.customElement`) only while
-- shown — mounting it is what triggers the toast:
snackbar : Toast -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
snackbar t =
    M3e.Unsafe.customElement "avt-snackbar"
        [ M3e.Unsafe.Attributes.customAttribute "message" t.message
        , M3e.Unsafe.Attributes.customAttribute "action" "Undo"
        , M3e.Unsafe.Attributes.customAttribute "dismissible" ""
        ]
        []

-- The `avt-snackbar-action` CustomEvent (detail.id) comes back through a
-- port/subscription and becomes a Msg — see Ui.Snackbar in the docs kit."""


viewTransBody : String
viewTransBody =
    """Cross-route motion — the whole page morphing as you navigate — is the browser's **View Transitions API**, not a component concern. It is opt-in and progressive: where it is unsupported the navigation simply happens instantly, with no broken state. Because elm-pages owns navigation, wiring it is an app-shell concern (a `view-transition-name` on the shared elements and a `startViewTransition` on route change), not something any `M3e.*` component provides. Keep these transitions *functional* — they orient the user across a route change; they are not decoration — and always let them degrade to an instant cut."""


reducedBody : String
reducedBody =
    """Some users set `prefers-reduced-motion` because motion makes them ill. This is an accessibility requirement, not a preference to ignore. The `@m3e/web` elements already honor it, and the docs' own JS does too — [`js/slide-panels.js`](https://github.com/jackhp95/elm-m3e/blob/main/js/slide-panels.js) notes that its height/transform transitions are zeroed by a `prefers-reduced-motion` media query in CSS, so no JS branch is needed. **Any motion you author yourself must do the same**: gate your CSS transitions behind `@media (prefers-reduced-motion: no-preference)`, and never make a state change *depend* on an animation completing. See [Accessibility](/guide/accessible-by-construction)."""


recap : String
recap =
    """- Expressive motion — **springs, shape morph, ripples, sheet/menu choreography — ships inside `@m3e/web`**. You never keyframe it.
- Choose its character once with **`Theme.motion` (`standard` vs `expressive`)** at the root; it publishes `--md-sys-motion-*` to everything.
- **You wire the motion *between* components**: the [`avt-snackbar`](https://github.com/jackhp95/elm-m3e/blob/main/js/avt-snackbar.js) (Elm owns visibility, the element owns the slide), cross-route **view transitions**, and your own reflow transitions.
- **Reduced motion is required**: the elements honor it, and so must anything you author — gate transitions behind `prefers-reduced-motion: no-preference`.
- Deep motion physics and the token scale live in **m3e-okf** and the [Styles → Motion](/styles/motion) page; this page is just the boundary."""

module Route.Guide.InvalidStates exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/invalid-states`): the headline promise, felt.
Every piece carries an invisible tag for the KIND of content it is; every slot
says which kinds it accepts; a mismatch is a compile error. The running Save
button gains an icon (valid), and putting the wrong kind of thing in the icon
slot stops the build — shown as the real compiler output, not an assertion.
-}

import BackendTask
import Doc
import Guide.Samples as Samples
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Button
import M3e.Kind
import M3e.Values as Value
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
        , description = "Every piece is tagged with its kind of content and every slot says which kinds it accepts, so a wrong composition is a compile error — the browser never sees the mistake."
        , locale = Nothing
        , title = "Invalid states don't compile · elm-m3e"
        }
        |> Seo.website


{-| The running Save button, now with a leading icon in its dedicated icon slot.
This is the VALID version — the one that renders. The chapter's failures are
shown as real compiler text, not built here.
-}



-- @sample-source-body guideSavedButton


savedButton : Element { s | button : M3e.Kind.Brand } adm_ msg
savedButton =
    M3e.button [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Button.icon (M3e.icon [ TA.name "save" ] [])
        , M3e.text "Save"
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Invalid states don't compile"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Invalid states don't compile"
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown valid
                    , Doc.showcase savedButton
                    , Doc.codeBlock Doc.Elm Samples.guideSavedButton
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown broken
                    , Doc.codeBlock Doc.Elm brokenCode
                    , Doc.codeBlock Doc.NoLang errorText
                    , Doc.markdown readError
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """Here's the promise that started this: **put the wrong thing in the wrong place and the *build* stops — not the browser.** Two plain ideas do all the work.

Every piece of content carries an invisible tag for its **kind** — the category it is: an icon, some text, a button. And every **slot** — a labeled place a component puts content — declares which kinds it will accept. Line those up and it compiles. Mismatch them and it doesn't."""


valid : String
valid =
    """Give the Save button a leading icon. The button has an `icon` slot, and that slot accepts icon-kind content. `M3e.icon` is icon-kind, so it drops right in — this renders:"""


broken : String
broken =
    """Now do it wrong on purpose. The `icon` slot accepts only icon-kind content — put a **chip** in there instead and the build refuses. This is the real output of `elm make`, not a screenshot we wrote:"""



-- @sample expect-compile-error: this page's subject. The `icon` slot admits the
-- `icon` kind and a Chip does not name it, so the compiler refuses this call —
-- which is exactly what the page tells the reader, and now proves.


brokenCode : String
brokenCode =
    """M3e.button [ M3e.Attributes.variant Value.filled ]
    [ M3e.Component.Button.icon (M3e.chip [] [ M3e.text "not an icon" ])
    , M3e.text "Save"
    ]"""


errorText : String
errorText =
    """The 1st argument to `icon` is not what I expect:

9|     [ M3e.Component.Button.icon (M3e.chip [] [ M3e.text "not an icon" ])
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This `chip` call produces:

    Element { a | chip : M3e.Kind.Brand, icon : M3e.Kind.Brand, ... } adm_ msg

But `icon` needs the 1st argument to be:

    Element { icon : M3e.Kind.Brand, loadingIndicator : M3e.Kind.Brand } adm_ msg

Hint: Seems like a record field typo. Maybe chip should be icon?"""


readError : String
readError =
    """Read it the plain way: *"this is a chip; the icon slot only takes icons."* The compiler even guesses your intent — *maybe chip should be icon?* You never shipped a broken button, because it was never a value you could build. The same guard covers variants: a variant that doesn't exist isn't a name you can type — only the real tokens (`M3e.Attributes.variant Value.filled`, `M3e.Attributes.variant Value.outlined`, …) exist at all.

**The browser never sees the mistake — the compiler does.**

One boundary to be precise about: this hard, compile-time guard is what the *type system* gives you — a wrong-kind child in a named slot, or a token that doesn't exist. The component-agnostic slot setters (`M3e.slotLeading`, …) accept the *union* of every component's kinds, so placing a child in a slot the container doesn't declare is caught not by the compiler but by an elm-review rule (`Cem.ValidSlotKind`) — which you run in CI. The next chapter is the dial for exactly this: what the compiler holds versus what the linter holds."""


recap : String
recap =
    """- Every piece carries a **kind**; every **slot** declares the kinds it accepts.
- A mismatch is a **compile error** — the wrong UI is never a value you can build.
- The error names the culprit in plain terms and often guesses the fix.
- **Next: [The strictness dial](/guide/strictness) →** the compiler leaves some checks loose on purpose — here's the dial that turns them back up."""

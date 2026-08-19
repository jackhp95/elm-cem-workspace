module Route.Guide.Troubleshooting exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/troubleshooting`): the safety net. A scannable
lookup of the common failures — kind mismatch, a class that renders nothing, an
enum token rejected at the loose layer, a missing accessible name, and the big
one: a green linter is not a green build. Each is cause → symptom → fix, with the
real message. Written to stand alone as a reference.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Sectioning
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
        , description = "Decode the common failures — kind mismatch, a class that renders nothing, an enum token rejected at the loose layer, a missing accessible name — and remember a green linter is not a green build."
        , locale = Nothing
        , title = "Troubleshooting · elm-m3e"
        }
        |> Seo.website


entry : String -> String -> M3e.Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ msg
entry prose code =
    TypedHtml.section [ TA.class "space-y-3" ]
        [ Doc.markdown prose
        , Doc.codeBlock Doc.NoLang code
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Troubleshooting"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Troubleshooting"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , entry kindMismatch kindMismatchError
                , entry m3eInNativeSlot m3eInNativeSlotError
                , entry deadClass deadClassNote
                , entry looseEnum looseEnumNote
                , entry missingName missingNameError
                , TypedHtml.section [ TA.class "space-y-4" ] [ Doc.markdown greenLint ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """A scannable field guide to the failures you'll actually hit, each as **cause → symptom → fix**. Skim for your symptom; every message here is real output."""


kindMismatch : String
kindMismatch =
    """### A slot won't accept your child

**Cause:** you put content of the wrong *kind* in a slot. **Symptom:** a type error naming the slot, with a record field that "doesn't match." **Fix:** give the slot the kind it accepts — the compiler usually guesses it for you (*"Maybe chip should be icon?"*)."""


kindMismatchError : String
kindMismatchError =
    """This `chip` call produces:
    Element { a | chip : M3e.Kind.Brand, icon : M3e.Kind.Brand, ... } adm_ msg
But `slotIcon` needs the 1st argument to be:
    Element { icon : M3e.Kind.Brand, loadingIndicator : M3e.Kind.Brand } adm_ msg
Hint: Maybe chip should be icon?"""


m3eInNativeSlot : String
m3eInNativeSlot =
    """### A native element won't accept an M3e component

**Cause:** you put an M3e component inside a native element whose content model is *enumerated* — `<span>`, `<p>`, `<h1>`, `<li>`, `<td>`. Those admit HTML content categories (`sharedFlow` / `sharedPhrasing`) plus shared atoms, and an M3e component names its own brand kind so that its own slots can tell it apart. **Symptom:** a mismatch between `<Tag>Content` and a row that has absorbed your component's kind. **Fix:** use a flow container — `TypedHtml.div`, `section`, `header`, `nav`, `form` and ~20 more take any children at all. This is a designed limit, not a gap; the [seams guide](/guide/seams) explains why erasing the brand kind would also let a Card into a Menu. The reverse direction *does* work: native HTML goes into any M3e slot declaring `shared:flow` / `shared:phrasing`."""


m3eInNativeSlotError : String
m3eInNativeSlotError =
    """This argument is a list of type:
    List (M3e.Element (M3e.Heading.Is { a | …, sharedPhrasing : HtmlIr.Kind.Shared,
        sharedText : HtmlIr.Kind.Shared }) (SpanChildAdmittedBy childAdm) msg)
But `span` needs the 2nd argument to be:
    List (Element TypedHtml.Component.Text.SpanContent (SpanChildAdmittedBy childAdm) msg)"""


deadClass : String
deadClass =
    """### A class renders nothing

**Cause:** you wrote a proprietary design-system class (`ds-…` / `t-…`) that ships no CSS in this system, so it silently does nothing. **Symptom:** no error, no style — the element renders bare. **Fix:** the linter flags these dead classes; use a real style token or a seam instead. This is a correctness check, not a style opinion — the class simply has no effect."""


deadClassNote : String
deadClassNote =
    """NoProprietaryDsClasses: `class "ds-card"` renders nothing here —
this class ships no CSS in this system. Use a real token or a seam."""


looseEnum : String
looseEnum =
    """### An enum token type-checks but is rejected

**Cause:** the shared `M3e.Attributes.*` vocabulary closes over the library-wide *union* of enum values, so a token that's real for *some* component type-checks even on one that doesn't support it. **Symptom:** it compiles, but the linter flags it. **Fix:** use one of the component's real tokens — or reach for the per-component setter (`M3e.Button.variant`), where only that component's tokens exist as names and the mistake can't compile in the first place."""


looseEnumNote : String
looseEnumNote =
    """ValidEnumValue: `wobbly` is not a valid `variant` for this component.
Valid tokens: elevated, filled, outlined, text, tonal."""


missingName : String
missingName =
    """### A control has no accessible name

**Cause:** an icon-only control with no visible text and no `aria-label`. **Symptom:** it compiles, but the linter refuses it. **Fix:** add the accessible name — `Aria.label "…"`."""


missingNameError : String
missingNameError =
    """MissingRequiredAttribute: Component `iconButton` requires attribute
`aria-label` but this call doesn't provide it.
Add `Aria.label "..."` to the attrs list."""


greenLint : String
greenLint =
    """### "The linter is clean but the app won't compile"

**Cause:** you're treating the linter as the build. It isn't. The linter catches the *soft* misses the compiler leaves loose on purpose; it does not replace the compiler. **Symptom:** `elm-review` passes, `elm make` fails. **Fix:** a real `elm make` is the authority — read its error (the earlier entries here are all `elm make` output). **A green linter is not a green build.**"""


recap : String
recap =
    """- **Kind mismatch:** give the slot the kind it accepts; the compiler often guesses the fix.
- **Dead class / rejected token / missing name:** the linter catches what types leave loose — read its message.
- **A green linter is not a green build** — `elm make` is the authority.
- **Next: [How we prove it](/guide/how-we-prove-it) →** why you can trust every example in these docs."""

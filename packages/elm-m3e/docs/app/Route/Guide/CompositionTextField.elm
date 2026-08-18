module Route.Guide.CompositionTextField exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/composition-text-field`): build things that
aren't single components. There is no `M3e.TextField`; a text field is composed
from a form field, a typed native `<input>`, and a label wired to that input by
one shared id. Native HTML is first-class and typed; the library assembles what
you wrote and never injects structure around it. The running example gains an
Email field, live, beside its exact source.
-}

import BackendTask
import Doc
import Guide.Samples as Samples
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Component.FormField
import M3e.Kind
import M3e.Values as Value
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes
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
        , description = "A text field is not a component — it composes from a form field, a typed native input, and a label wired by one shared id. What you write is what renders."
        , locale = Nothing
        , title = "Composition, not injection · elm-m3e"
        }
        |> Seo.website


{-| The Email field for the settings panel — composed, not a component. A form
field holds a native `<label>` and a typed native `<input>`, wired together by
the one shared id "email-field". This is the value shown live and printed below.
-}



-- @sample-source guideEmailField


emailField : Element { s | formField : M3e.Kind.Brand } admittedBy msg
emailField =
    M3e.formField [ M3e.Component.FormField.variant Value.outlined ]
        [ M3e.Component.FormField.label
            (TypedHtml.label [ TypedHtml.Attributes.for "email-field" ] [ M3e.text "Email address" ])
        , M3e.Component.FormField.hint (M3e.text "We'll never share it.")
        , TypedHtml.input
            [ TypedHtml.Attributes.id "email-field"
            , TypedHtml.Attributes.type_ "email"
            , TypedHtml.Attributes.placeholder "you@example.com"
            , TypedHtml.Attributes.name "email"
            ]
            []
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Composition, not injection"
        (Doc.pane
            [ TypedHtml.div [ TypedHtml.Attributes.class "space-y-12" ]
                [ TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.pageHeading "Composition, not injection"
                    , TypedHtml.div [ TypedHtml.Attributes.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown composed
                    , Doc.showcase emailField
                    , Doc.codeBlock Doc.Elm Samples.guideEmailField
                    ]
                , TypedHtml.section [ TypedHtml.Attributes.class "space-y-4" ]
                    [ Doc.markdown native ]
                , Doc.recapBox recap
                ]
            ]
        )


intro : String
intro =
    """The settings panel needs text fields. Reach for `M3e.TextField` and… there isn't one — and there doesn't need to be. A text field is not a special component; it's a few typed pieces **composed**. That's the whole point of this chapter: you build things bigger than one component by clicking small typed parts together, and the guarantees you've met so far come along for the ride."""


composed : String
composed =
    """Here's the Email field. A **form field** holds two things: a native `<label>` and a typed native `<input>`. They're wired into one accessible control by a single shared id — `"email-field"` appears once on the label slot and once on the input slot, and the library stamps the matching `for`/`id` for you. This is the label wiring from [accessibility you can't forget](/guide/accessible-by-construction), paying off exactly where you'd want it:"""


native : String
native =
    """Two things make this safe. First, **native HTML is first-class and typed.** `TypedHtml.input` is a real `<input>`, but its attributes are closed to the ones an input actually permits — `type_`, `placeholder`, `name`, `value`, `checked`… An input has no `href`, so `TypedHtml.input [ TypedHtml.Attributes.href "/x" ]` is a **compile error**, not a raw-HTML escape hatch. You get the exact tag you asked for, with the exact attributes it's allowed.

Second, **the library never injects.** It assembles the pieces you wrote — it doesn't secretly wrap, reorder, or add structure around your content. What you write is what renders. A search field is the same move with a different input `type_`; once you can compose one field, you can compose any of them."""


recap : String
recap =
    """- There's no `M3e.TextField` — a field is **composed**: form field + typed native `<input>` + a label wired by one shared id.
- **Native HTML is typed**: an `<input>` with an `href` doesn't compile.
- The library **assembles, never injects** — what you write is what renders.
- **Next: [Generated & inspectable](/guide/generated-and-inspectable) →** you've built real things on this API; now see why you can trust it — it's generated, and inspectable data underneath."""

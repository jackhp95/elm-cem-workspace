module Route.Guide.CompositionTextField exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/composition-text-field`): build things that
aren't single components. There is no `M3e.TextField`; a text field is composed
from a form field, a typed native `<input>`, and a label wired to that input by
one shared id. Native HTML is first-class and typed; the library assembles what
you wrote and never injects structure around it. The running example gains an
Email field, live, beside its exact source.
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
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/CompositionTextField.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


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
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        composed : String
        composed =
            Doc.section "composed" d

        native : String
        native =
            Doc.section "native" d

        recap : String
        recap =
            Doc.section "recap" d
    in
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

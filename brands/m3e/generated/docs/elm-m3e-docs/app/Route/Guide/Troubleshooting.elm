module Route.Guide.Troubleshooting exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/troubleshooting`): the safety net. A scannable
lookup of the common failures — kind mismatch, a class that renders nothing, an
enum token rejected at the loose layer, a missing accessible name, and the big
one: a green linter is not a green build. Each is cause → symptom → fix, with the
real message. Written to stand alone as a reference.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
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
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/Troubleshooting.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


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
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        kindMismatch : String
        kindMismatch =
            Doc.section "kindMismatch" d

        m3eInNativeSlot : String
        m3eInNativeSlot =
            Doc.section "m3eInNativeSlot" d

        deadClass : String
        deadClass =
            Doc.section "deadClass" d

        looseEnum : String
        looseEnum =
            Doc.section "looseEnum" d

        missingName : String
        missingName =
            Doc.section "missingName" d

        greenLint : String
        greenLint =
            Doc.section "greenLint" d

        recap : String
        recap =
            Doc.section "recap" d
    in
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


kindMismatchError : String
kindMismatchError =
    """This `chip` call produces:
    Element { a | chip : M3e.Kind.Brand, icon : M3e.Kind.Brand, ... } adm_ msg
But `slotIcon` needs the 1st argument to be:
    Element { icon : M3e.Kind.Brand, loadingIndicator : M3e.Kind.Brand } adm_ msg
Hint: Maybe chip should be icon?"""


m3eInNativeSlotError : String
m3eInNativeSlotError =
    """This argument is a list of type:
    List (M3e.Element (M3e.Heading.Is { a | …, sharedPhrasing : HtmlIr.Kind.Shared,
        sharedText : HtmlIr.Kind.Shared }) (SpanChildAdmittedBy childAdm) msg)
But `span` needs the 2nd argument to be:
    List (Element TypedHtml.Component.Text.SpanContent (SpanChildAdmittedBy childAdm) msg)"""


deadClassNote : String
deadClassNote =
    """NoProprietaryDsClasses: `class "ds-card"` renders nothing here —
this class ships no CSS in this system. Use a real token or a seam."""


looseEnumNote : String
looseEnumNote =
    """ValidEnumValue: `wobbly` is not a valid `variant` for this component.
Valid tokens: elevated, filled, outlined, text, tonal."""


missingNameError : String
missingNameError =
    """MissingRequiredAttribute: Component `iconButton` requires attribute
`aria-label` but this call doesn't provide it.
Add `Aria.label "..."` to the attrs list."""
